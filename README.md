# Kayorama Mail Server

Full-featured email server using Mailu on Coolify.

## Features

- **Multi-domain support** - Host email for multiple domains
- **Webmail** - Roundcube interface at /webmail
- **Mobile support** - Works with Apple Mail, Gmail, Outlook
- **Security** - Let's Encrypt SSL, DKIM, DMARC, SPF
- **Antispam** - Rspamd with machine learning
- **Antivirus** - ClamAV scanning
- **Admin panel** - Web-based administration

## Ports Used

| Port | Service | Purpose |
|------|---------|---------|
| 25 | SMTP | Incoming mail |
| 465 | SMTPS | Secure SMTP (legacy) |
| 587 | Submission | Outgoing mail (STARTTLS) |
| 110 | POP3 | Mail retrieval (avoid) |
| 995 | POP3S | Secure POP3 |
| 143 | IMAP | Mail retrieval (STARTTLS) |
| 993 | IMAPS | Secure IMAP |

## Setup

1. **Update Configuration**
   - Edit `mailu.env`
   - Change `DOMAIN` to your main domain
   - Change `HOSTNAME` to mail.yourdomain.com
   - Set `SECRET_KEY` (generate: `openssl rand -hex 32`)
   - Set `INITIAL_ADMIN_PW` to a strong password
   - Add additional domains to `DOMAINS=`

2. **DNS Records**

   For each domain, add these DNS records:

   ```
   # A Record
   mail.domain.com    A     YOUR_SERVER_IP

   # MX Record
   domain.com         MX    10 mail.domain.com

   # SPF
   domain.com         TXT   "v=spf1 mx a:mail.domain.com -all"

   # DKIM (added automatically after setup)
   mail._domainkey    TXT   (auto-generated)

   # DMARC
   _dmarc             TXT   "v=DMARC1; p=quarantine; rua=mailto:admin@domain.com"
   ```

3. **Deploy on Coolify**
   - Create new project
   - Add Docker Compose resource
   - Upload docker-compose.yml and mailu.env
   - Deploy

4. **Access**
   - Admin: https://mail.kayorama.nl/admin
   - Webmail: https://mail.kayorama.nl/webmail

## Mobile Setup

### Apple Mail (iPhone/iPad/Mac)

**Incoming Mail (IMAP):**
- Hostname: mail.kayorama.nl
- Username: user@domain.com
- Password: your-password
- Port: 993 (SSL)

**Outgoing Mail (SMTP):**
- Hostname: mail.kayorama.nl
- Username: user@domain.com
- Password: your-password
- Port: 587 (STARTTLS) or 465 (SSL)

### Gmail (Android/Web)

**Add account → Other:**
- Email: user@domain.com
- Password: your-password
- IMAP Server: mail.kayorama.nl:993
- SMTP Server: mail.kayorama.nl:587

### Outlook

**Manual Setup:**
- Account Type: IMAP
- Incoming: mail.kayorama.nl:993 (SSL)
- Outgoing: mail.kayorama.nl:587 (STARTTLS)

## Adding Domains

1. Log into admin panel
2. Go to "Mail domains"
3. Click "Add domain"
4. Add DNS records for new domain
5. Generate DKIM key in admin panel
6. Add DKIM TXT record to DNS

## Adding Users

1. Admin panel → Users
2. Click "Add user"
3. Set username, domain, password
4. Optional: Set quota, enable/disable

## Troubleshooting

**Can't send email:**
- Check port 587/465 is open
- Verify SPF record
- Check if IP is blacklisted: mxtoolbox.com/blacklists.aspx

**Can't receive email:**
- Check MX record
- Verify port 25 is open
- Check spam folder

**SSL errors:**
- Wait for Let's Encrypt (can take a few minutes)
- Check DNS A record points to server

## Security

- Change default admin password immediately
- Use strong passwords for all accounts
- Enable 2FA in admin panel if available
- Keep server updated
- Monitor logs for abuse

## Backup

Mail data is in Docker volumes:
- `mailu_data` - All emails and config
- `mailu_certs` - SSL certificates

Backup command:
```bash
docker run --rm -v mailu_data:/data -v $(pwd):/backup alpine tar czf /backup/mailu-backup.tar.gz -C /data .
```
