export interface ToolDefinition {
  name: string;
  description: string;
  parameters: {
    type: 'object';
    properties: Record<string, {
      type: string;
      description: string;
      enum?: string[];
      default?: unknown;
    }>;
    required?: string[];
  };
}

export interface Tool {
  definition: ToolDefinition;
  execute(args: Record<string, unknown>): Promise<string>;
}
