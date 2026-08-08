#!/usr/bin/env bash
set -euo pipefail

add_mcp_server() {
  local name="$1"
  local url="$2"
  local transport="${3:-http}"
  local auth_header="${4:-}"

  echo "Adding MCP server ${name} (${transport}) -> ${url}"

  local args=()
  if [ -n "$auth_header" ]; then
    args+=(--header "$auth_header")
  fi
  args+=(--transport "$transport" "$name" "$url")

  if ! copilot mcp add "${args[@]}"; then
    echo "ERROR: failed to add MCP server ${name}" >&2
    return 1
  fi

  echo "OK: MCP server ${name} added"
}

if [ "$#" -lt 2 ]; then
  echo "ERROR: missing arguments" >&2
  echo "Usage: $0 \$name \$url [\$transport] [\$authHeader]" >&2
  exit 1
fi

if ! add_mcp_server "$@"; then
  echo "ERROR: failed to add MCP server" >&2
  exit 1
fi
