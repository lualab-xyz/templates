FROM ubuntu:24.04

ENV TERM=tmux-256color
ENV LANG=en_US.UTF-8
ENV PATH="/root/.local/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    curl nodejs npm nano git sudo ca-certificates gnupg tmux \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL https://claude.ai/install.sh | bash

# ttyd — terminal web (binario estático)
RUN curl -fsSL "https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64" \
    -o /usr/local/bin/ttyd && chmod +x /usr/local/bin/ttyd

COPY files/root/.tmux.conf /root/.tmux.conf

WORKDIR /workspace

COPY defaults.env /opt/defaults.env
COPY entrypoint.sh /usr/local/bin/claude-entrypoint
COPY start-agent.sh /usr/local/bin/start-agent.sh
COPY set-provider.sh /usr/local/bin/set-provider.sh
COPY stop-agent.sh /usr/local/bin/stop-agent.sh
RUN chmod +x /usr/local/bin/claude-entrypoint /usr/local/bin/start-agent.sh /usr/local/bin/set-provider.sh /usr/local/bin/stop-agent.sh

ENTRYPOINT ["/usr/local/bin/claude-entrypoint"]