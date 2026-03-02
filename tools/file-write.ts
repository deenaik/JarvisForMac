import fs from 'node:fs';
import path from 'node:path';
import type { Tool } from '../models/ToolTypes.js';

export const fileWriteTool: Tool = {
  definition: {
    name: 'file_write',
    description:
      'Write content to a file. Creates the file and parent directories if they don\'t exist. Can write new content or append to existing files.',
    parameters: {
      type: 'object',
      properties: {
        path: {
          type: 'string',
          description: 'The file path to write to',
        },
        content: {
          type: 'string',
          description: 'The content to write to the file',
        },
        append: {
          type: 'string',
          description: 'Set to "true" to append instead of overwrite. Default: "false"',
          default: 'false',
        },
      },
      required: ['path', 'content'],
    },
  },

  async execute(args: Record<string, unknown>): Promise<string> {
    const filePath = args.path as string;
    const content = args.content as string;
    const append = String(args.append ?? 'false') === 'true';

    if (!filePath) return 'Error: path is required';
    if (content === undefined || content === null) return 'Error: content is required';

    const resolved = path.resolve(filePath);

    try {
      // Create parent directories
      const dir = path.dirname(resolved);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }

      if (append) {
        fs.appendFileSync(resolved, content, 'utf-8');
        return `Appended to ${resolved}`;
      } else {
        fs.writeFileSync(resolved, content, 'utf-8');
        return `Wrote ${content.length} bytes to ${resolved}`;
      }
    } catch (error) {
      return `Error writing file: ${error instanceof Error ? error.message : String(error)}`;
    }
  },
};
