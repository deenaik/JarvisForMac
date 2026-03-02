import { openRouterClient } from './openrouter-client.js';
import { toolRegistry } from './tool-registry.js';
import { conversationManager } from './conversation-manager.js';
import { MAX_AGENT_STEPS } from '../config/jarvis.js';
import { getModelForTask } from '../config/openrouter.js';
import type { OpenRouterMessage, OpenRouterToolCall } from '../models/OpenRouterTypes.js';
import type { AgentStep, AgentResponse, ToolCall, ToolResult, ProgressCallback } from '../models/AgentTypes.js';

/**
 * Core ReAct agent loop:
 *   1. Send messages + tools to LLM
 *   2. If LLM returns tool_calls -> execute tools -> add results -> loop
 *   3. If LLM returns text (no tool_calls) -> return response (done)
 */
export async function runAgentLoop(userMessage: string, onProgress?: ProgressCallback): Promise<AgentResponse> {
  // Add user message to conversation
  conversationManager.addMessage({ role: 'user', content: userMessage });

  const tools = toolRegistry.toOpenRouterTools();
  const steps: AgentStep[] = [];
  let stepCount = 0;

  while (stepCount < MAX_AGENT_STEPS) {
    stepCount++;

    // Select model based on step count (use stronger model if we're deep in reasoning)
    const model = getModelForTask(stepCount > 10 ? 'complex' : 'simple');

    const response = await openRouterClient.chatCompletionWithTools(
      conversationManager.getMessages(),
      tools,
      { model }
    );

    const choice = response.choices?.[0];
    if (!choice) {
      throw new Error('No response choice from OpenRouter');
    }

    const assistantMessage = choice.message;
    const toolCalls = assistantMessage.tool_calls;

    // Add assistant message to conversation
    const msg: OpenRouterMessage = {
      role: 'assistant',
      content: assistantMessage.content,
    };
    if (toolCalls && toolCalls.length > 0) {
      msg.tool_calls = toolCalls;
    }
    conversationManager.addMessage(msg);

    // If no tool calls, we're done
    if (!toolCalls || toolCalls.length === 0) {
      return {
        text: assistantMessage.content ?? '(no response)',
        steps,
        totalSteps: stepCount,
      };
    }

    // Execute tool calls
    const step = await executeToolCalls(stepCount, toolCalls, onProgress);
    steps.push(step);

    // Add tool results to conversation
    for (const result of step.toolResults) {
      conversationManager.addMessage({
        role: 'tool',
        content: result.output,
        tool_call_id: result.toolCallId,
      });
    }

    // Log progress
    for (const result of step.toolResults) {
      const status = result.isError ? '✗' : '✓';
      console.log(`  ${status} ${result.name}`);
    }
  }

  // Hit max steps - return what we have
  return {
    text: `I reached the maximum number of steps (${MAX_AGENT_STEPS}) while working on your request. Here's what I accomplished so far.`,
    steps,
    totalSteps: stepCount,
  };
}

async function executeToolCalls(
  stepNumber: number,
  toolCalls: OpenRouterToolCall[],
  onProgress?: ProgressCallback
): Promise<AgentStep> {
  const parsedCalls: ToolCall[] = [];
  const results: ToolResult[] = [];

  for (const tc of toolCalls) {
    let args: Record<string, unknown>;
    try {
      args = JSON.parse(tc.function.arguments);
    } catch {
      args = {};
    }

    const call: ToolCall = {
      id: tc.id,
      name: tc.function.name,
      arguments: args,
    };
    parsedCalls.push(call);

    onProgress?.({ type: 'tool_start', toolName: tc.function.name, step: stepNumber });

    const { output, isError } = await toolRegistry.execute(tc.function.name, args);
    results.push({
      toolCallId: tc.id,
      name: tc.function.name,
      output,
      isError,
    });

    onProgress?.({ type: 'tool_result', toolName: tc.function.name, step: stepNumber, success: !isError });
  }

  return {
    step: stepNumber,
    toolCalls: parsedCalls,
    toolResults: results,
    assistantMessage: null,
  };
}
