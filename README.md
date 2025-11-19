# Paperless-ngx Home Server Setup

This repository contains the Docker Compose configuration for running Paperless-ngx on your home server for managing family documents and scans.

## What is Paperless-ngx?

Paperless-ngx is a document management system that transforms your physical documents into a searchable online archive. It scans your documents, performs OCR (Optical Character Recognition), and allows you to organize, search, and retrieve them easily.

## Prerequisites

- Docker and Docker Compose installed on your home server
- At least 2GB of RAM available
- Sufficient storage space for your documents

## Repository Structure

```
.
├── docker-compose.yml       # Docker services configuration
├── docker-compose.env       # Environment variables and settings
├── README.md               # This file
├── consume/                # Folder for uploading new documents (auto-created)
└── export/                 # Folder for exporting documents (auto-created)
```

## Installation Steps

### 1. Clone this repository

```bash
git clone <your-repo-url>
cd paperless-ngx-homeserver
```

### 2. Configure environment variables

Edit the `docker-compose.env` file and update the following critical settings:

**Security Settings (REQUIRED):**
```bash
# Change this to a long random string (at least 64 characters)
PAPERLESS_SECRET_KEY=your-very-long-random-secret-key-here

# Change default admin credentials
PAPERLESS_ADMIN_USER=your-admin-username
PAPERLESS_ADMIN_PASSWORD=your-secure-password
PAPERLESS_ADMIN_MAIL=your-email@example.com
```

**Generate a secure secret key:**
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(64))"
```

**Optional Settings:**
- `PAPERLESS_TIME_ZONE`: Set to your timezone (default: Europe/Oslo)
- `PAPERLESS_OCR_LANGUAGE`: Primary language for OCR (default: eng)
- `PAPERLESS_OCR_LANGUAGES`: Additional languages (default: eng nor)
- `USERMAP_UID` and `USERMAP_GID`: Set to your user's UID/GID (check with `id` command)

### 3. Create required directories

```bash
mkdir -p consume export
```

### 4. Start Paperless-ngx

```bash
docker-compose up -d
```

This will:
- Download the necessary Docker images
- Create and start the PostgreSQL database
- Create and start the Redis broker
- Start the Paperless-ngx webserver

### 5. Check the logs

```bash
docker-compose logs -f webserver
```

Wait until you see messages indicating that the system is ready.

### 6. Access Paperless-ngx

Open your web browser and navigate to:
```
http://homeserverx:8000
```
or
```
http://<your-server-ip>:8000
```

Log in with the credentials you set in `docker-compose.env`.

## Usage

### Adding Documents

There are several ways to add documents to Paperless-ngx:

#### 1. Upload via Web Interface
- Log in to the web interface
- Click on the upload button
- Select your documents

#### 2. Consume Folder (Recommended for bulk uploads)
- Copy or move documents to the `./consume` folder
- Paperless will automatically detect and process them
- Original files will be deleted after successful import (configure with `PAPERLESS_CONSUMER_DELETE_DUPLICATES`)

```bash
# Example: Copy scans to consume folder
cp /path/to/scans/* ./consume/
```

#### 3. Email (requires email configuration)
- Configure email settings in `docker-compose.env`
- Email documents as attachments to your configured address

#### 4. Mobile App
- Use the official Paperless-ngx mobile app (iOS/Android)
- Scan documents directly with your phone

### Document Organization

Paperless-ngx organizes documents using:
- **Tags**: Categorize documents (e.g., "Tax", "Medical", "Bills")
- **Correspondents**: Who the document is from/to
- **Document Types**: What kind of document it is
- **Dates**: When the document was created
- **Custom Fields**: Add your own metadata

### Searching Documents

- Full-text search across all documents
- Filter by tags, correspondents, dates, types
- Advanced query syntax for complex searches

## Maintenance

### Backup

It's crucial to backup your Paperless data regularly. The important data includes:

1. **PostgreSQL Database**
```bash
docker-compose exec db pg_dump -U paperless paperless > backup_$(date +%Y%m%d).sql
```

2. **Media Files** (original documents)
```bash
# The media volume contains your documents
docker run --rm -v paperless-ngx-homeserver_media:/data -v $(pwd):/backup ubuntu tar czf /backup/media_backup_$(date +%Y%m%d).tar.gz /data
```

3. **Data Files** (index and metadata)
```bash
docker run --rm -v paperless-ngx-homeserver_data:/data -v $(pwd):/backup ubuntu tar czf /backup/data_backup_$(date +%Y%m%d).tar.gz /data
```

### Using Paperless Export Feature
```bash
# Export all documents via the web interface or command:
docker-compose exec webserver document_exporter /usr/src/paperless/export
```

### Update Paperless-ngx

```bash
docker-compose pull
docker-compose up -d
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f webserver
docker-compose logs -f db
docker-compose logs -f broker
```

### Restart Services

```bash
docker-compose restart
```

### Stop Services

```bash
docker-compose down
```

## Advanced Configuration

### Reverse Proxy (Nginx/Traefik)

If you want to access Paperless-ngx via a domain name with HTTPS, uncomment and configure these in `docker-compose.env`:

```bash
PAPERLESS_URL=https://paperless.yourdomain.com
```

Then set up your reverse proxy to forward requests to `localhost:8000`.

### Additional OCR Languages

Install additional language packs by adding them to `PAPERLESS_OCR_LANGUAGES`:

```bash
PAPERLESS_OCR_LANGUAGES=eng nor swe dan deu fra
```

Available languages: https://packages.debian.org/search?keywords=tesseract-ocr-

### Email Notifications

Configure email settings in `docker-compose.env` to receive notifications:

```bash
PAPERLESS_EMAIL_HOST=smtp.gmail.com
PAPERLESS_EMAIL_PORT=587
PAPERLESS_EMAIL_HOST_USER=your-email@gmail.com
PAPERLESS_EMAIL_HOST_PASSWORD=your-app-password
PAPERLESS_EMAIL_USE_TLS=true
PAPERLESS_EMAIL_FROM=paperless@yourdomain.com
```

### Advanced Document Processing (Tika & Gotenberg)

For better support of Office documents, add these services to `docker-compose.yml`:

```yaml
  gotenberg:
    image: docker.io/gotenberg/gotenberg:7.10
    restart: unless-stopped
    networks:
      - paperless

  tika:
    image: ghcr.io/paperless-ngx/tika:latest
    restart: unless-stopped
    networks:
      - paperless
```

And enable in `docker-compose.env`:
```bash
PAPERLESS_TIKA_ENABLED=1
PAPERLESS_TIKA_ENDPOINT=http://tika:9998
PAPERLESS_TIKA_GOTENBERG_ENDPOINT=http://gotenberg:3000
```

## Troubleshooting

### Cannot access web interface
- Check if containers are running: `docker-compose ps`
- Check logs: `docker-compose logs webserver`
- Ensure port 8000 is not blocked by firewall

### OCR not working properly
- Verify `PAPERLESS_OCR_LANGUAGE` is set correctly
- Install additional language packs if needed
- Check document quality (minimum 300 DPI recommended)

### Database connection errors
- Ensure database credentials in `docker-compose.env` match `docker-compose.yml`
- Check database logs: `docker-compose logs db`

### Permission errors with consume folder
- Set correct `USERMAP_UID` and `USERMAP_GID` in `docker-compose.env`
- Check folder permissions: `ls -la consume/`

### High memory usage
- Reduce `PAPERLESS_TASK_WORKERS` in `docker-compose.env`
- Increase server resources if processing many documents

## Security Recommendations

1. **Change default passwords** in `docker-compose.env`
2. **Use a strong secret key** (at least 64 characters)
3. **Don't expose port 8000** directly to the internet; use a reverse proxy with HTTPS
4. **Regular backups** of database and media files
5. **Keep Docker images updated** regularly
6. **Use firewall rules** to restrict access to your home network

## Useful Commands

```bash
# Create a superuser
docker-compose exec webserver python manage.py createsuperuser

# Reprocess all documents
docker-compose exec webserver document_retagger

# Check system status
docker-compose exec webserver python manage.py check

# Clear Redis cache
docker-compose exec broker redis-cli FLUSHALL

# Import documents from export
docker-compose exec webserver document_importer /usr/src/paperless/export
```

## Documentation

- Official Paperless-ngx Documentation: https://docs.paperless-ngx.com/
- Docker Setup Guide: https://docs.paperless-ngx.com/setup/#docker_hub
- Configuration Options: https://docs.paperless-ngx.com/configuration/

## Support

- GitHub Issues: https://github.com/paperless-ngx/paperless-ngx/issues
- Discussions: https://github.com/paperless-ngx/paperless-ngx/discussions
- Discord: https://discord.gg/paperless-ngx
- 

## Tips
rdfind (Fast & Smart)
Rdfind uses a ranking algorithm to identify the original file vs duplicates, making it faster than other tools BeebomMakeUseOf. It creates a results.txt file you can review before deleting anything Wondershare Recoverit.
Install:
bashsudo apt install rdfind
Scan for duplicates (safe - just creates report):
bashrdfind /path/to/your/documents
Review results:
bashcat results.txt
Delete duplicates after review:
bashrdfind -deleteduplicates true /path/to/your/documents

## License

Paperless-ngx is licensed under the GNU General Public License v3.0.

---

**Happy Document Management! 📄**
