#!/bin/bash

# Auto-configure Mailu on first run
# This script generates secrets and configures the server

CONFIG_FILE="/data/.mailu-configured"

# Only run once
if [ -f "$CONFIG_FILE" ]; then
    echo "Mailu already configured, starting..."
    exit 0
fi

echo "🔧 First-time setup for Mailu..."

# Generate secret key if not set
if [ -z "$SECRET_KEY" ]; then
    export SECRET_KEY=$(openssl rand -hex 32)
    echo "Generated SECRET_KEY"
fi

# Set default admin password if not set
if [ -z "$ADMIN_PASSWORD" ]; then
    export ADMIN_PASSWORD=$(openssl rand -base64 16)
    echo "Generated admin password: $ADMIN_PASSWORD"
    echo "⚠️  IMPORTANT: Save this password!"
fi

# Create marker file
touch "$CONFIG_FILE"

echo "✅ Configuration complete"
echo ""
echo "📧 Mail server: $HOSTNAMES"
echo "🔑 Admin: admin@$DOMAIN"
echo "🔒 Password: $ADMIN_PASSWORD"
