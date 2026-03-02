// Phase 2: MCP Client Manager
// TODO: Connect to MCP servers using @modelcontextprotocol/sdk
// - MCPManager class with Client + StdioClientTransport
// - Connect to configured servers on startup
// - Discover and register tools from each server
// - Handle server lifecycle (start, reconnect, shutdown)

import type { MCPServerConfig } from '../config/mcp.js';

export class MCPManager {
  private _servers: MCPServerConfig[] = [];

  async connectAll(_configs: MCPServerConfig[]): Promise<void> {
    // TODO: For each config, spawn process and connect via StdioClientTransport
    throw new Error('MCP client not implemented yet (Phase 2)');
  }

  async disconnectAll(): Promise<void> {
    // TODO: Gracefully close all MCP server connections
  }

  getAvailableTools(): Array<{ server: string; name: string; description: string }> {
    // TODO: Return all tools from all connected MCP servers
    return [];
  }
}

export const mcpManager = new MCPManager();
