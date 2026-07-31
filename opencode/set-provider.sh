#!/usr/bin/env bash
set -euo pipefail

set_provider() {
  BASE_URL="$1"
  MODEL_NAME="$2"
  API_KEY="$3"
  PROVIDER_NAME="$4"
  PROVIDER_TYPE="${5:-openai}"

  mkdir -p /root/.opencode /root/.local/share/opencode

  CONFIG_PATH='/root/.opencode/opencode.jsonc'
  AUTH_PATH='/root/.local/share/opencode/auth.json'

  node - "$BASE_URL" "$MODEL_NAME" "$API_KEY" "$PROVIDER_NAME" "$PROVIDER_TYPE" "$CONFIG_PATH" "$AUTH_PATH" <<'JS'
const fs = require('fs');
const [baseUrl, modelName, apiKey, providerName, _providerType, configPath, authPath] = process.argv.slice(2);

const cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));
cfg.model = `${providerName}/${modelName}`;
cfg.provider = {
  [providerName]: {
    options: {
      baseURL: baseUrl,
      resourceName: 'docker-host',
    },
    models: {
      [modelName]: { name: modelName },
    },
  },
};
fs.writeFileSync(configPath, JSON.stringify(cfg, null, 2) + '\n');

const auth = { [providerName]: { type: 'api', key: apiKey } };
fs.writeFileSync(authPath, JSON.stringify(auth, null, 2) + '\n');
JS

  echo "OK: OpenCode provider set to ${PROVIDER_NAME}/${MODEL_NAME} via ${BASE_URL}"
}

if ! set_provider "$@"; then
  echo "ERROR: failed to set OpenCode provider" >&2
  exit 1
fi
