#!/bin/bash

# Mail Server Setup Script
# Run after deployment

echo "Setting up Mailu email server..."

# Generate secret key if not set
if grep -q "change-this-secret-key" mailu.env; then
    SECRET=$(openssl rand -hex 32)
    sed -i "s/change-this-secret-key-32-chars-long/$SECRET/g" mailu.env
    echo "Generated new SECRET_KEY"
fi

# Check if domains are configured
if grep -q "^DOMAINS=" mailu.env; then
    echo "Additional domains configured"
else
    echo "No additional domains configured yet"
    echo "Edit mailu.env and add: DOMAINS=domain1.com,domain2.com"
fi

echo ""
echo "Setup complete! Next steps:"
echo "1. Update DNS records for your domain(s)"
echo "2. Access admin panel at https://mail.kayorama.nl/admin"
echo "3. Login with: admin@kayorama.nl / your-password"
echo "4. Add domains and users in admin panel"
echo ""
echo "DNS Records needed:"
echo "  mail.kayorama.nl A YOUR_SERVER_IP"
echo "  kayorama.nl MX 10 mail.kayorama.nl"
echo "  kayorama.nl TXT \"v=spf1 mx a:mail.kayorama.nl -all\""
echo "  _dmarc TXT \"v=DMARC1; p=quarantine; rua=mailto:admin@kayorama.nl\""
