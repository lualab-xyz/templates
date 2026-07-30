FROM ubuntu:24.04

ENV TERM=tmux-256color
ENV LANG=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    curl nano git sudo ca-certificates gnupg tmux python3 \
    && rm -rf /var/lib/apt/lists/*

# OpenCode binary (feat/base-path-support build)
COPY files/bin/opencode /usr/local/bin/opencode
RUN chmod +x /usr/local/bin/opencode

# ttyd - terminal web (static binary)
RUN curl -fsSL "https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64" \
    -o /usr/local/bin/ttyd && chmod +x /usr/local/bin/ttyd

RUN mkdir -p /root/.opencode /root/.local/share/opencode

# Self-contained runtime config
COPY files/root/.opencode/opencode.jsonc /root/.opencode/opencode.jsonc
COPY files/root/.opencode/tui.json /root/.opencode/tui.json
COPY files/root/.local/share/opencode/auth.json /root/.local/share/opencode/auth.json
COPY files/root/.tmux.conf /root/.tmux.conf
COPY defaults.env /opt/defaults.env

WORKDIR /workspace

COPY entrypoint.sh /usr/local/bin/opencode-entrypoint
COPY set-provider.sh /usr/local/bin/set-provider.sh
COPY start-agent.sh /usr/local/bin/start-agent.sh
COPY stop-agent.sh /usr/local/bin/stop-agent.sh
RUN chmod +x /usr/local/bin/opencode-entrypoint /usr/local/bin/set-provider.sh /usr/local/bin/start-agent.sh /usr/local/bin/stop-agent.sh

ENTRYPOINT ["/usr/local/bin/opencode-entrypoint"]
