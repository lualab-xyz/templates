FROM ubuntu:24.04

ENV TERM=tmux-256color
ENV LANG=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    curl nano git sudo ca-certificates gnupg tmux \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24 (OpenClaw requires Node 22.22.3+)
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g openclaw@latest

# ttyd - terminal web (static binary)
RUN curl -fsSL "https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64" \
    -o /usr/local/bin/ttyd && chmod +x /usr/local/bin/ttyd

RUN mkdir -p /root/.openclaw
COPY files/root/.openclaw/openclaw.json /root/.openclaw/openclaw.json
COPY files/root/.tmux.conf /root/.tmux.conf
COPY defaults.env /opt/defaults.env

WORKDIR /workspace

COPY entrypoint.sh /usr/local/bin/openclaw-entrypoint
COPY set-provider.sh /usr/local/bin/set-provider.sh
COPY set-git-proxy.sh /usr/local/bin/set-git-proxy.sh
COPY start-agent.sh /usr/local/bin/start-agent.sh
COPY stop-agent.sh /usr/local/bin/stop-agent.sh
RUN chmod +x /usr/local/bin/openclaw-entrypoint /usr/local/bin/set-provider.sh /usr/local/bin/set-git-proxy.sh /usr/local/bin/start-agent.sh /usr/local/bin/stop-agent.sh

ENTRYPOINT ["/usr/local/bin/openclaw-entrypoint"]
