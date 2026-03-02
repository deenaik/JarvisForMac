import 'dotenv/config';
import { createInterface } from 'node:readline';
import { toolRegistry } from './services/tool-registry.js';
import { runAgentLoop } from './services/agent-loop.js';
import { conversationManager } from './services/conversation-manager.js';
import { getDatabase, closeDatabase } from './services/database.js';
import type { ProgressCallback } from './models/AgentTypes.js';

// Import all Phase 1 tools
import { shellTool } from './tools/shell.js';
import { fileReadTool } from './tools/file-read.js';
import { fileWriteTool } from './tools/file-write.js';
import { applescriptTool } from './tools/applescript.js';
import { shortcutsTool } from './tools/shortcuts.js';
import { webSearchTool } from './tools/web-search.js';

// --- IPC Protocol Types ---

interface IPCRequest {
  id: string;
  type: 'query' | 'new_conversation';
  text?: string;
}

interface IPCResponse {
  id: string | null;
  type: 'ready' | 'tool_start' | 'tool_result' | 'response' | 'error';
  toolName?: string;
  step?: number;
  success?: boolean;
  text?: string;
  totalSteps?: number;
  toolCalls?: number;
  message?: string;
}

function send(msg: IPCResponse): void {
  process.stdout.write(JSON.stringify(msg) + '\n');
}

function registerTools(): void {
  toolRegistry.register(shellTool);
  toolRegistry.register(fileReadTool);
  toolRegistry.register(fileWriteTool);
  toolRegistry.register(applescriptTool);
  toolRegistry.register(shortcutsTool);
  toolRegistry.register(webSearchTool);
}

async function handleRequest(request: IPCRequest): Promise<void> {
  if (request.type === 'new_conversation') {
    conversationManager.createNew();
    send({ id: request.id, type: 'response', text: 'New conversation started.' });
    return;
  }

  if (request.type === 'query') {
    if (!request.text) {
      send({ id: request.id, type: 'error', message: 'Missing "text" field in query request.' });
      return;
    }

    const onProgress: ProgressCallback = (event) => {
      if (event.type === 'tool_start') {
        send({ id: request.id, type: 'tool_start', toolName: event.toolName, step: event.step });
      } else if (event.type === 'tool_result') {
        send({ id: request.id, type: 'tool_result', toolName: event.toolName, step: event.step, success: event.success });
      }
    };

    try {
      const response = await runAgentLoop(request.text, onProgress);
      send({
        id: request.id,
        type: 'response',
        text: response.text,
        totalSteps: response.totalSteps,
        toolCalls: response.steps.reduce((sum, s) => sum + s.toolCalls.length, 0),
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      send({ id: request.id, type: 'error', message });
    }
    return;
  }

  send({ id: request.id, type: 'error', message: `Unknown request type: ${(request as IPCRequest).type}` });
}

function main(): void {
  // Redirect console to stderr so stdout is clean NDJSON
  const origLog = console.log;
  const origError = console.error;
  const origWarn = console.warn;
  console.log = (...args: unknown[]) => origError('[server:log]', ...args);
  console.warn = (...args: unknown[]) => origWarn('[server:warn]', ...args);

  // Initialize
  getDatabase();
  registerTools();

  // Signal readiness
  send({ id: null, type: 'ready' });

  // Read NDJSON from stdin
  const rl = createInterface({ input: process.stdin });

  rl.on('line', (line: string) => {
    const trimmed = line.trim();
    if (!trimmed) return;

    let request: IPCRequest;
    try {
      request = JSON.parse(trimmed) as IPCRequest;
    } catch {
      send({ id: null, type: 'error', message: `Invalid JSON: ${trimmed}` });
      return;
    }

    handleRequest(request).catch((error) => {
      const message = error instanceof Error ? error.message : String(error);
      send({ id: request.id ?? null, type: 'error', message });
    });
  });

  rl.on('close', () => {
    closeDatabase();
    process.exit(0);
  });
}

process.on('SIGINT', () => {
  closeDatabase();
  process.exit(0);
});

process.on('SIGTERM', () => {
  closeDatabase();
  process.exit(0);
});

main();
