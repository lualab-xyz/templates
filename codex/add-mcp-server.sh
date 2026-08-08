#!/usr/bin/env bash
set -euo pipefail

add_mcp_server() {
  local name="$1"
  local url="$2"
  local transport="${3:-http}"
  local auth_header="${4:-}"

  echo "Adding MCP server ${name} (${transport}) -> ${url}"

  mkdir -p "${HOME}/.codex"
  local config="${HOME}/.codex/config.toml"

  python3 - "$name" "$url" "$transport" "$auth_header" "$config" <<'PY'
import sys

def esc(s: str) -> str:
    return s.replace('\\', '\\\\').replace('"', '\\"').replace("'", "\\'")

name, url, transport, auth_header, config_path = sys.argv[1:6]

entry = f'''[mcp_servers."{esc(name)}"]
enabled = true
url = "{esc(url)}"
'''

if auth_header:
    key, _, value = auth_header.partition(':')
    if key and value is not None:
        entry += f'''[mcp_servers."{esc(name)}".http_headers]
{esc(key.strip())} = "{esc(value.strip())}"
'''

# Append or update the section in config.toml
lines = []
if __import__('os').path.exists(config_path):
    with open(config_path, 'r') as f:
        lines = f.readlines()

# Remove existing [mcp_servers.name] section
new_lines = []
skip = False
section_prefix = f'[mcp_servers."{name}"'
for line in lines:
    stripped = line.strip()
    if stripped.startswith(section_prefix):
        skip = True
        continue
    if skip and stripped.startswith('[') and not stripped.startswith(section_prefix):
        skip = False
    if not skip:
        new_lines.append(line)

# Ensure file ends with a newline
if new_lines and not new_lines[-1].endswith('\n'):
    new_lines.append('\n')

new_lines.append(entry)

with open(config_path, 'w') as f:
    f.writelines(new_lines)
PY

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
