#!/usr/bin/env bash
set -euo pipefail

PID_FILE="/var/run/start-agent.pid"
STOPPED=0
FAILED=0

kill_if_alive() {
  local pid="$1"
  if [ -n "$pid" ] && [ -d "/proc/$pid" ]; then
    if kill -TERM "$pid" >/dev/null 2>&1; then
      STOPPED=$((STOPPED + 1))
    else
      FAILED=$((FAILED + 1))
    fi
  fi
}

kill_by_cmdline() {
  local sig="$1"
  for proc in /proc/[0-9]*; do
    if [ ! -d "$proc" ]; then continue; fi
    pid="$(basename "$proc")"
    if [ "$pid" = "$$" ] || [ "$pid" = "1" ]; then continue; fi
    cmdline="$(tr '\0' ' ' < "$proc/cmdline" 2>/dev/null || true)"
    if [[ "$cmdline" == *"start-agent.sh"* ]] || [[ "$cmdline" == *"ttyd --port"* ]] || [[ "$cmdline" == *"tmux new-session"* ]] || [[ "$cmdline" == *"opencode web"* ]] || [[ "$cmdline" == *"kimi web"* ]] || [[ "$cmdline" == *"openclaw gateway run"* ]]; then
      if kill -"$sig" "$pid" >/dev/null 2>&1; then
        STOPPED=$((STOPPED + 1))
      fi
    fi
  done
}

echo "Stopping agent services..."

if [ -f "$PID_FILE" ]; then
  old_pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  kill_if_alive "$old_pid"
  rm -f "$PID_FILE"
fi

# Kill any remaining known agent children by scanning /proc explicitly
kill_by_cmdline TERM

# Give processes a moment to exit cleanly
sleep 2

# Final cleanup of stragglers
kill_by_cmdline KILL

tmux kill-session -t main >/dev/null 2>&1 || true

if [ "$FAILED" -gt 0 ]; then
  echo "ERROR: failed to stop $FAILED agent process(es)"
  exit 1
fi

if [ "$STOPPED" -eq 0 ]; then
  echo "OK: no running agent services to stop"
else
  echo "OK: stopped $STOPPED agent process(es)"
fi
