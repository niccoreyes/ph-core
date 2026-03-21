/**
 * Structured logging for drug mapping pipeline
 * Outputs: console + structured JSON log files for analysis
 */

export type LogLevel = 'debug' | 'info' | 'warn' | 'error';
export type LogCategory =
  | 'api'
  | 'parsing'
  | 'matching'
  | 'scoring'
  | 'output'
  | 'performance';

interface LogEntry {
  timestamp: string;
  level: LogLevel;
  category: LogCategory;
  drugId?: string;
  drugName?: string;
  message: string;
  data?: unknown;
  durationMs?: number;
  error?: string;
  stack?: string;
}

interface MatchAttempt {
  drugId: string;
  drugName: string;
  genericName: string;
  strategy: string;
  query: string;
  resultCount: number;
  topMatches: Array<{
    code: string;
    display: string;
    score: number;
  }>;
  durationMs: number;
  error?: string;
}

export class MapperLogger {
  private logs: LogEntry[] = [];
  private matchAttempts: MatchAttempt[] = [];
  private startTime: number;
  private logDir: string;

  constructor(logDir = './logs') {
    this.logDir = logDir;
    this.startTime = Date.now();
    this.ensureLogDir();
  }

  private async ensureLogDir() {
    try {
      // Use Bun.write to create a dummy file which creates directories
      await Bun.write(`${this.logDir}/.gitkeep`, '');
    } catch {
      // Directory may already exist
    }
  }

  private log(
    level: LogLevel,
    category: LogCategory,
    message: string,
    meta?: {
      drugId?: string;
      drugName?: string;
      data?: unknown;
      durationMs?: number;
      error?: Error;
    }
  ) {
    const entry: LogEntry = {
      timestamp: new Date().toISOString(),
      level,
      category,
      message,
      ...meta,
    };

    if (meta?.error) {
      entry.error = meta.error.message;
      entry.stack = meta.error.stack;
    }

    this.logs.push(entry);

    // Console output with colors for readability
    const color =
      {
        debug: '\x1b[36m', // cyan
        info: '\x1b[32m', // green
        warn: '\x1b[33m', // yellow
        error: '\x1b[31m', // red
      }[level] + '\x1b[0m';

    const prefix = `[${entry.timestamp.split('T')[1].split('.')[0]}] ${level.toUpperCase()} [${category}]`;
    const drugInfo = meta?.drugId ? ` [${meta.drugId}:${meta.drugName}]` : '';

    if (level === 'error') {
      console.error(`${color}${prefix}${drugInfo} ${message}\x1b[0m`);
      if (meta?.error) console.error(meta.error.stack);
    } else if (level === 'warn') {
      console.warn(`${color}${prefix}${drugInfo} ${message}\x1b[0m`);
    } else {
      console.log(`${color}${prefix}${drugInfo} ${message}\x1b[0m`);
    }

    // Print data for debug level
    if (level === 'debug' && meta?.data) {
      console.log('  Data:', JSON.stringify(meta.data, null, 2).split('\n').join('\n  '));
    }
  }

  debug(category: LogCategory, message: string, meta?: Parameters<typeof this.log>[3]) {
    this.log('debug', category, message, meta);
  }

  info(category: LogCategory, message: string, meta?: Parameters<typeof this.log>[3]) {
    this.log('info', category, message, meta);
  }

  warn(category: LogCategory, message: string, meta?: Parameters<typeof this.log>[3]) {
    this.log('warn', category, message, meta);
  }

  error(category: LogCategory, message: string, meta?: Parameters<typeof this.log>[3]) {
    this.log('error', category, message, meta);
  }

  logMatchAttempt(attempt: MatchAttempt) {
    this.matchAttempts.push(attempt);
    this.debug('matching', `Match attempt: ${attempt.strategy}`, {
      drugId: attempt.drugId,
      drugName: attempt.drugName,
      data: {
        query: attempt.query,
        results: attempt.resultCount,
        topMatch: attempt.topMatches[0],
        durationMs: attempt.durationMs,
      },
    });
  }

  async flush(): Promise<void> {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const totalDuration = Date.now() - this.startTime;

    // Ensure log directory exists
    await this.ensureLogDir();

    // Write structured logs
    const logFile = `${this.logDir}/mapping-${timestamp}.jsonl`;
    const logContent = this.logs.map((entry) => JSON.stringify(entry)).join('\n');
    await Bun.write(logFile, logContent);

    // Write match attempts summary
    const matchFile = `${this.logDir}/matches-${timestamp}.json`;
    const matchContent = JSON.stringify(
      {
        summary: {
          totalDrugs: new Set(this.matchAttempts.map((m) => m.drugId)).size,
          totalAttempts: this.matchAttempts.length,
          avgQueryTimeMs: Math.round(
            this.matchAttempts.reduce((a, m) => a + m.durationMs, 0) /
              this.matchAttempts.length || 0
          ),
          strategies: Object.fromEntries(
            Object.entries(
              this.matchAttempts.reduce((acc, m) => {
                acc[m.strategy] = (acc[m.strategy] || 0) + 1;
                return acc;
              }, {} as Record<string, number>)
            )
          ),
          errors: this.matchAttempts.filter((m) => m.error).length,
        },
        attempts: this.matchAttempts,
      },
      null,
      2
    );
    await Bun.write(matchFile, matchContent);

    // Write summary to console
    this.info('output', `Logs written to ${logFile}`);
    this.info('output', `Match summary written to ${matchFile}`);
    this.info('performance', `Total execution time: ${totalDuration}ms`);

    // Summary statistics
    const byStrategy = this.matchAttempts.reduce((acc, m) => {
      acc[m.strategy] = acc[m.strategy] || { count: 0, avgResults: 0 };
      acc[m.strategy].count++;
      acc[m.strategy].avgResults += m.resultCount;
      return acc;
    }, {} as Record<string, { count: number; avgResults: number }>);

    for (const [strategy, stats] of Object.entries(byStrategy)) {
      this.info('output', `  ${strategy}: ${stats.count} attempts, avg ${Math.round(stats.avgResults / stats.count)} results`);
    }
  }
}
