FROM ubuntu:24.04

ENV TERM=tmux-256color
ENV LANG=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    curl nodejs npm nano git sudo ca-certificates gnupg tmux \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g opencode-ai

# ttyd - terminal web (static binary)
RUN curl -fsSL "https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64" \
    -o /usr/local/bin/ttyd && chmod +x /usr/local/bin/ttyd

RUN mkdir -p /root/.opencode /root/.local/share/opencode

# Self-contained runtime config
COPY files/root/.opencode/opencode.jsonc /root/.opencode/opencode.jsonc
COPY files/root/.opencode/tui.json /root/.opencode/tui.json
COPY files/root/.local/share/opencode/auth.json /root/.local/share/opencode/auth.json
COPY defaults.env /opt/defaults.env
RUN cat > /root/.tmux.conf <<'EOF'
set -g default-terminal "tmux-256color"
set -as terminal-features ",xterm-256color:RGB"
set -g status off
set -g pane-border-status off
set -g pane-border-format ""
set -g mouse off
EOF

WORKDIR /workspace

COPY entrypoint.sh /usr/local/bin/opencode-entrypoint
RUN chmod +x /usr/local/bin/opencode-entrypoint

ENTRYPOINT ["/usr/local/bin/opencode-entrypoint"]
