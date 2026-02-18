# Mailu Email Server

Zero-config email server. Just set your domain and deploy.

## Quick Deploy (2 minutes)

### 1. Create Project in Coolify
- New Project → Docker Compose
- Repository: `https://github.com/kaygaaf/mailserver`

### 2. Set Environment Variables (only 1 required!)

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DOMAIN` | ✅ Yes | - | Your main domain (e.g., kayorama.nl) |
| `HOSTNAMES` | No | mail.${DOMAIN} | Mail server hostname |
| `ADMIN_PASSWORD` | No | auto-generated | Admin password |
| `SECRET_KEY` | No | auto-generated | Encryption key |

**Example:**
```
DOMAIN=kayorama.nl
```

That's it! Everything else is auto-configured.

### 3. Deploy
Click deploy and wait 2-3 minutes.

### 4. Check Logs for Password
If you didn't set `ADMIN_PASSWORD`, check the logs:
```
docker logs mailserver-admin-1 | grep "Password"
```

## DNS Records (Auto-generated)

After deploy, run this to get your DNS records:
```bash
docker exec mailserver-admin-1 cat /dns-records.txt
```

Or manually add:

```
mail.kayorama.nl    A     YOUR_SERVER_IP
kayorama.nl         MX    10 mail.kayorama.nl
kayorama.nl         TXT   "v=spf1 mx a:mail.kayorama.nl -all"
_dmarc.kayorama.nl  TXT   "v=DMARC1; p=quarantine; rua=mailto:admin@kayorama.nl"
```

## Access

- **Webmail:** https://mail.kayorama.nl/webmail
- **Admin:** https://mail.kayorama.nl/admin
- **Username:** admin@kayorama.nl

## Mobile Setup

**iPhone/Android:**
- Email: user@kayorama.nl
- IMAP: mail.kayorama.nl:993 (SSL)
- SMTP: mail.kayorama.nl:587 (STARTTLS)

## Adding More Domains

Just add to environment:
```
OTHER_DOMAINS=domain2.com,domain3.com
```

Then add DNS records for each domain.

## Features

✅ Webmail (Roundcube)
✅ Admin panel
✅ Multi-domain
✅ Apple/Google Mail compatible
✅ Auto SSL (Let's Encrypt)
✅ Antispam & Antivirus
✅ DKIM, SPF, DMARC

## Support

Docs: https://mailu.io
