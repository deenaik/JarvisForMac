import 'dotenv/config';
import readline from 'node:readline';
import { toolRegistry } from './services/tool-registry.js';
import { runAgentLoop } from './services/agent-loop.js';
import { conversationManager } from './services/conversation-manager.js';
import { getDatabase, closeDatabase } from './services/database.js';

// Import all Phase 1 tools
import { shellTool } from './tools/shell.js';
import { fileReadTool } from './tools/file-read.js';
import { fileWriteTool } from './tools/file-write.js';
import { applescriptTool } from './tools/applescript.js';
import { shortcutsTool } from './tools/shortcuts.js';
import { webSearchTool } from './tools/web-search.js';

function registerTools(): void {
  toolRegistry.register(shellTool);
  toolRegistry.register(fileReadTool);
  toolRegistry.register(fileWriteTool);
  toolRegistry.register(applescriptTool);
  toolRegistry.register(shortcutsTool);
  toolRegistry.register(webSearchTool);
}

function printBanner(): void {
  console.log(`
╔══════════════════════════════════════╗
║         JARVIS for Mac v0.1         ║
║     Your Personal AI Assistant      ║
╚══════════════════════════════════════╝
`);
  const tools = toolRegistry.listDefinitions();
  console.log(`Tools loaded: ${tools.map((t) => t.name).join(', ')}`);
  console.log('Type your request, or "quit" to exit. "new" starts a fresh conversation.\n');
}

async function main(): Promise<void> {
  // Initialize
  getDatabase();
  registerTools();
  printBanner();

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  const prompt = (): void => {
    rl.question('You: ', async (input) => {
      const trimmed = input.trim();

      if (!trimmed) {
        prompt();
        return;
      }

      if (trimmed.toLowerCase() === 'quit' || trimmed.toLowerCase() === 'exit') {
        console.log('\nGoodbye!');
        cleanup(rl);
        return;
      }

      if (trimmed.toLowerCase() === 'new') {
        conversationManager.createNew();
        console.log('\n--- New conversation started ---\n');
        prompt();
        return;
      }

      try {
        console.log(''); // spacing
        const response = await runAgentLoop(trimmed);
        console.log(`\nJarvis: ${response.text}\n`);

        if (response.totalSteps > 1) {
          console.log(`  (${response.totalSteps} steps, ${response.steps.length} tool calls)\n`);
        }
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        console.error(`\nError: ${message}\n`);
      }

      prompt();
    });
  };

  prompt();
}

function cleanup(rl: readline.Interface): void {
  rl.close();
  closeDatabase();
  process.exit(0);
}

// Handle graceful shutdown
process.on('SIGINT', () => {
  console.log('\n\nShutting down...');
  closeDatabase();
  process.exit(0);
});

main().catch((error) => {
  console.error('Fatal error:', error);
  closeDatabase();
  process.exit(1);
});
