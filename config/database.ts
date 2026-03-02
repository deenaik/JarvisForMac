import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export const DB_PATH = path.join(__dirname, '..', 'data', 'jarvis.db');
export const SCHEMA_VERSION = 1;
