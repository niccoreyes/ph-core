# PH FDA Drug to SNOMED CT Mapper

Maps Philippine FDA registered drugs to SNOMED CT concepts using the FHIR terminology server.

## Quick Start

```bash
# Run with defaults (processes all drugs)
bun run index.ts

# Test with just 5 drugs and verbose logging
bun run index.ts --limit 5 --verbose

# Custom input/output
bun run index.ts --input ./my-drugs.fsh --output ./results.json
```

## Files

| File | Purpose |
|------|---------|
| `index.ts` | Main entry point with CLI |
| `mapper.ts` | Core mapping logic with 5 strategies |
| `snomed-client.ts` | FHIR API client with caching |
| `fsh-parser.ts` | Parses FSH CodeSystem files |
| `logger.ts` | Structured logging for debugging |

## Mapping Strategies (in order)

1. **exact** - Full generic name + dose form + strength
2. **generic+form** - Generic name filtered by dose form
3. **generic-only** - Generic name alone
4. **components** - For combo drugs (split on `+`)
5. **fuzzy-brand** - Fuzzy match on brand name

## Debugging

### Console Output
- Real-time progress with match status
- Colored log levels (debug=dim, info=green, warn=yellow, error=red)
- Per-drug timing and confidence scores

### Log Files

After each run, check:

```
logs/
├── mapping-{timestamp}.jsonl   # Structured log entries
└── matches-{timestamp}.json    # Match attempts with queries
```

**Analyzing match logs:**

```bash
# Find drugs with no matches
jq '.attempts[] | select(.topMatches | length == 0)' logs/matches-*.json

# Find slow queries
jq '.attempts[] | select(.durationMs > 5000)' logs/matches-*.json

# See strategy distribution
jq '.summary.strategies' logs/matches-*.json
```

### Common Issues

**No matches for any drug:**
```bash
# Check API connectivity
bun run index.ts --limit 1 --verbose
# Look for api category logs
```

**Spelling variations not matching:**
- Check `logs/matches-*.json` to see the actual queries being sent
- Look at `scoreBreakdown` to see why matches were rejected

**Rate limiting / slow:**
- The client has built-in delays (100ms between requests)
- Check `logs/mapping-*.jsonl` for `api` category with `durationMs`

## Output Format

```json
{
  "meta": {
    "generatedAt": "2026-03-21T10:30:00Z",
    "sourceFile": "...",
    "totalDrugs": 100,
    "matched": 85,
    "failed": 15,
    "avgConfidence": 0.87
  },
  "mappings": [
    {
      "drugId": "DRP-10144",
      "drugName": "Twinact",
      "genericName": "Telmisartan + Amlodipine (as besilate)",
      "matched": true,
      "matchStrategy": "components",
      "snomedCode": "770045006",
      "snomedDisplay": "Telmisartan 40 mg / Amlodipine 5 mg oral tablet",
      "confidence": 0.92,
      "alternatives": [...],
      "queryCount": 2,
      "durationMs": 450
    }
  ]
}
```

## SNOMED CT API

The client uses the Philippine SNOMED CT Edition (999991001000101) by default with designations enabled:

```typescript
// Example query generated for "paracetamol":
// https://tx.fhirlab.net/fhir/ValueSet/$expand?_format=json
//   &url=http://snomed.info/sct/999991001000101/version/20240701?fhir_vs
//   &filter=paracetamol
//   &includeDesignations=true
//   &elements=expansion.contains.code,expansion.contains.display,...
```

To search manually with the same parameters:

```typescript
const client = new SnomedClient(logger);

// Simple search
const results = await client.searchByName('paracetamol');

// Search with designations (includes fullySpecifiedName)
const resultsWithFSN = await client.searchWithDesignations('paracetamol', {
  count: 100,
  version: '20240701'
});

// Each result now includes:
// - code: SNOMED concept ID
// - display: Preferred term
// - fullySpecifiedName: Complete FSN with semantics
// - active: Whether concept is active
```

## Extending

### Add a new strategy

In `mapper.ts`, add to the strategies array:

```typescript
() => this.tryMyNewStrategy(drug),
```

And implement:

```typescript
private async tryMyNewStrategy(drug: PhFdaDrug): Promise<DrugMapping | null> {
  // Your logic
  this.logAttempt(drug, 'my-strategy', query, count, scored, duration);
  return match ? this.buildMapping(...) : null;
}
```

### Adjust scoring weights

Edit `scoreMatches()` in `mapper.ts` to change how confidence is calculated.
