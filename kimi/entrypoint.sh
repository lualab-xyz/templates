#!/usr/bin/env bash
set -euo pipefail
# Keep the container alive; services are started via the start_agent command.
exec tail -f /dev/null
