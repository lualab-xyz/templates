#!/usr/bin/env bash
set -euo pipefail

BASE_URL="$1"
MODEL_NAME="$2"
API_KEY="$3"
PROVIDER_NAME="$4"
PROVIDER_TYPE="${5:-openai}"
RESTART="${6:-false}"

case "$PROVIDER_TYPE" in
  openai|openai_completions) API="openai-completions" ;;
  responses|openai_responses) API="openai-responses" ;;
  chatgpt|openai_chatgpt) API="openai-chatgpt-responses" ;;
  anthropic|claude) API="anthropic-messages" ;;
  google|gemini) API="google-generative-ai" ;;
  vertex) API="google-vertex" ;;
  azure) API="azure-openai-responses" ;;
  github) API="github-copilot" ;;
  bedrock) API="bedrock-converse-stream" ;;
  ollama) API="ollama" ;;
  *) API="openai-completions" ;;
esac

python3 - "$BASE_URL" "$MODEL_NAME" "$API_KEY" "$PROVIDER_NAME" "$API" <<'PY'
import json, subprocess, sys

base_url, model_name, api_key, provider_name, api = sys.argv[1:6]

config_path = '/root/.openclaw/openclaw.json'
with open(config_path, 'r') as f:
    cfg = json.load(f)

old_providers = list(cfg.get('models', {}).get('providers', {}).keys())

patch = {
    "models": {
        "mode": "replace",
        "providers": {}
    }
}

for p in old_providers:
    patch["models"]["providers"][p] = None

patch["models"]["providers"][provider_name] = {
    "baseUrl": base_url,
    "apiKey": api_key,
    "auth": "api-key",
    "api": api,
    "models": [
        {
            "id": model_name,
            "name": model_name,
            "api": api,
            "baseUrl": base_url,
        }
    ]
}

subprocess.run(
    ['openclaw', 'config', 'patch', '--stdin'],
    input=json.dumps(patch),
    text=True,
    check=True,
)
PY

openclaw models set "${PROVIDER_NAME}/${MODEL_NAME}"

echo "OpenClaw provider set to ${PROVIDER_NAME}/${MODEL_NAME} (${API}) via ${BASE_URL}"

if [ "$RESTART" = "true" ]; then
  echo "Restart requested: killing tmux session 'main' to recreate with new provider"
  tmux kill-session -t main >/dev/null 2>&1 || true
fi
