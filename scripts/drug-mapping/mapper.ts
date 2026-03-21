/**
 * Main mapping logic for PH FDA drugs to SNOMED CT
 * Implements cascading match strategies with detailed logging
 */

import { MapperLogger, type MatchAttempt } from './logger';
import { SnomedClient, type SnomedConcept } from './snomed-client';

export interface PhFdaDrug {
  code: string;
  display: string;
  genericName?: string;
  dosageStrength?: string;
  dosageForm?: string;
  pharmacologicCategory?: string;
  [key: string]: string | undefined;
}

export interface DrugMapping {
  drugId: string;
  drugName: string;
  genericName: string;
  matched: boolean;
  matchStrategy: string;
  snomedCode: string | null;
  snomedDisplay: string | null;
  confidence: number;
  alternatives: Array<{
    code: string;
    display: string;
    score: number;
  }>;
  errors: string[];
  queryCount: number;
  durationMs: number;
}

interface ScoredConcept extends SnomedConcept {
  score: number;
  scoreBreakdown: Record<string, number>;
}

export class DrugMapper {
  private client: SnomedClient;
  private logger: MapperLogger;

  constructor(client: SnomedClient, logger: MapperLogger) {
    this.client = client;
    this.logger = logger;
  }

  async mapDrug(drug: PhFdaDrug): Promise<DrugMapping> {
    const startTime = Date.now();
    const errors: string[] = [];
    let queryCount = 0;

    this.logger.info('matching', `Starting mapping for ${drug.display}`, {
      drugId: drug.code,
      drugName: drug.display,
      data: { genericName: drug.genericName, form: drug.dosageForm },
    });

    // Try strategies in order of specificity
    const strategies: Array<() => Promise<DrugMapping | null>> = [
      () => this.tryExactMatch(drug),
      () => this.tryGenericPlusForm(drug),
      () => this.tryGenericOnly(drug),
      () => this.tryComponentSearch(drug),
      () => this.tryFuzzyMatch(drug),
    ];

    for (const strategy of strategies) {
      try {
        queryCount++;
        const result = await strategy();
        if (result) {
          result.queryCount = queryCount;
          result.durationMs = Date.now() - startTime;
          this.logger.info('matching', `Success with strategy: ${result.matchStrategy}`, {
            drugId: drug.code,
            drugName: drug.display,
            data: {
              snomedCode: result.snomedCode,
              confidence: result.confidence,
            },
            durationMs: result.durationMs,
          });
          return result;
        }
      } catch (error) {
        const msg = error instanceof Error ? error.message : String(error);
        errors.push(msg);
        this.logger.warn('matching', `Strategy failed: ${msg}`, {
          drugId: drug.code,
          drugName: drug.display,
        });
      }
    }

    // No match found
    const duration = Date.now() - startTime;
    this.logger.warn('matching', `No match found after ${strategies.length} strategies`, {
      drugId: drug.code,
      drugName: drug.display,
      durationMs: duration,
    });

    return {
      drugId: drug.code,
      drugName: drug.display,
      genericName: drug.genericName || '',
      matched: false,
      matchStrategy: 'none',
      snomedCode: null,
      snomedDisplay: null,
      confidence: 0,
      alternatives: [],
      errors,
      queryCount,
      durationMs: duration,
    };
  }

  /**
   * Strategy 1: Exact match on generic name
   */
  private async tryExactMatch(drug: PhFdaDrug): Promise<DrugMapping | null> {
    if (!drug.genericName) return null;

    const strategy = 'exact';
    const query = drug.genericName;
    const queryStart = Date.now();

    const concepts = await this.client.findClinicalDrugs(query, {
      doseForm: drug.dosageForm,
      strength: drug.dosageStrength,
    }, 10);

    const scored = this.scoreMatches(drug, concepts);
    const topMatch = scored[0];

    this.logAttempt(drug, strategy, query, concepts.length, scored, Date.now() - queryStart);

    if (topMatch && topMatch.score >= 0.95) {
      return this.buildMapping(drug, strategy, topMatch, scored.slice(1, 4));
    }

    return null;
  }

  /**
   * Strategy 2: Generic name + dose form
   */
  private async tryGenericPlusForm(drug: PhFdaDrug): Promise<DrugMapping | null> {
    if (!drug.genericName || !drug.dosageForm) return null;

    const strategy = 'generic+form';
    // Search for just the generic, filter by form post-query
    const query = this.cleanGenericName(drug.genericName);
    const queryStart = Date.now();

    const concepts = await this.client.findClinicalDrugs(query, {}, 20);

    // Post-filter by form
    const formTerms = drug.dosageForm.toLowerCase().split(/\s+/);
    const filtered = concepts.filter(c =>
      formTerms.some(term => c.display.toLowerCase().includes(term))
    );

    const scored = this.scoreMatches(drug, filtered.length > 0 ? filtered : concepts);
    const topMatch = scored[0];

    this.logAttempt(drug, strategy, query, concepts.length, scored, Date.now() - queryStart);

    if (topMatch && topMatch.score >= 0.85) {
      return this.buildMapping(drug, strategy, topMatch, scored.slice(1, 4));
    }

    return null;
  }

  /**
   * Strategy 3: Generic name only (cleaned)
   */
  private async tryGenericOnly(drug: PhFdaDrug): Promise<DrugMapping | null> {
    if (!drug.genericName) return null;

    const strategy = 'generic-only';
    const query = this.cleanGenericName(drug.genericName);
    const queryStart = Date.now();

    const concepts = await this.client.findClinicalDrugs(query, {}, 20);
    const scored = this.scoreMatches(drug, concepts);
    const topMatch = scored[0];

    this.logAttempt(drug, strategy, query, concepts.length, scored, Date.now() - queryStart);

    if (topMatch && topMatch.score >= 0.75) {
      return this.buildMapping(drug, strategy, topMatch, scored.slice(1, 4));
    }

    return null;
  }

  /**
   * Strategy 4: Component search (for combo drugs)
   * Split on '+' and search for products containing all components
   */
  private async tryComponentSearch(drug: PhFdaDrug): Promise<DrugMapping | null> {
    if (!drug.genericName || !drug.genericName.includes('+')) return null;

    const strategy = 'components';
    const components = drug.genericName.split('+').map(s => this.cleanGenericName(s));
    const queryStart = Date.now();

    // Search for each component and find intersections
    const componentResults: SnomedConcept[][] = [];
    for (const component of components) {
      const results = await this.client.findClinicalDrugs(component, {}, 50);
      componentResults.push(results);
    }

    // Find products that appear in all component searches
    const intersection = componentResults.reduce((acc, results) => {
      const codes = new Set(results.map(r => r.code));
      return acc.filter(a => codes.has(a.code));
    }, componentResults[0] || []);

    const scored = this.scoreMatches(drug, intersection);
    const topMatch = scored[0];

    this.logAttempt(drug, strategy, components.join(' + '), intersection.length, scored, Date.now() - queryStart);

    if (topMatch && topMatch.score >= 0.70) {
      return this.buildMapping(drug, strategy, topMatch, scored.slice(1, 4));
    }

    return null;
  }

  /**
   * Strategy 5: Fuzzy match on brand name
   */
  private async tryFuzzyMatch(drug: PhFdaDrug): Promise<DrugMapping | null> {
    const strategy = 'fuzzy-brand';
    const query = drug.display;
    const queryStart = Date.now();

    const concepts = await this.client.findClinicalDrugs(query, {}, 20);
    const scored = this.scoreMatches(drug, concepts);
    const topMatch = scored[0];

    this.logAttempt(drug, strategy, query, concepts.length, scored, Date.now() - queryStart);

    if (topMatch && topMatch.score >= 0.60) {
      return this.buildMapping(drug, strategy, topMatch, scored.slice(1, 4));
    }

    return null;
  }

  private scoreMatches(drug: PhFdaDrug, concepts: SnomedConcept[]): ScoredConcept[] {
    const drugGeneric = (drug.genericName || '').toLowerCase();
    const drugForm = (drug.dosageForm || '').toLowerCase();
    const drugBrand = drug.display.toLowerCase();

    return concepts.map(concept => {
      const display = concept.display.toLowerCase();
      const fsn = (concept.fullySpecifiedName || '').toLowerCase();
      const scores: Record<string, number> = {};

      // Generic name similarity (most important)
      if (drug.genericName) {
        scores.generic = this.stringSimilarity(drugGeneric, display);
        // Also check FSN for better matching
        const fsnScore = this.stringSimilarity(drugGeneric, fsn) * 0.8;
        scores.generic = Math.max(scores.generic, fsnScore);
      }

      // Dose form presence
      if (drug.dosageForm) {
        const displayMatch = drugForm.split(/\s+/).some(term => display.includes(term)) ? 0.1 : 0;
        const fsnMatch = drugForm.split(/\s+/).some(term => fsn.includes(term)) ? 0.08 : 0;
        scores.form = Math.max(displayMatch, fsnMatch);
      }

      // Brand name similarity (lower weight)
      scores.brand = this.stringSimilarity(drugBrand, display) * 0.3;

      // Boost exact matches
      if (display.includes(drugGeneric)) scores.exactMatch = 0.2;
      if (fsn.includes(drugGeneric)) scores.fsnMatch = 0.15;

      const totalScore = Object.values(scores).reduce((a, b) => a + b, 0);

      return {
        ...concept,
        score: Math.min(totalScore, 1.0),
        scoreBreakdown: scores,
      };
    }).sort((a, b) => b.score - a.score);
  }

  private stringSimilarity(a: string, b: string): number {
    // Simple Levenshtein-based similarity (0-1)
    const longer = a.length > b.length ? a : b;
    const shorter = a.length > b.length ? b : a;

    if (longer.length === 0) return 1.0;

    const distance = this.levenshteinDistance(longer, shorter);
    return (longer.length - distance) / longer.length;
  }

  private levenshteinDistance(a: string, b: string): number {
    const matrix: number[][] = [];

    for (let i = 0; i <= b.length; i++) {
      matrix[i] = [i];
    }

    for (let j = 0; j <= a.length; j++) {
      matrix[0][j] = j;
    }

    for (let i = 1; i <= b.length; i++) {
      for (let j = 1; j <= a.length; j++) {
        if (b.charAt(i - 1) === a.charAt(j - 1)) {
          matrix[i][j] = matrix[i - 1][j - 1];
        } else {
          matrix[i][j] = Math.min(
            matrix[i - 1][j - 1] + 1,
            Math.min(matrix[i][j - 1] + 1, matrix[i - 1][j] + 1)
          );
        }
      }
    }

    return matrix[b.length][a.length];
  }

  private cleanGenericName(name: string): string {
    return name
      .replace(/\s*\([^)]+\)/g, '') // Remove salt forms
      .replace(/\s+/g, ' ')
      .trim();
  }

  private logAttempt(
    drug: PhFdaDrug,
    strategy: string,
    query: string,
    resultCount: number,
    scored: ScoredConcept[],
    durationMs: number
  ): void {
    const attempt: MatchAttempt = {
      drugId: drug.code,
      drugName: drug.display,
      genericName: drug.genericName || '',
      strategy,
      query,
      resultCount,
      topMatches: scored.slice(0, 3).map(s => ({
        code: s.code,
        display: s.display,
        score: Math.round(s.score * 100) / 100,
      })),
      durationMs,
    };

    this.logger.logMatchAttempt(attempt);
  }

  private buildMapping(
    drug: PhFdaDrug,
    strategy: string,
    topMatch: ScoredConcept,
    alternatives: ScoredConcept[]
  ): DrugMapping {
    return {
      drugId: drug.code,
      drugName: drug.display,
      genericName: drug.genericName || '',
      matched: true,
      matchStrategy: strategy,
      snomedCode: topMatch.code,
      snomedDisplay: topMatch.display,
      confidence: Math.round(topMatch.score * 100) / 100,
      alternatives: alternatives.map(a => ({
        code: a.code,
        display: a.display,
        score: Math.round(a.score * 100) / 100,
      })),
      errors: [],
      queryCount: 0,
      durationMs: 0,
    };
  }
}
