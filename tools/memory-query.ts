// Phase 3: Memory query tool
// TODO: Allow the agent to search its own knowledge base

import type { Tool } from '../models/ToolTypes.js';

export const memoryQueryTool: Tool = {
  definition: {
    name: 'memory_query',
    description:
      'Search your knowledge base for relevant memories, facts, and learned preferences. Use this to recall past conversations, user preferences, and previously learned procedures.',
    parameters: {
      type: 'object',
      properties: {
        query: {
          type: 'string',
          description: 'What to search for in memory',
        },
        type: {
          type: 'string',
          description: 'Filter by memory type: episodic, semantic, procedural, or all',
          enum: ['episodic', 'semantic', 'procedural', 'all'],
          default: 'all',
        },
      },
      required: ['query'],
    },
  },

  async execute(_args: Record<string, unknown>): Promise<string> {
    // TODO: Use memoryService.query() to search knowledge base
    return 'Memory system not implemented yet (Phase 3)';
  },
};
