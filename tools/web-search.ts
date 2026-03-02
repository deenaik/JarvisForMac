import { execFile } from 'node:child_process';
import type { Tool } from '../models/ToolTypes.js';
import { TOOL_TIMEOUT_MS } from '../config/jarvis.js';

export const webSearchTool: Tool = {
  definition: {
    name: 'web_search',
    description:
      'Search the web using a query. Returns search results with titles, URLs, and snippets. Uses curl to fetch results from a search API.',
    parameters: {
      type: 'object',
      properties: {
        query: {
          type: 'string',
          description: 'The search query',
        },
      },
      required: ['query'],
    },
  },

  async execute(args: Record<string, unknown>): Promise<string> {
    const query = args.query as string;
    if (!query) {
      return 'Error: query is required';
    }

    // Use DuckDuckGo's HTML-lite endpoint which doesn't require API keys
    const encodedQuery = encodeURIComponent(query);
    const url = `https://html.duckduckgo.com/html/?q=${encodedQuery}`;

    return new Promise((resolve) => {
      execFile(
        '/usr/bin/curl',
        ['-s', '-L', '-A', 'Mozilla/5.0', url],
        { timeout: TOOL_TIMEOUT_MS, maxBuffer: 1024 * 1024 },
        (error, stdout) => {
          if (error) {
            resolve(`Error searching: ${error.message}`);
            return;
          }

          // Parse the HTML response for result snippets
          const results = parseSearchResults(stdout);
          if (results.length === 0) {
            resolve(`No results found for: "${query}"`);
          } else {
            resolve(results.join('\n\n'));
          }
        }
      );
    });
  },
};

function parseSearchResults(html: string): string[] {
  const results: string[] = [];
  // Match DuckDuckGo result blocks
  const resultPattern = /<a[^>]*class="result__a"[^>]*href="([^"]*)"[^>]*>([\s\S]*?)<\/a>/g;
  const snippetPattern = /<a[^>]*class="result__snippet"[^>]*>([\s\S]*?)<\/a>/g;

  const titles: string[] = [];
  const urls: string[] = [];
  const snippets: string[] = [];

  let match;
  while ((match = resultPattern.exec(html)) !== null) {
    urls.push(decodeURIComponent(match[1].replace(/.*uddg=/, '').replace(/&.*/, '')));
    titles.push(match[2].replace(/<[^>]+>/g, '').trim());
  }

  while ((match = snippetPattern.exec(html)) !== null) {
    snippets.push(match[1].replace(/<[^>]+>/g, '').trim());
  }

  const count = Math.min(titles.length, 5); // Top 5 results
  for (let i = 0; i < count; i++) {
    const title = titles[i] || '(no title)';
    const url = urls[i] || '';
    const snippet = snippets[i] || '';
    results.push(`${i + 1}. ${title}\n   ${url}\n   ${snippet}`);
  }

  return results;
}
