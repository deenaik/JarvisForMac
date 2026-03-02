import { execFile } from 'node:child_process';
import type { Tool } from '../models/ToolTypes.js';
import { TOOL_TIMEOUT_MS } from '../config/jarvis.js';

export const shortcutsTool: Tool = {
  definition: {
    name: 'shortcuts',
    description:
      'Run macOS Shortcuts or list available shortcuts. Use action "list" to see all available shortcuts, or "run" to execute a specific shortcut by name. Optionally pass input text to the shortcut.',
    parameters: {
      type: 'object',
      properties: {
        action: {
          type: 'string',
          description: '"list" to list all shortcuts, "run" to execute one',
          enum: ['list', 'run'],
        },
        name: {
          type: 'string',
          description: 'The name of the shortcut to run (required when action is "run")',
        },
        input: {
          type: 'string',
          description: 'Optional input text to pass to the shortcut',
        },
      },
      required: ['action'],
    },
  },

  async execute(args: Record<string, unknown>): Promise<string> {
    const action = args.action as string;
    const name = args.name as string | undefined;
    const input = args.input as string | undefined;

    if (action === 'list') {
      return new Promise((resolve) => {
        execFile(
          '/usr/bin/shortcuts',
          ['list'],
          { timeout: TOOL_TIMEOUT_MS },
          (error, stdout, stderr) => {
            if (error) {
              resolve(`Error listing shortcuts: ${stderr || error.message}`);
            } else {
              resolve(stdout.trim() || '(no shortcuts found)');
            }
          }
        );
      });
    }

    if (action === 'run') {
      if (!name) {
        return 'Error: name is required when action is "run"';
      }

      const runArgs = ['run', name];
      if (input) {
        runArgs.push('--input-type', 'text', '--input', input);
      }

      return new Promise((resolve) => {
        execFile(
          '/usr/bin/shortcuts',
          runArgs,
          { timeout: TOOL_TIMEOUT_MS * 2 }, // Shortcuts may take longer
          (error, stdout, stderr) => {
            if (error) {
              resolve(`Error running shortcut "${name}": ${stderr || error.message}`);
            } else {
              resolve(stdout.trim() || `Shortcut "${name}" executed successfully.`);
            }
          }
        );
      });
    }

    return `Error: Unknown action "${action}". Use "list" or "run".`;
  },
};
