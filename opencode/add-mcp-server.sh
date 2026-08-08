#!/usr/bin/env bash
set -euo pipefail

add_mcp_server() {
  local name="$1"
  local url="$2"
  local transport="${3:-http}"
  local auth_header="${4:-}"

  echo "Adding MCP server ${name} (${transport}) -> ${url}"

  mkdir -p "${HOME}/.opencode" "${HOME}/.local/share/opencode"
  local config="${HOME}/.opencode/opencode.jsonc"

  node - "$name" "$url" "$transport" "$auth_header" "$config" <<'JS'
const fs = require('fs');
const [name, url, transport, authHeader, configPath] = process.argv.slice(2);

const cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));

const mcpEntry = {
  type: transport === 'stdio' ? 'local' : 'remote',
  enabled: true,
};

if (transport === 'stdio') {
  mcpEntry.command = url.split(' ');
} else {
  mcpEntry.url = url;
}

if (authHeader) {
  const idx = authHeader.indexOf(':');
  if (idx > 0) {
    const key = authHeader.slice(0, idx).trim();
    const value = authHeader.slice(idx + 1).trim();
    mcpEntry.headers = { [key]: value };
  }
}

if (!cfg.mcp) cfg.mcp = {};
cfg.mcp[name] = mcpEntry;

fs.writeFileSync(configPath, JSON.stringify(cfg, null, 2) + '\n');
JS

  echo "OK: MCP server ${name} added to ${config}"
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
