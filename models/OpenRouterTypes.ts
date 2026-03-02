// OpenRouter API types with tool calling support

export interface OpenRouterMessage {
  role: 'system' | 'user' | 'assistant' | 'tool';
  content: string | null;
  tool_calls?: OpenRouterToolCall[];
  tool_call_id?: string;
}

export interface OpenRouterToolCall {
  id: string;
  type: 'function';
  function: {
    name: string;
    arguments: string; // JSON string
  };
}

export interface OpenRouterToolDefinition {
  type: 'function';
  function: {
    name: string;
    description: string;
    parameters: Record<string, unknown>; // JSON Schema
  };
}

export interface OpenRouterRequest {
  model: string;
  messages: OpenRouterMessage[];
  tools?: OpenRouterToolDefinition[];
  tool_choice?: 'auto' | 'none' | { type: 'function'; function: { name: string } };
  response_format?: { type: 'json_object' };
  temperature?: number;
  max_tokens?: number;
}

export interface OpenRouterChoice {
  message: {
    role: 'assistant';
    content: string | null;
    tool_calls?: OpenRouterToolCall[];
  };
  finish_reason: 'stop' | 'tool_calls' | 'length' | 'content_filter';
}

export interface OpenRouterResponse {
  id: string;
  choices: OpenRouterChoice[];
  usage?: {
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
  };
}

export interface OpenRouterError {
  error: {
    message: string;
    type: string;
    code: number;
  };
}
