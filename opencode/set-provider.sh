#!/usr/bin/env bash
set -euo pipefail

BASE_URL="$1"
MODEL_NAME="$2"
API_KEY="$3"
PROVIDER_NAME="$4"
PROVIDER_TYPE="${5:-openai}"

mkdir -p /root/.opencode /root/.local/share/opencode

python3 - "$BASE_URL" "$MODEL_NAME" "$API_KEY" "$PROVIDER_NAME" "$PROVIDER_TYPE" <<'PY'
import json, sys

base_url, model_name, api_key, provider_name, _provider_type = sys.argv[1:6]

config_path = '/root/.opencode/opencode.jsonc'
with open(config_path, 'r') as f:
    cfg = json.load(f)

cfg['model'] = f'{provider_name}/{model_name}'
cfg['provider'] = {
    provider_name: {
        'options': {
            'baseURL': base_url,
            'resourceName': 'docker-host',
        },
        'models': {
            model_name: {
                'name': model_name,
            }
        }
    }
}

with open(config_path, 'w') as f:
    json.dump(cfg, f, indent=2)
    f.write('\n')

auth_path = '/root/.local/share/opencode/auth.json'
with open(auth_path, 'w') as f:
    json.dump({provider_name: {'type': 'api', 'key': api_key}}, f, indent=2)
    f.write('\n')
PY

echo "OpenCode provider set to ${PROVIDER_NAME}/${MODEL_NAME} via ${BASE_URL}"
