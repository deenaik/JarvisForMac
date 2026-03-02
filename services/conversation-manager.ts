import { randomUUID } from 'node:crypto';
import type { OpenRouterMessage } from '../models/OpenRouterTypes.js';
import type { Conversation } from '../models/AgentTypes.js';
import { SYSTEM_PROMPT } from '../config/jarvis.js';
import { getDatabase } from './database.js';

const MAX_MESSAGES = 100; // Truncate beyond this to avoid token overflow

export class ConversationManager {
  private current: Conversation;

  constructor() {
    this.current = this.createNew();
  }

  createNew(): Conversation {
    const now = new Date().toISOString();
    const conversation: Conversation = {
      id: randomUUID(),
      messages: [{ role: 'system', content: SYSTEM_PROMPT }],
      steps: [],
      createdAt: now,
      updatedAt: now,
    };
    this.current = conversation;

    // Persist conversation record
    const db = getDatabase();
    db.prepare('INSERT INTO conversations (id, created_at, updated_at) VALUES (?, ?, ?)').run(
      conversation.id,
      now,
      now
    );

    return conversation;
  }

  getCurrent(): Conversation {
    return this.current;
  }

  getMessages(): OpenRouterMessage[] {
    return this.current.messages;
  }

  addMessage(message: OpenRouterMessage): void {
    this.current.messages.push(message);
    this.current.updatedAt = new Date().toISOString();

    // Persist message
    const db = getDatabase();
    db.prepare(
      'INSERT INTO messages (conversation_id, role, content, tool_calls, tool_call_id, created_at) VALUES (?, ?, ?, ?, ?, ?)'
    ).run(
      this.current.id,
      message.role,
      message.content,
      message.tool_calls ? JSON.stringify(message.tool_calls) : null,
      message.tool_call_id ?? null,
      this.current.updatedAt
    );

    // Truncate if too long (keep system prompt + recent messages)
    if (this.current.messages.length > MAX_MESSAGES) {
      const system = this.current.messages[0];
      const recent = this.current.messages.slice(-MAX_MESSAGES + 1);
      this.current.messages = [system, ...recent];
    }
  }
}

export const conversationManager = new ConversationManager();
