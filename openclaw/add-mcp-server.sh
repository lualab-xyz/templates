#!/usr/bin/env bash
set -euo pipefail

add_mcp_server() {
  local name="$1"
  local url="$2"
  local transport="${3:-http}"
  local auth_header="${4:-}"

  echo "WARNING: OpenClaw does not support MCP servers natively; skipping ${name} (${transport}) -> ${url}" >&2
  return 0
}

if [ "$#" -lt 2 ]; then
  echo "ERROR: missing arguments" >&2
  echo "Usage: $0 \$name \$url [\$transport] [\$authHeader]" >&2
  exit 1
fi

add_mcp_server "$@"
echo "OK: no MCP server added (OpenClaw has no native MCP support)"
