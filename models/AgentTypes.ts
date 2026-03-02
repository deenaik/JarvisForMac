import type { OpenRouterMessage } from './OpenRouterTypes.js';

export interface ToolCall {
  id: string;
  name: string;
  arguments: Record<string, unknown>;
}

export interface ToolResult {
  toolCallId: string;
  name: string;
  output: string;
  isError: boolean;
}

export interface AgentStep {
  step: number;
  toolCalls: ToolCall[];
  toolResults: ToolResult[];
  assistantMessage: string | null;
}

export interface Conversation {
  id: string;
  messages: OpenRouterMessage[];
  steps: AgentStep[];
  createdAt: string;
  updatedAt: string;
}

export interface AgentResponse {
  text: string;
  steps: AgentStep[];
  totalSteps: number;
}

export type ProgressEventType = 'tool_start' | 'tool_result';

export interface ProgressEvent {
  type: ProgressEventType;
  toolName: string;
  step: number;
  success?: boolean;
}

export type ProgressCallback = (event: ProgressEvent) => void;
