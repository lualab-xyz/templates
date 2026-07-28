#!/usr/bin/env bash
set -euo pipefail

BASE_URL="$1"
MODEL_NAME="$2"
API_KEY="$3"
PROVIDER_NAME="$4"
PROVIDER_TYPE="${5:-openai}"
RESTART="${6:-false}"

DEFAULTS_FILE="/opt/defaults.env"
mkdir -p "$(dirname "$DEFAULTS_FILE")"

update_or_set() {
  local key="$1" value="$2"
  if [ -f "$DEFAULTS_FILE" ] && grep -q "^${key}=" "$DEFAULTS_FILE"; then
    sed -i "s#^${key}=.*#${key}=${value}#" "$DEFAULTS_FILE"
  else
    echo "${key}=${value}" >> "$DEFAULTS_FILE"
  fi
}

update_or_set "COPILOT_PROVIDER_TYPE" "$PROVIDER_TYPE"
update_or_set "COPILOT_PROVIDER_API_KEY" "$API_KEY"
update_or_set "COPILOT_PROVIDER_BASE_URL" "$BASE_URL"
update_or_set "COPILOT_PROVIDER_WIRE_API" "responses"
update_or_set "COPILOT_MODEL" "$MODEL_NAME"

echo "Copilot BYOK provider set to ${PROVIDER_NAME}/${MODEL_NAME} via ${BASE_URL}"

if [ "$RESTART" = "true" ]; then
  echo "Restart requested: killing tmux session 'main' to recreate with new provider"
  tmux kill-session -t main >/dev/null 2>&1 || true
fi
