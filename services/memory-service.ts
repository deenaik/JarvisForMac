// Phase 3: Memory Service
// TODO: Store/query memories, inject relevant context into agent loop
// - Store episodic memories (conversation summaries)
// - Store semantic memories (learned facts/preferences)
// - Store procedural memories (learned workflows)
// - RAG: query relevant memories before each LLM call

import type { Memory } from '../models/MemoryTypes.js';

export class MemoryService {
  async store(_memory: Memory): Promise<void> {
    // TODO: Store memory with embedding in SQLite + sqlite-vec
    throw new Error('Memory service not implemented yet (Phase 3)');
  }

  async query(_text: string, _limit?: number): Promise<Memory[]> {
    // TODO: Generate embedding, search sqlite-vec, return ranked results
    return [];
  }

  async getRelevantContext(_userMessage: string): Promise<string> {
    // TODO: Query memories and format as context for system prompt injection
    return '';
  }
}

export const memoryService = new MemoryService();
