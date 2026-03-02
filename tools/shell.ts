import { execFile } from 'node:child_process';
import type { Tool } from '../models/ToolTypes.js';
import { TOOL_TIMEOUT_MS } from '../config/jarvis.js';

const MAX_OUTPUT_LENGTH = 50_000; // ~50KB output limit

export const shellTool: Tool = {
  definition: {
    name: 'shell',
    description:
      'Execute a shell command on macOS. Returns stdout and stderr. Use for system commands, file operations, installing packages, running scripts, etc. Commands run in the user\'s default shell.',
    parameters: {
      type: 'object',
      properties: {
        command: {
          type: 'string',
          description: 'The shell command to execute',
        },
      },
      required: ['command'],
    },
  },

  async execute(args: Record<string, unknown>): Promise<string> {
    const command = args.command as string;
    if (!command) {
      return 'Error: command is required';
    }

    return new Promise((resolve) => {
      execFile(
        '/bin/zsh',
        ['-c', command],
        {
          timeout: TOOL_TIMEOUT_MS,
          maxBuffer: 1024 * 1024, // 1MB
          env: { ...process.env, PATH: process.env.PATH },
        },
        (error, stdout, stderr) => {
          let output = '';

          if (stdout) {
            output += stdout;
          }
          if (stderr) {
            output += (output ? '\n' : '') + `stderr: ${stderr}`;
          }
          if (error && !stdout && !stderr) {
            output = `Error: ${error.message}`;
          }

          // Truncate very long output
          if (output.length > MAX_OUTPUT_LENGTH) {
            output = output.slice(0, MAX_OUTPUT_LENGTH) + '\n... (output truncated)';
          }

          resolve(output || '(no output)');
        }
      );
    });
  },
};
