#!/usr/bin/env bash
set -euo pipefail

DEFAULTS_FILE="/opt/defaults.env"
if [ -f "$DEFAULTS_FILE" ]; then
  # shellcheck disable=SC1091
  set -a
  . "$DEFAULTS_FILE"
  set +a
fi

PID_FILE="/var/run/start-agent.pid"
TERMINAL_PORT="${TERMINAL_PORT:-${CODEPODS_TERMINAL_PORT:-7681}}"
if [ -z "$TERMINAL_PORT" ]; then
  echo "ERROR: Terminal port not configured. Please set CODEPODS_TERMINAL_PORT." >&2
  exit 1
fi

FONT_OPTION="fontSize=${TERM_FONT_SIZE:-14}"

# Mark this invocation as the current owner
echo "$$" > "$PID_FILE"

TMUX_CMD=(tmux new-session -A -s main "cd /workspace && exec claude")
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
    echo "ERROR: no services started" >&2
    return 1
  fi
  echo "OK: agent services started"
  wait -n "${pids[@]}"
}

cd /workspace

while true; do
  start_services || {
    echo "ERROR: service loop failed; retrying in 2s..." >&2
    sleep 2
    continue
  }
  if $stop; then
    break
  fi
  sleep 1
done

cleanup
rm -f "$PID_FILE"
