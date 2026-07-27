FROM ubuntu:24.04

ENV TERM=tmux-256color
ENV LANG=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    curl nodejs npm nano git sudo ca-certificates gnupg tmux \
    && npm install -g @github/copilot \
    && rm -rf /var/lib/apt/lists/*

# ttyd — terminal web (binario estático)
RUN curl -fsSL "https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64" \
    -o /usr/local/bin/ttyd && chmod +x /usr/local/bin/ttyd

COPY files/root/.tmux.conf /root/.tmux.conf

WORKDIR /workspace

COPY defaults.env /opt/defaults.env
COPY entrypoint.sh /usr/local/bin/copilot-entrypoint
RUN chmod +x /usr/local/bin/copilot-entrypoint

ENTRYPOINT ["/usr/local/bin/copilot-entrypoint"]
