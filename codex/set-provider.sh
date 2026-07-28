#!/usr/bin/env bash
set -euo pipefail

BASE_URL="$1"
MODEL_NAME="$2"
API_KEY="$3"
PROVIDER_NAME="$4"
PROVIDER_TYPE="${5:-openai}"
RESTART="${6:-false}"

mkdir -p /root/.codex

python3 - "$BASE_URL" "$MODEL_NAME" "$API_KEY" "$PROVIDER_NAME" "$PROVIDER_TYPE" <<'PY'
import sys

def esc(s: str) -> str:
    return s.replace('\\', '\\\\').replace('"', '\\"')

base_url, model_name, api_key, provider_name, provider_type = sys.argv[1:6]

toml = f'''model = "{esc(model_name)}"
model_provider = "{esc(provider_name)}"

[model_providers."{esc(provider_name)}"]
name = "{esc(provider_name)}"
base_url = "{esc(base_url)}"
api_key = "{esc(api_key)}"
deployment_id = "{esc(model_name)}"
wire_api = "responses"
'''

if provider_type == "azure":
    toml += 'query_params.api-version = "2025-04-01-preview"\n'

with open('/root/.codex/config.toml', 'w') as f:
    f.write(toml)
PY

echo "Codex provider set to ${PROVIDER_NAME}/${MODEL_NAME} via ${BASE_URL}"

if [ "$RESTART" = "true" ]; then
  echo "Restart requested: killing tmux session 'main' to recreate with new provider"
  tmux kill-session -t main >/dev/null 2>&1 || true
fi
