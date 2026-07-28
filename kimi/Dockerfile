FROM ubuntu:24.04

ENV TERM=tmux-256color
ENV LANG=en_US.UTF-8
ENV PATH="/root/.local/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    curl nano git sudo ca-certificates gnupg tmux \
    && rm -rf /var/lib/apt/lists/* \
    && curl -LsSf https://code.kimi.com/install.sh | bash \
    && ln -sf /root/.local/share/uv/python/cpython-3.13.14-linux-x86_64-gnu/bin/python3 /usr/local/bin/python3

# ttyd — terminal web (binario estático)
RUN curl -fsSL "https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64" \
    -o /usr/local/bin/ttyd && chmod +x /usr/local/bin/ttyd

COPY files/root/.tmux.conf /root/.tmux.conf

WORKDIR /workspace

COPY defaults.env /opt/defaults.env
COPY entrypoint.sh /usr/local/bin/kimi-entrypoint
COPY set-provider.sh /usr/local/bin/set-provider.sh
COPY start-agent.sh /usr/local/bin/start-agent.sh
RUN chmod +x /usr/local/bin/kimi-entrypoint /usr/local/bin/set-provider.sh /usr/local/bin/start-agent.sh

ENTRYPOINT ["/usr/local/bin/kimi-entrypoint"]