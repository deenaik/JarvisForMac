import Database from 'better-sqlite3';
import fs from 'node:fs';
import path from 'node:path';
import { DB_PATH, SCHEMA_VERSION } from '../config/database.js';

let db: Database.Database | null = null;

export function getDatabase(): Database.Database {
  if (!db) {
    // Ensure data directory exists
    const dir = path.dirname(DB_PATH);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    db = new Database(DB_PATH);
    db.pragma('journal_mode = WAL');
    db.pragma('foreign_keys = ON');
    initializeSchema(db);
  }
  return db;
}

function initializeSchema(database: Database.Database): void {
  database.exec(`
    CREATE TABLE IF NOT EXISTS schema_version (
      version INTEGER NOT NULL
    );

    CREATE TABLE IF NOT EXISTS conversations (
      id TEXT PRIMARY KEY,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      conversation_id TEXT NOT NULL,
      role TEXT NOT NULL,
      content TEXT,
      tool_calls TEXT,
      tool_call_id TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (conversation_id) REFERENCES conversations(id)
    );

    CREATE TABLE IF NOT EXISTS agent_state (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  `);

  // Check and update schema version
  const row = database.prepare('SELECT version FROM schema_version LIMIT 1').get() as { version: number } | undefined;
  if (!row) {
    database.prepare('INSERT INTO schema_version (version) VALUES (?)').run(SCHEMA_VERSION);
  }
}

export function closeDatabase(): void {
  if (db) {
    db.close();
    db = null;
  }
}

// Convenience helpers

export function getState(key: string): string | null {
  const db = getDatabase();
  const row = db.prepare('SELECT value FROM agent_state WHERE key = ?').get(key) as { value: string } | undefined;
  return row?.value ?? null;
}

export function setState(key: string, value: string): void {
  const db = getDatabase();
  db.prepare(`
    INSERT INTO agent_state (key, value, updated_at)
    VALUES (?, ?, ?)
    ON CONFLICT(key) DO UPDATE SET value = excluded.value, updated_at = excluded.updated_at
  `).run(key, value, new Date().toISOString());
}
