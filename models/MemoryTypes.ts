// Phase 3: Memory system types
// TODO: Implement memory storage and retrieval

export type MemoryType = 'episodic' | 'semantic' | 'procedural';

export interface EpisodicMemory {
  id: string;
  type: 'episodic';
  conversationId: string;
  summary: string;
  entities: string[];
  outcomes: string[];
  embedding: number[];
  createdAt: string;
}

export interface SemanticMemory {
  id: string;
  type: 'semantic';
  fact: string;
  category: string;
  confidence: number;
  source: string;
  embedding: number[];
  createdAt: string;
  updatedAt: string;
}

export interface ProceduralMemory {
  id: string;
  type: 'procedural';
  name: string;
  triggerPatterns: string[];
  steps: string[];
  successCount: number;
  failureCount: number;
  embedding: number[];
  createdAt: string;
  updatedAt: string;
}

export type Memory = EpisodicMemory | SemanticMemory | ProceduralMemory;
