import type { Tool, ToolDefinition } from '../models/ToolTypes.js';
import type { OpenRouterToolDefinition } from '../models/OpenRouterTypes.js';
import { TOOL_TIMEOUT_MS } from '../config/jarvis.js';

export class ToolRegistry {
  private tools = new Map<string, Tool>();

  register(tool: Tool): void {
    if (this.tools.has(tool.definition.name)) {
      console.warn(`Tool "${tool.definition.name}" already registered, overwriting.`);
    }
    this.tools.set(tool.definition.name, tool);
  }

  get(name: string): Tool | undefined {
    return this.tools.get(name);
  }

  listDefinitions(): ToolDefinition[] {
    return Array.from(this.tools.values()).map((t) => t.definition);
  }

  /**
   * Convert all registered tools to OpenRouter function calling format.
   */
  toOpenRouterTools(): OpenRouterToolDefinition[] {
    return Array.from(this.tools.values()).map((tool) => ({
      type: 'function' as const,
      function: {
        name: tool.definition.name,
        description: tool.definition.description,
        parameters: tool.definition.parameters,
      },
    }));
  }

  /**
   * Execute a tool by name with timeout protection.
   */
  async execute(
    name: string,
    args: Record<string, unknown>
  ): Promise<{ output: string; isError: boolean }> {
    const tool = this.tools.get(name);
    if (!tool) {
      return { output: `Unknown tool: ${name}`, isError: true };
    }

    try {
      const result = await Promise.race([
        tool.execute(args),
        new Promise<never>((_, reject) =>
          setTimeout(() => reject(new Error(`Tool "${name}" timed out after ${TOOL_TIMEOUT_MS}ms`)), TOOL_TIMEOUT_MS)
        ),
      ]);
      return { output: result, isError: false };
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      return { output: `Error executing ${name}: ${message}`, isError: true };
    }
  }
}

export const toolRegistry = new ToolRegistry();
