import {
  OPENROUTER_BASE_URL,
  DEFAULT_MODEL,
  REQUEST_TIMEOUT_MS,
  getApiKey,
} from '../config/openrouter.js';
import type {
  OpenRouterMessage,
  OpenRouterRequest,
  OpenRouterResponse,
  OpenRouterError,
  OpenRouterToolDefinition,
} from '../models/OpenRouterTypes.js';

export class OpenRouterClient {
  /**
   * Basic chat completion without tools (for simple queries).
   */
  async chatCompletion(
    messages: OpenRouterMessage[],
    options?: {
      model?: string;
      jsonMode?: boolean;
      temperature?: number;
      maxTokens?: number;
    }
  ): Promise<string> {
    const response = await this.chatCompletionRaw(messages, {
      model: options?.model,
      temperature: options?.temperature,
      maxTokens: options?.maxTokens,
      jsonMode: options?.jsonMode,
    });

    const content = response.choices?.[0]?.message?.content;
    if (!content) {
      throw new Error('Empty response from OpenRouter');
    }
    return content;
  }

  /**
   * Chat completion with tool calling support. Returns the full response
   * so the agent loop can inspect tool_calls and finish_reason.
   */
  async chatCompletionWithTools(
    messages: OpenRouterMessage[],
    tools: OpenRouterToolDefinition[],
    options?: {
      model?: string;
      temperature?: number;
      maxTokens?: number;
      toolChoice?: OpenRouterRequest['tool_choice'];
    }
  ): Promise<OpenRouterResponse> {
    return this.chatCompletionRaw(messages, {
      model: options?.model,
      temperature: options?.temperature,
      maxTokens: options?.maxTokens,
      tools: tools.length > 0 ? tools : undefined,
      toolChoice: options?.toolChoice,
    });
  }

  private async chatCompletionRaw(
    messages: OpenRouterMessage[],
    options?: {
      model?: string;
      jsonMode?: boolean;
      temperature?: number;
      maxTokens?: number;
      tools?: OpenRouterToolDefinition[];
      toolChoice?: OpenRouterRequest['tool_choice'];
    }
  ): Promise<OpenRouterResponse> {
    const apiKey = getApiKey();

    const body: OpenRouterRequest = {
      model: options?.model ?? DEFAULT_MODEL,
      messages,
      temperature: options?.temperature ?? 0.3,
      max_tokens: options?.maxTokens ?? 4096,
    };

    if (options?.jsonMode) {
      body.response_format = { type: 'json_object' };
    }

    if (options?.tools) {
      body.tools = options.tools;
      body.tool_choice = options.toolChoice ?? 'auto';
    }

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

    try {
      const response = await fetch(`${OPENROUTER_BASE_URL}/chat/completions`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
          'HTTP-Referer': 'com.deenaik.jarvis',
          'X-Title': 'Jarvis for Mac',
        },
        body: JSON.stringify(body),
        signal: controller.signal,
      });

      if (!response.ok) {
        const errorBody = (await response.json().catch(() => ({}))) as OpenRouterError;
        throw new Error(
          `OpenRouter API error (${response.status}): ${errorBody.error?.message ?? 'Unknown error'}`
        );
      }

      return (await response.json()) as OpenRouterResponse;
    } catch (error) {
      if (error instanceof Error && error.name === 'AbortError') {
        throw new Error(`OpenRouter request timed out after ${REQUEST_TIMEOUT_MS}ms`);
      }
      throw error;
    } finally {
      clearTimeout(timeoutId);
    }
  }
}

export const openRouterClient = new OpenRouterClient();
