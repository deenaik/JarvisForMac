import 'dotenv/config';

export const OPENROUTER_BASE_URL = 'https://openrouter.ai/api/v1';
export const REQUEST_TIMEOUT_MS = 30_000;

// Model selection: fast/cheap for most tasks, stronger for complex reasoning
export const DEFAULT_MODEL = 'google/gemini-2.0-flash-001';
export const REASONING_MODEL = 'anthropic/claude-sonnet-4';

export type TaskComplexity = 'simple' | 'complex';

export function getModelForTask(complexity: TaskComplexity): string {
  switch (complexity) {
    case 'complex':
      return REASONING_MODEL;
    case 'simple':
    default:
      return DEFAULT_MODEL;
  }
}

export function getApiKey(): string {
  const key = process.env.OPENROUTER_API_KEY;
  if (!key || key === 'your-api-key-here') {
    throw new Error(
      'OPENROUTER_API_KEY not configured. Set it in .env file.'
    );
  }
  return key;
}
