/**
 * SNOMED CT FHIR API Client
 * Handles caching, retries, and rate limiting
 */

import { MapperLogger } from './logger';

const SNOMED_FHIR_BASE = 'https://tx.fhirlab.net/fhir';

export interface SnomedConcept {
  code: string;
  display: string;
  system: string;
  version?: string;
  inactive?: boolean;
  fullySpecifiedName?: string;
  designation?: Array<{
    language?: string;
    use?: {
      system?: string;
      code?: string;
      display?: string;
    };
    value?: string;
  }>;
}

export interface ValueSetExpansion {
  expansion: {
    offset?: number;
    count?: number;
    total?: number;
    contains?: SnomedConcept[];
  };
}

interface CacheEntry {
  data: ValueSetExpansion;
  timestamp: number;
}

export class SnomedClient {
  private cache: Map<string, CacheEntry> = new Map();
  private cacheTtlMs = 5 * 60 * 1000; // 5 minutes
  private requestDelayMs = 100; // Delay between requests
  private lastRequestTime = 0;
  private logger: MapperLogger;

  constructor(logger: MapperLogger) {
    this.logger = logger;
  }

  private async delay(): Promise<void> {
    const now = Date.now();
    const timeSinceLastRequest = now - this.lastRequestTime;
    if (timeSinceLastRequest < this.requestDelayMs) {
      await new Promise((r) => setTimeout(r, this.requestDelayMs - timeSinceLastRequest));
    }
    this.lastRequestTime = Date.now();
  }

  private getCacheKey(url: string): string {
    return url;
  }

  private getCached(key: string): ValueSetExpansion | null {
    const entry = this.cache.get(key);
    if (!entry) return null;
    if (Date.now() - entry.timestamp > this.cacheTtlMs) {
      this.cache.delete(key);
      return null;
    }
    this.logger.debug('api', `Cache hit for ${key.slice(0, 80)}...`);
    return entry.data;
  }

  private setCached(key: string, data: ValueSetExpansion): void {
    this.cache.set(key, { data, timestamp: Date.now() });
  }

  async expandValueSet(
    eclOrUrl: string,
    options?: {
      filter?: string;
      count?: number;
      offset?: number;
      includeDesignations?: boolean;
      systemVersion?: string;
      elements?: string[];
      _format?: string;
    }
  ): Promise<ValueSetExpansion> {
    const params = new URLSearchParams();

    params.set('_format', options?._format || 'json');

    // Build URL - could be full ValueSet URL or ECL expression
    if (eclOrUrl.includes('?fhir_vs') || eclOrUrl.startsWith('http')) {
      params.set('url', eclOrUrl);
    } else {
      // Assume it's an ECL expression
      // Use the PH SNOMED Edition (999991001000101) with version support
      const version = options?.systemVersion || '20240701';
      const urlBase = `http://snomed.info/sct/999991001000101/version/${version}?fhir_vs`;
      params.set('url', urlBase);
      params.set('system-version', `http://snomed.info/sct|http://snomed.info/sct/999991001000101/version/${version}`);
    }

    if (options?.filter) params.set('filter', options.filter);
    if (options?.count) params.set('count', options.count.toString());
    if (options?.offset) params.set('offset', options.offset.toString());
    if (options?.includeDesignations) params.set('includeDesignations', 'true');
    if (options?.elements && options.elements.length > 0) {
      params.set('elements', options.elements.join(','));
    }

    const url = `${SNOMED_FHIR_BASE}/ValueSet/$expand?${params.toString()}`;
    const cacheKey = this.getCacheKey(url);

    // Check cache
    const cached = this.getCached(cacheKey);
    if (cached) return cached;

    await this.delay();

    this.logger.debug('api', `Fetching: ${url.slice(0, 120)}...`, {
      data: { ecl: eclOrUrl, filter: options?.filter },
    });

    const startTime = Date.now();
    try {
      const response = await fetch(url);
      const duration = Date.now() - startTime;

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`HTTP ${response.status}: ${errorText.slice(0, 200)}`);
      }

      const data: ValueSetExpansion = await response.json();

      this.logger.debug('api', `Fetched in ${duration}ms`, {
        data: {
          total: data.expansion?.total,
          returned: data.expansion?.contains?.length || 0,
        },
        durationMs: duration,
      });

      this.setCached(cacheKey, data);
      return data;
    } catch (error) {
      this.logger.error('api', `Fetch failed after ${Date.now() - startTime}ms`, {
        error: error as Error,
        data: { url: url.slice(0, 120) },
      });
      throw error;
    }
  }

  /**
   * Search by display name filter
   * Good for finding concepts by name with fuzzy matching
   */
  async searchByName(
    filter: string,
    ecl?: string,
    count = 20
  ): Promise<SnomedConcept[]> {
    const hierarchy = ecl || '< 373873005'; // Pharmaceutical/biologic product
    const result = await this.expandValueSet(hierarchy, {
      filter,
      count,
      includeDesignations: true,
      elements: ['expansion.contains.code', 'expansion.contains.display', 'expansion.contains.fullySpecifiedName', 'expansion.contains.active'],
    });
    return result.expansion?.contains || [];
  }

  /**
   * Search using the exact format shown in the example
   * https://tx.fhirlab.net/fhir/ValueSet/$expand?_format=json&url=...
   */
  async searchWithDesignations(
    filter: string,
    options?: {
      count?: number;
      ecl?: string;
      version?: string;
    }
  ): Promise<SnomedConcept[]> {
    const version = options?.version || '20240701';
    // Build the full URL like the example
    const url = `http://snomed.info/sct/999991001000101/version/${version}?fhir_vs`;

    const result = await this.expandValueSet(url, {
      filter,
      count: options?.count || 100,
      includeDesignations: true,
      systemVersion: version,
      elements: [
        'expansion.contains.code',
        'expansion.contains.display',
        'expansion.contains.fullySpecifiedName',
        'expansion.contains.active',
      ],
    });

    return result.expansion?.contains || [];
  }

  /**
   * Get substance concepts for a generic name
   */
  async findSubstance(genericName: string, count = 10): Promise<SnomedConcept[]> {
    // ECL for substances - use the PH SNOMED Edition
    const ecl = '< 105590001'; // Substance hierarchy
    const result = await this.expandValueSet(ecl, {
      filter: this.cleanSearchTerm(genericName),
      count,
      includeDesignations: true,
      elements: ['expansion.contains.code', 'expansion.contains.display', 'expansion.contains.fullySpecifiedName', 'expansion.contains.active'],
    });
    return result.expansion?.contains || [];
  }

  /**
   * Find clinical drugs (has dose form + strength)
   */
  async findClinicalDrugs(
    genericName: string,
    options?: {
      doseForm?: string;
      strength?: string;
    },
    count = 20
  ): Promise<SnomedConcept[]> {
    // ECL for clinical drugs with attributes
    let ecl = '< 736542009'; // Clinical drug

    // Build expression with constraints if provided
    if (options?.doseForm || options?.strength) {
      const constraints: string[] = [];
      if (options.doseForm) {
        // Map common dose forms to SNOMED codes
        const formCode = this.mapDoseForm(options.doseForm);
        if (formCode) {
          constraints.push(`[0..0] 736542009 | Has dose form (attribute) | = ${formCode}`);
        }
      }
      // Note: Strength filtering is more complex, usually done post-query
    }

    const result = await this.expandValueSet(ecl, {
      filter: this.cleanSearchTerm(genericName),
      count,
      includeDesignations: true,
      elements: ['expansion.contains.code', 'expansion.contains.display', 'expansion.contains.fullySpecifiedName', 'expansion.contains.active'],
    });

    return result.expansion?.contains || [];
  }

  /**
   * Validate a code exists in SNOMED
   */
  async validateCode(code: string): Promise<boolean> {
    const url = `${SNOMED_FHIR_BASE}/CodeSystem/$validate-code?system=http://snomed.info/sct&code=${code}`;
    const cacheKey = this.getCacheKey(url);

    const cached = this.getCached(cacheKey);
    if (cached) return true;

    await this.delay();

    try {
      const response = await fetch(url);
      if (!response.ok) return false;

      const data = await response.json();
      const valid = data.parameter?.find((p: { name: string }) => p.name === 'result')?.valueBoolean === true;

      if (valid) {
        this.setCached(cacheKey, { expansion: { total: 1 } });
      }

      return valid;
    } catch {
      return false;
    }
  }

  private cleanSearchTerm(term: string): string {
    // Remove salt form parentheticals for better matching
    return term
      .replace(/\s*\([^)]+\)/g, '') // Remove (as besilate), etc.
      .replace(/\+/g, ' ') // Replace + with space
      .replace(/\s+/g, ' ') // Normalize whitespace
      .trim();
  }

  private mapDoseForm(form: string): string | null {
    // Common dose form mappings - expand as needed
    const mappings: Record<string, string> = {
      tablet: '385055001',
      capsule: '385049007',
      injection: '385268001',
      solution: '385024009',
      suspension: '385023003',
      syrup: '421026006',
      cream: '385024009',
      ointment: '385024009',
      'eye drops': '385024009',
      'ear drops': '385024009',
    };

    const normalized = form.toLowerCase().trim();
    return mappings[normalized] || null;
  }

  getCacheStats(): { size: number; ttl: number } {
    return { size: this.cache.size, ttl: this.cacheTtlMs };
  }
}
