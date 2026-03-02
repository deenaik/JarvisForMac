// Phase 3: Embedding Service
// TODO: Generate embeddings for memory storage and retrieval
// - Initially use LLM-generated 384-dim embeddings via OpenRouter
// - Later swap to local model (e.g., Ollama) for offline/faster embeddings

export const EMBEDDING_DIM = 384;

export class EmbeddingService {
  async generateEmbedding(_text: string): Promise<number[]> {
    // TODO: Call OpenRouter or local model to generate embedding
    throw new Error('Embedding service not implemented yet (Phase 3)');
  }

  async generateBatchEmbeddings(_texts: string[]): Promise<number[][]> {
    // TODO: Batch embedding generation for efficiency
    throw new Error('Embedding service not implemented yet (Phase 3)');
  }
}

export const embeddingService = new EmbeddingService();
