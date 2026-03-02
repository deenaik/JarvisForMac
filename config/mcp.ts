// Phase 2: MCP server configuration
// TODO: Implement MCP server connections

export interface MCPServerConfig {
  name: string;
  command: string;
  args: string[];
  env?: Record<string, string>;
}

// MCP servers to connect to on startup
export const MCP_SERVERS: MCPServerConfig[] = [
  // Example:
  // {
  //   name: 'filesystem',
  //   command: 'npx',
  //   args: ['-y', '@modelcontextprotocol/server-filesystem', '/tmp'],
  // },
];
