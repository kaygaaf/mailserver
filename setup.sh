#!/bin/bash

# Mailu Setup Script
# Run after deployment to configure initial settings

set -e

echo "=========================================="
echo "  Mailu Email Server Setup"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

# Generate secret key if not changed
if grep -q "change-this-to-64-char-hex-string" mailu.env; then
    echo "🔑 Generating secret key..."
    SECRET=$(openssl rand -hex 32)
    sed -i "s/change-this-to-64-char-hex-string-from-openssl-rand-hex-32/$SECRET/g" mailu.env
    echo "✅ Secret key generated"
else
    echo "✅ Secret key already set"
fi

# Check domain configuration
DOMAIN=$(grep "^DOMAIN=" mailu.env | cut -d'=' -f2)
HOSTNAMES=$(grep "^HOSTNAMES=" mailu.env | cut -d'=' -f2)

echo ""
echo "📧 Domain Configuration:"
echo "   Main Domain: $DOMAIN"
echo "   Hostname: $HOSTNAMES"
echo ""

# Get server IP
SERVER_IP=$(curl -s ifconfig.me || echo "YOUR_SERVER_IP")
echo "🌐 Server IP: $SERVER_IP"
echo ""

# Display DNS records
echo "=========================================="
echo "  Required DNS Records"
echo "=========================================="
echo ""
echo "1. A Record:"
echo "   $HOSTNAMES    A    $SERVER_IP"
echo ""
echo "2. MX Record:"
echo "   $DOMAIN         MX    10 $HOSTNAMES"
echo ""
echo "3. SPF Record:"
echo "   $DOMAIN         TXT   \"v=spf1 mx a:$HOSTNAMES -all\""
echo ""
echo "4. DMARC Record:"
echo "   _dmarc.$DOMAIN  TXT   \"v=DMARC1; p=quarantine; rua=mailto:admin@$DOMAIN\""
echo ""
echo "5. Reverse DNS (PTR):"
echo "   Contact your VPS provider to set:"
echo "   $SERVER_IP → $HOSTNAMES"
echo ""
echo "6. DKIM Record: (Generate after setup in admin panel)"
echo "   mail._domainkey.$DOMAIN  TXT  \"v=DKIM1; ...\""
echo ""

# Check if ports are available
echo "=========================================="
echo "  Port Availability Check"
echo "=========================================="
echo ""

PORTS="25 465 587 110 995 143 993 80 443"
for PORT in $PORTS; do
    if ss -tlnp | grep -q ":$PORT "; then
        echo "⚠️  Port $PORT is already in use"
    else
        echo "✅ Port $PORT is available"
    fi
done

echo ""
echo "=========================================="
echo "  Next Steps"
echo "=========================================="
echo ""
echo "1. Add the DNS records shown above"
echo "2. Wait for DNS propagation (5-30 minutes)"
echo "3. Deploy in Coolify"
echo "4. Access admin panel: https://$HOSTNAMES/admin"
echo "5. Login with: admin@$DOMAIN"
echo "6. Generate DKIM keys and add DNS record"
echo "7. Create users and aliases"
echo ""
echo "📖 Full documentation: https://mailu.io/"
echo ""

# Ask if user wants to start the server
read -p "Do you want to start the mail server now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Starting Mailu..."
    docker-compose up -d
    echo ""
    echo "✅ Mailu is starting up!"
    echo "   Webmail: https://$HOSTNAMES/webmail"
    echo "   Admin: https://$HOSTNAMES/admin"
    echo ""
    echo "⏳ Wait 2-3 minutes for all services to start"
    echo "🔍 Check status: docker-compose ps"
fi
