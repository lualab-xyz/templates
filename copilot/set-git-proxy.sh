#!/usr/bin/env bash
set -euo pipefail

set_git_proxy() {
  local download_url="$1"
  local bin_path="/usr/local/bin/git"
  local backup_path="/usr/local/bin/git.original"

  echo "Installing git proxy from ${download_url}..."

  # If a real git binary exists, move it aside (do not uninstall packages to avoid breaking deps)
  if [ -f "$bin_path" ] && [ ! -L "$bin_path" ]; then
    echo "Backing up original git to ${backup_path}"
    mv "$bin_path" "$backup_path"
  fi

  # Download the fake-git proxy binary from the host
  if ! curl -fsSL "$download_url" -o "$bin_path"; then
    echo "ERROR: failed to download git proxy from ${download_url}" >&2
    return 1
  fi

  chmod +x "$bin_path"

  # Verify it is executable
  if ! "$bin_path" --version >/dev/null 2>&1; then
    echo "WARNING: git proxy does not respond to --version" >&2
  fi

  echo "OK: git proxy installed at ${bin_path}"
}

if [ "$#" -lt 1 ]; then
  echo "ERROR: missing download URL" >&2
  echo "Usage: $0 \$downloadUrl" >&2
  exit 1
fi

if ! set_git_proxy "$1"; then
  echo "ERROR: failed to install git proxy" >&2
  exit 1
fi
