#!/usr/bin/with-contenv bash

# Check if WireGuard config was copied successfully
if [ -f /config/wg_confs/wg0.conf ]; then
    echo "✓ WireGuard configuration found"
    echo "  Config: /config/wg_confs/wg0.conf"
    echo ""
else
    echo "⚠️  ERROR: WireGuard configuration not found!"
    echo ""
    echo "Please ensure 'wireguard.conf' exists in your project root"
    echo "The Docker build should copy it automatically"
    echo ""
fi

# Display service information
echo "Services:"
echo "  • Astro Dev Page:  http://localhost:4321"
echo "  • Terminal: http://localhost:7681"
echo ""

# Check if WireGuard is connected (after a short delay for startup)
sleep 8
if wg show wg0 &>/dev/null; then
    echo "✓ WireGuard VPN connected"
    echo "  Interface: wg0"
    wg show wg0 | grep -E "peer:|endpoint:|latest handshake:" | head -3
    
    # Show external IP
    EXTERNAL_IP=$(curl -s --max-time 5 https://ipinfo.io/ip 2>/dev/null)
    if [ ! -z "$EXTERNAL_IP" ]; then
        echo "  External IP: $EXTERNAL_IP"
    fi
else
    echo "⚠ WireGuard VPN not connected"
    echo "  Check logs: docker logs claude-dev"
fi