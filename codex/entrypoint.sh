#!/usr/bin/env bash
set -euo pipefail

DEFAULTS_FILE="/opt/defaults.env"
if [ -f "$DEFAULTS_FILE" ]; then
  # shellcheck disable=SC1091
  . "$DEFAULTS_FILE"
fi

TERMINAL_PORT="${TERMINAL_PORT:-${CODEPODS_TERMINAL_PORT:-7681}}"
if [ -z "$TERMINAL_PORT" ]; then
  echo "Terminal port not configured. Please set CODEPODS_TERMINAL_PORT." >&2
  exit 1
fi

FONT_OPTION="fontSize=${TERM_FONT_SIZE:-14}"
TMUX_CMD=(tmux new-session -A -s main "cd /workspace && exec codex resume --all")
cd /workspace

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

trap 'stop=true; cleanup' INT TERM

start_services() {
  cleanup
  start_ttyd
  if [ "${#pids[@]}" -eq 0 ]; then
    return
  fi
  wait -n "${pids[@]}"
}

while true; do
  start_services
  if $stop; then
    break
  fi
  sleep 1
done

cleanup
