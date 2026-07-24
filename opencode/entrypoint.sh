#!/usr/bin/env bash
set -euo pipefail

DEFAULTS_FILE="/opt/defaults.env"
if [ -f "$DEFAULTS_FILE" ]; then
  # shellcheck disable=SC1091
  set -a
  . "$DEFAULTS_FILE"
  set +a
fi

TERMINAL_PORT="${TERMINAL_PORT:-${CODEPODS_TERMINAL_PORT:-7681}}"
WEB_PORT="${WEB_PORT:-${CODEPODS_WEB_PORT:-4096}}"
FONT_OPTION="fontSize=${TERM_FONT_SIZE:-14}"
TMUX_CMD=(tmux new-session -A -s main "cd /workspace && exec opencode")

pids=()
stop=false

cleanup() {
  for pid in "${pids[@]:-}"; do
    kill "$pid" >/dev/null 2>&1 || true
  done
  pids=()
}

start_ttyd() {
  echo "Starting ttyd on port $TERMINAL_PORT, attaching tmux session 'main'"
  /usr/local/bin/ttyd \
    --port "$TERMINAL_PORT" \
    --writable \
    --client-option disableLeaveAlert=true \
    --client-option "$FONT_OPTION" \
    "${TMUX_CMD[@]}" &
  pids+=("$!")
}

start_web() {
  if [ -z "$WEB_PORT" ]; then
    return
  fi
  echo "Starting OpenCode web on port $WEB_PORT"
  opencode web --port "$WEB_PORT" --hostname 0.0.0.0 >/tmp/opencode-web.log 2>&1 &
  pids+=("$!")
}

trap 'stop=true; cleanup' INT TERM

start_services() {
  cleanup
  start_ttyd
  start_web
  wait -n "${pids[@]}"
}

cd /workspace

while true; do
  start_services
  if $stop; then
    break
  fi
  sleep 1
done

cleanup
