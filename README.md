# Mailu Email Server Setup Guide

Complete email server with webmail, multi-domain support, and mobile compatibility.

## Quick Start

### 1. Configure Environment

Edit `mailu.env`:

```bash
# Required changes:
DOMAIN=kayorama.nl                    # Your main domain
HOSTNAMES=mail.kayorama.nl            # Mail server hostname
INITIAL_ADMIN_PW=YourStrongPassword!  # Admin password
SECRET_KEY=$(openssl rand -hex 32)    # Generate secret key
```

### 2. DNS Records

Add these DNS records for each domain:

**A Record:**
```
mail.kayorama.nl    A     YOUR_SERVER_IP
```

**MX Record:**
```
kayorama.nl         MX    10 mail.kayorama.nl
```

**SPF (Sender Policy Framework):**
```
kayorama.nl         TXT   "v=spf1 mx a:mail.kayorama.nl -all"
```

**DMARC:**
```
_dmarc.kayorama.nl  TXT   "v=DMARC1; p=quarantine; rua=mailto:admin@kayorama.nl"
```

**DKIM:** (Generate after setup in admin panel)
```
mail._domainkey.kayorama.nl  TXT  "v=DKIM1; k=rsa; p=YOUR_PUBLIC_KEY"
```

**Reverse DNS (PTR):**
Contact your VPS provider to set PTR record:
```
YOUR_IP → mail.kayorama.nl
```

### 3. Deploy on Coolify

1. Create new project in Coolify
2. Add Docker Compose resource
3. Repository: `https://github.com/kaygaaf/mailserver`
4. Upload `docker-compose.yml` and `mailu.env`
5. Deploy

### 4. Access Services

- **Webmail:** https://mail.kayorama.nl/webmail
- **Admin Panel:** https://mail.kayorama.nl/admin
- **Default Login:** admin@kayorama.nl / YourPassword

## Mobile Setup

### iPhone/iPad (Apple Mail)

1. Settings → Mail → Accounts → Add Account → Other
2. Add Mail Account
3. **Name:** Your Name
4. **Email:** user@kayorama.nl
5. **Password:** YourPassword
6. **Description:** Kayorama Mail

**Incoming Mail Server:**
- Hostname: mail.kayorama.nl
- Username: user@kayorama.nl
- Password: YourPassword
- Port: 993 (SSL)

**Outgoing Mail Server:**
- Hostname: mail.kayorama.nl
- Username: user@kayorama.nl
- Password: YourPassword
- Port: 587 (STARTTLS) or 465 (SSL)

### Gmail (Android)

1. Gmail app → Add account → Other
2. Enter email: user@kayorama.nl
3. Choose **Personal (IMAP/POP)**
4. Password: YourPassword

**Incoming:**
- Server: mail.kayorama.nl
- Port: 993
- Security: SSL/TLS

**Outgoing:**
- Server: mail.kayorama.nl
- Port: 587
- Security: STARTTLS

### Outlook

1. File → Add Account → Manual setup
2. Choose **IMAP/POP**
3. **Incoming:**
   - Server: mail.kayorama.nl
   - Port: 993
   - Encryption: SSL/TLS
4. **Outgoing:**
   - Server: mail.kayorama.nl
   - Port: 587
   - Encryption: STARTTLS

## Adding Domains

1. Login to admin panel: https://mail.kayorama.nl/admin
2. Go to **Mail domains**
3. Click **Add domain**
4. Enter domain name
5. Add DNS records for new domain
6. Generate DKIM key in admin panel
7. Add DKIM TXT record to DNS

## Adding Users

1. Admin panel → Users
2. Click **Add user**
3. Set:
   - Email: user@domain.com
   - Password: (strong password)
   - Quota: (optional)
   - Enabled: Yes

## Aliases

Create aliases that forward to other addresses:

1. Admin panel → Aliases
2. Click **Add alias**
3. Source: alias@domain.com
4. Destination: user@domain.com

## Auto-Reply (Vacation)

Users can set in Roundcube:
1. Login to webmail
2. Settings → Vacation
3. Enable and compose message

## Filtering (Sieve)

Create filters in Roundcube:
1. Settings → Filters
2. Create new filter
3. Set conditions and actions

## Security Features

- **TLS/SSL:** Let's Encrypt certificates
- **DKIM:** DomainKeys Identified Mail
- **SPF:** Sender Policy Framework
- **DMARC:** Domain-based Message Authentication
- **Antispam:** Rspamd with machine learning
- **Antivirus:** ClamAV scanning
- **Rate Limiting:** Brute force protection

## Troubleshooting

### Can't Send Email

1. Check port 587/465 is open: `telnet mail.kayorama.nl 587`
2. Verify SPF record: `dig TXT kayorama.nl`
3. Check IP reputation: https://mxtoolbox.com/blacklists.aspx
4. Verify reverse DNS (PTR) is set

### Can't Receive Email

1. Check MX record: `dig MX kayorama.nl`
2. Verify port 25 is open: `telnet mail.kayorama.nl 25`
3. Check firewall rules
4. Review logs: `docker logs mailserver-front-1`

### SSL Certificate Issues

1. Wait 5-10 minutes for Let's Encrypt
2. Verify DNS A record points to server
3. Check domain is accessible: `curl -I https://mail.kayorama.nl`

### Login Issues

1. Verify user exists in admin panel
2. Check password (case sensitive)
3. Try webmail first to confirm credentials
4. Check rate limiting logs

## Backup

### Automated Backup Script

```bash
#!/bin/bash
BACKUP_DIR=/backups/mailu
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup
mkdir -p $BACKUP_DIR
docker run --rm \
  -v mailserver_mailu_data:/data \
  -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/mailu-$DATE.tar.gz -C /data .

# Keep only last 7 backups
ls -t $BACKUP_DIR/mailu-*.tar.gz | tail -n +8 | xargs rm -f
```

Add to crontab:
```
0 2 * * * /path/to/backup.sh
```

## Monitoring

Check mail queue:
```bash
docker exec mailserver-smtp-1 postqueue -p
```

Check logs:
```bash
docker logs mailserver-front-1
docker logs mailserver-smtp-1
docker logs mailserver-imap-1
```

Check status:
```bash
docker ps | grep mailserver
```

## Updates

Update Mailu:
```bash
cd /path/to/mailserver
docker-compose pull
docker-compose up -d
```

## Resources

- Mailu Docs: https://mailu.io/
- Roundcube Docs: https://roundcube.net/
- Test Email: https://www.mail-tester.com/
- DNS Check: https://mxtoolbox.com/
