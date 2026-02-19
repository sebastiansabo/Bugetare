"""Tool Registry — central registration and execution of AI tools.

Each tool has:
- name: unique identifier (used in LLM tool_use)
- description: what the tool does (shown to LLM)
- input_schema: JSON Schema for parameters
- handler: Python callable(params, user_id) -> dict
- permission: optional permission key required to use the tool
"""

import logging
from typing import Callable, Dict, Any, List, Optional

logger = logging.getLogger('jarvis.ai_agent.tools')


class Tool:
    """A single tool that the AI can invoke."""

    __slots__ = ('name', 'description', 'input_schema', 'handler', 'permission')

    def __init__(
        self,
        name: str,
        description: str,
        input_schema: dict,
        handler: Callable[[dict, int], dict],
        permission: Optional[str] = None,
    ):
        self.name = name
        self.description = description
        self.input_schema = input_schema
        self.handler = handler
        self.permission = permission


class ToolRegistry:
    """Registry of available AI tools."""

    def __init__(self):
        self._tools: Dict[str, Tool] = {}

    def register(
        self,
        name: str,
        description: str,
        input_schema: dict,
        handler: Callable[[dict, int], dict],
        permission: Optional[str] = None,
    ):
        """Register a tool."""
        self._tools[name] = Tool(
            name=name,
            description=description,
            input_schema=input_schema,
            handler=handler,
            permission=permission,
        )

    def get_schemas(self, user_permissions: Optional[set] = None) -> List[dict]:
        """Get tool schemas formatted for Claude/OpenAI tool_use.

        Args:
            user_permissions: set of permission keys the user has.
                If None, returns all tools (no filtering).

        Returns:
            List of tool schema dicts ready for the LLM API.
        """
        schemas = []
        for tool in self._tools.values():
            if tool.permission and user_permissions is not None:
                if tool.permission not in user_permissions:
                    continue
            schemas.append({
                'name': tool.name,
                'description': tool.description,
                'input_schema': tool.input_schema,
            })
        return schemas

    def execute(
        self,
        name: str,
        params: dict,
        user_id: int,
        user_permissions: Optional[set] = None,
    ) -> dict:
        """Execute a tool by name.

        Args:
            name: Tool name
            params: Tool parameters from LLM
            user_id: ID of the user making the request
            user_permissions: set of permission keys for access control

        Returns:
            dict with tool result or error

        Raises:
            ValueError: If tool not found
            PermissionError: If user lacks required permission
        """
        tool = self._tools.get(name)
        if not tool:
            return {'error': f'Unknown tool: {name}'}

        if tool.permission and user_permissions is not None:
            if tool.permission not in user_permissions:
                return {'error': f'Permission denied: {tool.permission} required'}

        try:
            result = tool.handler(params, user_id)
            logger.info(f"Tool '{name}' executed by user {user_id}")
            return result
        except Exception as e:
            logger.error(f"Tool '{name}' failed: {e}")
            return {'error': f'Tool execution failed: {str(e)}'}

    def has_tool(self, name: str) -> bool:
        return name in self._tools

    @property
    def tool_count(self) -> int:
        return len(self._tools)


# Global registry instance
tool_registry = ToolRegistry()


def _register_all_tools():
    """Register all built-in tools. Called on first import."""
    from . import definitions  # noqa: F401


_register_all_tools()
