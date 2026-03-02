// Phase 3: Memory store tool
// TODO: Allow the agent to explicitly store facts and preferences

import type { Tool } from '../models/ToolTypes.js';

export const memoryStoreTool: Tool = {
  definition: {
    name: 'memory_store',
    description:
      'Store a fact, preference, or procedure in your knowledge base for future recall. Use this when the user tells you something to remember or when you learn something important.',
    parameters: {
      type: 'object',
      properties: {
        content: {
          type: 'string',
          description: 'The fact, preference, or procedure to remember',
        },
        type: {
          type: 'string',
          description: 'Memory type: semantic (facts/preferences) or procedural (workflows)',
          enum: ['semantic', 'procedural'],
        },
        category: {
          type: 'string',
          description: 'Category for organization (e.g., "preference", "workflow", "fact")',
        },
      },
      required: ['content', 'type'],
    },
  },

  async execute(_args: Record<string, unknown>): Promise<string> {
    // TODO: Use memoryService.store() to persist memory
    return 'Memory system not implemented yet (Phase 3)';
  },
};
