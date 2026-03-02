import { execFile } from 'node:child_process';
import type { Tool } from '../models/ToolTypes.js';
import { TOOL_TIMEOUT_MS } from '../config/jarvis.js';

export const applescriptTool: Tool = {
  definition: {
    name: 'applescript',
    description:
      'Execute AppleScript code via osascript. Use this to control macOS applications (Finder, Safari, Mail, Calendar, etc.), manage windows, send notifications, interact with System Preferences, and automate GUI tasks. You can also use JavaScript for Automation (JXA) by setting language to "javascript".',
    parameters: {
      type: 'object',
      properties: {
        script: {
          type: 'string',
          description: 'The AppleScript (or JXA) code to execute',
        },
        language: {
          type: 'string',
          description: 'Script language: "applescript" or "javascript" (JXA). Default: "applescript"',
          enum: ['applescript', 'javascript'],
          default: 'applescript',
        },
      },
      required: ['script'],
    },
  },

  async execute(args: Record<string, unknown>): Promise<string> {
    const script = args.script as string;
    const language = (args.language as string) ?? 'applescript';

    if (!script) {
      return 'Error: script is required';
    }

    const osascriptArgs = language === 'javascript'
      ? ['-l', 'JavaScript', '-e', script]
      : ['-e', script];

    return new Promise((resolve) => {
      execFile(
        '/usr/bin/osascript',
        osascriptArgs,
        { timeout: TOOL_TIMEOUT_MS },
        (error, stdout, stderr) => {
          if (error) {
            resolve(`Error: ${stderr || error.message}`);
          } else {
            resolve(stdout.trim() || '(script executed successfully, no output)');
          }
        }
      );
    });
  },
};
