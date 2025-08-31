FROM lscr.io/linuxserver/wireguard:latest

# Install Node.js, npm, ttyd and Claude Code
RUN apk add --no-cache nodejs npm curl bash git && \
    curl -L https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.x86_64 -o /usr/local/bin/ttyd && \
    chmod +x /usr/local/bin/ttyd && \
    npm install -g @anthropic-ai/claude-code

# Create WireGuard config directory
RUN mkdir -p /config/wg_confs

# Copy WireGuard configuration from project root
COPY wireguard.conf /config/wg_confs/wg0.conf

# Set proper permission
RUN chmod +r /config/wg_confs/wg0.conf

# Create custom service directories for s6-overlay (only ttyd now)
RUN mkdir -p /etc/s6-overlay/s6-rc.d/ttyd/dependencies.d && \
    touch /etc/s6-overlay/s6-rc.d/ttyd/dependencies.d/init-services && \
    echo "longrun" > /etc/s6-overlay/s6-rc.d/ttyd/type

# Copy service run script (only ttyd)
COPY ttyd-run.sh /etc/s6-overlay/s6-rc.d/ttyd/run
RUN chmod +x /etc/s6-overlay/s6-rc.d/ttyd/run

# Add service to user bundle (only ttyd)
RUN mkdir -p /etc/s6-overlay/s6-rc.d/user/contents.d && \
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/ttyd

# Copy startup script
COPY start.sh /custom-cont-init.d/99-start.sh
RUN chmod +x /custom-cont-init.d/99-start.sh

EXPOSE 7681

ENTRYPOINT ["/init"]