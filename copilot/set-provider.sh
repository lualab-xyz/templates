#!/usr/bin/env bash
set -euo pipefail

BASE_URL="$1"
MODEL_NAME="$2"
API_KEY="$3"
PROVIDER_NAME="$4"
PROVIDER_TYPE="${5:-openai}"

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

update_or_set "COPILOT_MODEL" "$MODEL_NAME"
update_or_set "COPILOT_PROVIDER_TYPE" "$PROVIDER_TYPE"

echo "Copilot model preference updated to ${MODEL_NAME} (providerType=${PROVIDER_TYPE})."
echo "Note: GitHub Copilot requires GitHub authentication; custom baseUrl/apiKey are not supported by this CLI."
