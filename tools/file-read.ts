import fs from 'node:fs';
import path from 'node:path';
import type { Tool } from '../models/ToolTypes.js';

const MAX_FILE_SIZE = 1024 * 1024; // 1MB

export const fileReadTool: Tool = {
  definition: {
    name: 'file_read',
    description:
      'Read the contents of a file. Returns the file content as text. Use absolute paths or paths relative to the current working directory.',
    parameters: {
      type: 'object',
      properties: {
        path: {
          type: 'string',
          description: 'The file path to read',
        },
      },
      required: ['path'],
    },
  },

  async execute(args: Record<string, unknown>): Promise<string> {
    const filePath = args.path as string;
    if (!filePath) {
      return 'Error: path is required';
    }

    const resolved = path.resolve(filePath);

    try {
      const stat = fs.statSync(resolved);
      if (stat.isDirectory()) {
        return `Error: "${resolved}" is a directory, not a file`;
      }
      if (stat.size > MAX_FILE_SIZE) {
        return `Error: File is too large (${(stat.size / 1024 / 1024).toFixed(1)}MB). Max is 1MB.`;
      }

      return fs.readFileSync(resolved, 'utf-8');
    } catch (error) {
      if (error instanceof Error && 'code' in error && (error as NodeJS.ErrnoException).code === 'ENOENT') {
        return `Error: File not found: ${resolved}`;
      }
      return `Error reading file: ${error instanceof Error ? error.message : String(error)}`;
    }
  },
};
