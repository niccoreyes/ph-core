/**
 * PH FDA Drug to SNOMED CT Mapper
 * Main entry point - run with: bun run index.ts [options]
 *
 * Options:
 *   --input, -i     Input FSH file path (default: ../../input/fsh/codeSystems/drugs.fsh)
 *   --output, -o    Output JSON file path (default: ./output/mappings.json)
 *   --limit, -l     Limit number of drugs to process (for testing)
 *   --strategy, -s  Only use specific strategy (exact|generic|components|fuzzy)
 *   --verbose, -v   Enable verbose debug logging
 *   --help, -h      Show help
 */

import { MapperLogger } from './logger';
import { SnomedClient } from './snomed-client';
import { DrugMapper, type DrugMapping, type PhFdaDrug } from './mapper';
import { parseFshDrugs } from './fsh-parser';

interface CliOptions {
  inputPath: string;
  outputPath: string;
  limit?: number;
  strategy?: string;
  verbose: boolean;
}

function parseArgs(args: string[]): CliOptions {
  const options: CliOptions = {
    inputPath: '../../input/fsh/codeSystems/drugs.fsh',
    outputPath: './output/mappings.json',
    verbose: false,
  };

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    switch (arg) {
      case '--input':
      case '-i':
        options.inputPath = args[++i];
        break;
      case '--output':
      case '-o':
        options.outputPath = args[++i];
        break;
      case '--limit':
      case '-l':
        options.limit = parseInt(args[++i], 10);
        break;
      case '--strategy':
      case '-s':
        options.strategy = args[++i];
        break;
      case '--verbose':
      case '-v':
        options.verbose = true;
        break;
      case '--help':
      case '-h':
        showHelp();
        process.exit(0);
        break;
    }
  }

  return options;
}

function showHelp() {
  console.log(`
PH FDA Drug to SNOMED CT Mapper

Usage: bun run index.ts [options]

Options:
  --input, -i     Input FSH file path (default: ../../input/fsh/codeSystems/drugs.fsh)
  --output, -o    Output JSON file path (default: ./output/mappings.json)
  --limit, -l     Limit number of drugs to process (for testing)
  --strategy, -s  Only use specific strategy (exact|generic|components|fuzzy)
  --verbose, -v   Enable verbose debug logging
  --help, -h      Show this help

Examples:
  # Process first 5 drugs with verbose logging
  bun run index.ts --limit 5 --verbose

  # Use specific input/output
  bun run index.ts --input ./my-drugs.fsh --output ./my-mappings.json

  # Test single strategy
  bun run index.ts --strategy exact --limit 10
`);
}

async function main() {
  const options = parseArgs(Bun.argv.slice(2));
  const logger = new MapperLogger('./logs');

  console.log('\n========================================');
  console.log('PH FDA Drug to SNOMED CT Mapper');
  console.log('========================================\n');

  console.log('Configuration:');
  console.log(`  Input: ${options.inputPath}`);
  console.log(`  Output: ${options.outputPath}`);
  if (options.limit) console.log(`  Limit: ${options.limit} drugs`);
  if (options.strategy) console.log(`  Strategy: ${options.strategy} only`);
  console.log(`  Verbose: ${options.verbose}`);
  console.log();

  // Parse input
  logger.info('parsing', 'Reading FSH file...', { data: { path: options.inputPath } });
  const parseResult = await parseFshDrugs(options.inputPath);

  if (parseResult.errors.length > 0) {
    parseResult.errors.forEach(e => logger.error('parsing', e));
    process.exit(1);
  }

  let drugs = parseResult.drugs;
  logger.info('parsing', `Parsed ${drugs.length} drugs from FSH file`);

  // Apply limit if specified
  if (options.limit) {
    drugs = drugs.slice(0, options.limit);
    logger.info('parsing', `Limited to ${drugs.length} drugs for testing`);
  }

  // Show sample drugs
  console.log('\nSample drugs to process:');
  drugs.slice(0, 3).forEach((d, i) => {
    console.log(`  ${i + 1}. ${d.code}: ${d.display}`);
    console.log(`     Generic: ${d.genericName || '(none)'}`);
    console.log(`     Form: ${d.dosageForm || '(none)'}`);
    if (options.verbose) {
      console.log('     Full:', JSON.stringify(d));
    }
  });
  if (drugs.length > 3) {
    console.log(`  ... and ${drugs.length - 3} more`);
  }
  console.log();

  // Initialize mapper
  const client = new SnomedClient(logger);
  const mapper = new DrugMapper(client, logger);

  // Process drugs
  const mappings: DrugMapping[] = [];
  const startTime = Date.now();

  console.log('Processing drugs...\n');

  for (let i = 0; i < drugs.length; i++) {
    const drug = drugs[i];
    const progress = `[${i + 1}/${drugs.length}]`;

    console.log(`${progress} Processing ${drug.code}: ${drug.display}`);

    try {
      const mapping = await mapper.mapDrug(drug);
      mappings.push(mapping);

      // Progress output
      const status = mapping.matched
        ? `✓ Matched (${mapping.matchStrategy}, confidence: ${mapping.confidence})`
        : '✗ No match';
      console.log(`   ${status}`);

      if (mapping.matched) {
        console.log(`   SNOMED: ${mapping.snomedCode} - ${mapping.snomedDisplay}`);
      }
      if (mapping.errors.length > 0) {
        console.log(`   Errors: ${mapping.errors.join(', ')}`);
      }
      console.log();

    } catch (error) {
      logger.error('matching', `Unexpected error processing ${drug.code}`, { error: error as Error });
      mappings.push({
        drugId: drug.code,
        drugName: drug.display,
        genericName: drug.genericName || '',
        matched: false,
        matchStrategy: 'error',
        snomedCode: null,
        snomedDisplay: null,
        confidence: 0,
        alternatives: [],
        errors: [(error as Error).message],
        queryCount: 0,
        durationMs: 0,
      });
    }
  }

  // Summary
  const duration = Date.now() - startTime;
  const matched = mappings.filter(m => m.matched).length;
  const failed = mappings.filter(m => !m.matched).length;
  const avgConfidence = matched > 0
    ? mappings.filter(m => m.matched).reduce((a, m) => a + m.confidence, 0) / matched
    : 0;

  console.log('\n========================================');
  console.log('Mapping Summary');
  console.log('========================================');
  console.log(`Total processed: ${mappings.length}`);
  console.log(`Matched: ${matched} (${Math.round(matched / mappings.length * 100)}%)`);
  console.log(`Failed: ${failed}`);
  console.log(`Average confidence: ${Math.round(avgConfidence * 100) / 100}`);
  console.log(`Total time: ${Math.round(duration / 1000)}s`);
  console.log(`Avg time per drug: ${Math.round(duration / mappings.length)}ms`);

  // Strategy breakdown
  const byStrategy = mappings.reduce((acc, m) => {
    const key = m.matchStrategy;
    acc[key] = (acc[key] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);

  console.log('\nMatches by strategy:');
  Object.entries(byStrategy)
    .sort((a, b) => b[1] - a[1])
    .forEach(([strategy, count]) => {
      console.log(`  ${strategy}: ${count}`);
    });

  // Write output
  try {
    await Bun.mkdir('./output', { recursive: true });
    await Bun.write(options.outputPath, JSON.stringify({
      meta: {
        generatedAt: new Date().toISOString(),
        sourceFile: options.inputPath,
        totalDrugs: drugs.length,
        matched,
        failed,
        avgConfidence: Math.round(avgConfidence * 100) / 100,
        durationMs: duration,
      },
      mappings,
    }, null, 2));
    console.log(`\nOutput written to: ${options.outputPath}`);
  } catch (error) {
    logger.error('output', `Failed to write output: ${error}`);
  }

  // Flush logs
  await logger.flush();

  console.log('\nDone!');
  process.exit(0);
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
