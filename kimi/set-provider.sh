#!/usr/bin/env bash
set -euo pipefail

set_provider() {
  BASE_URL="$1"
  MODEL_NAME="$2"
  API_KEY="$3"
  PROVIDER_NAME="$4"
  PROVIDER_TYPE="${5:-openai}"

  case "$PROVIDER_TYPE" in
    openai) TYPE="openai_responses" ;;
    openai_legacy) TYPE="openai_legacy" ;;
    anthropic|claude) TYPE="anthropic" ;;
    google|gemini) TYPE="gemini" ;;
    kimi) TYPE="kimi" ;;
    vertex) TYPE="vertexai" ;;
    *) TYPE="openai_responses" ;;
  esac

  mkdir -p /root/.kimi

  PYTHON_BIN="${KIMI_PYTHON:-/root/.local/share/uv/python/cpython-3.13.14-linux-x86_64-gnu/bin/python3}"
  "$PYTHON_BIN" - "$BASE_URL" "$MODEL_NAME" "$API_KEY" "$PROVIDER_NAME" "$TYPE" <<'PY'
import sys

def esc(s: str) -> str:
    return s.replace('\\', '\\\\').replace('"', '\\"')

base_url, model_name, api_key, provider_name, type_ = sys.argv[1:6]
model_key = f'{provider_name}/{model_name}'

toml = f'''default_model = "{esc(model_key)}"

[providers."{esc(provider_name)}"]
type = "{esc(type_)}"
base_url = "{esc(base_url)}"
api_key = "{esc(api_key)}"

[models."{esc(model_key)}"]
provider = "{esc(provider_name)}"
model = "{esc(model_name)}"
max_context_size = 200000
'''

with open('/root/.kimi/config.toml', 'w') as f:
    f.write(toml)
PY

  echo "OK: Kimi provider set to ${PROVIDER_NAME}/${MODEL_NAME} (${TYPE}) via ${BASE_URL}"
}

if ! set_provider "$@"; then
  echo "ERROR: failed to set Kimi provider" >&2
  exit 1
fi
