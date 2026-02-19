"""AI Agent Tool-Calling Framework.

Provides a registry of tools the AI can invoke during conversations.
Tools are read-only functions that query JARVIS data — no write operations.

Usage:
    from ai_agent.tools import tool_registry

    # Get all tool schemas for LLM
    schemas = tool_registry.get_schemas()

    # Execute a tool call
    result = tool_registry.execute('search_invoices', {'supplier': 'Google'}, user_id=1)
"""

from .registry import ToolRegistry, tool_registry

__all__ = ['ToolRegistry', 'tool_registry']
