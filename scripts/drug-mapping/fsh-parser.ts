/**
 * Parse PH FDA drugs from FSH CodeSystem file
 */

import { PhFdaDrug } from './mapper';

interface ParseResult {
  drugs: PhFdaDrug[];
  errors: string[];
}

export async function parseFshDrugs(filePath: string): Promise<ParseResult> {
  const result: ParseResult = { drugs: [], errors: [] };

  try {
    const content = await Bun.file(filePath).text();
    const lines = content.split('\n');

    let currentDrug: Record<string, string | undefined> | null = null;
    let currentCode: string | null = null;
    let currentDisplay: string | null = null;
    let lastPropertyCode: string | null = null;

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim();
      if (!line || line.startsWith('//')) continue;

      // Look for concept definitions with a specific code:
      // * #PH-FDA-DRUGS #DRP-10144 "Twinact"
      // Skip root concept: * #PH-FDA-DRUGS "Display" "Description"
      const conceptMatch = line.match(
        /^\*\s+#PH-FDA-DRUGS\s+#([A-Za-z0-9_-]+)\s+"([^"]+)"/
      );
      if (conceptMatch) {
        // Save previous drug if exists
        if (currentDrug && currentCode) {
          result.drugs.push({
            code: currentCode,
            display: currentDisplay || currentCode,
            ...currentDrug,
          } as PhFdaDrug);
        }

        currentCode = conceptMatch[1];
        currentDisplay = conceptMatch[2];
        currentDrug = { code: currentCode, display: currentDisplay };
        lastPropertyCode = null;
        continue;
      }

      // Property code definition:
      // * #PH-FDA-DRUGS #DRP-10144 ^property[+].code = #genericName
      // The code here can contain the specific drug code
      const propertyCodeMatch = line.match(
        /^\*\s+#PH-FDA-DRUGS\s+#[A-Za-z0-9_-]+\s+\^property\[[0-9+]+\]\.code\s*=\s*#(\w+)/
      );
      if (propertyCodeMatch && currentDrug) {
        lastPropertyCode = propertyCodeMatch[1];
        continue;
      }

      // Property value:
      // * #PH-FDA-DRUGS #DRP-10144 ^property[=].valueString = "value"
      const propertyValueMatch = line.match(
        /^\*\s+#PH-FDA-DRUGS\s+#[A-Za-z0-9_-]+\s+\^property\[[0-9+=]*\]\.valueString\s*=\s*"([^"]+)"/
      );
      if (propertyValueMatch && currentDrug && lastPropertyCode) {
        const value = propertyValueMatch[1];

        switch (lastPropertyCode) {
          case 'genericName':
            currentDrug.genericName = value;
            break;
          case 'dosageStrength':
            currentDrug.dosageStrength = value;
            break;
          case 'dosageForm':
            currentDrug.dosageForm = value;
            break;
          case 'pharmacologicCategory':
            currentDrug.pharmacologicCategory = value;
            break;
          case 'classification':
            currentDrug.classification = value;
            break;
          case 'manufacturer':
            currentDrug.manufacturer = value;
            break;
          case 'countryOfOrigin':
            currentDrug.countryOfOrigin = value;
            break;
          case 'packaging':
            currentDrug.packaging = value;
            break;
          case 'importer':
            currentDrug.importer = value;
            break;
          case 'distributor':
            currentDrug.distributor = value;
            break;
        }
        continue;
      }
    }

    // Don't forget the last drug
    if (currentDrug && currentCode) {
      result.drugs.push({
        code: currentCode,
        display: currentDisplay || currentCode,
        ...currentDrug,
      } as PhFdaDrug);
    }
  } catch (error) {
    result.errors.push(`Failed to read file: ${error}`);
  }

  return result;
}

/**
 * Alternative: Parse from a simple JSON format if FSH is too complex
 */
export async function parseJsonDrugs(filePath: string): Promise<ParseResult> {
  const result: ParseResult = { drugs: [], errors: [] };

  try {
    const content = await Bun.file(filePath).text();
    result.drugs = JSON.parse(content);
  } catch (error) {
    result.errors.push(`Failed to parse JSON: ${error}`);
  }

  return result;
}

export function drugToJson(drug: PhFdaDrug): string {
  return JSON.stringify(drug, null, 2);
}
