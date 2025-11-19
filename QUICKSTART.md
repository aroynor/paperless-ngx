# Quick Start Guide

Get Paperless-ngx running in 5 minutes!

## Step 1: Initial Setup (2 minutes)

```bash
# Clone your repository
git clone <your-repo-url>
cd paperless-ngx-homeserver

# Copy and edit the environment file
cp docker-compose.env.template docker-compose.env
nano docker-compose.env  # or use vim, vi, etc.
```

## Step 2: Critical Settings to Change

Open `docker-compose.env` and change:

1. **PAPERLESS_SECRET_KEY** - Generate with:
   ```bash
   python3 -c "import secrets; print(secrets.token_urlsafe(64))"
   ```

2. **PAPERLESS_ADMIN_USER** - Your admin username

3. **PAPERLESS_ADMIN_PASSWORD** - A strong password

4. **PAPERLESS_ADMIN_MAIL** - Your email address

## Step 3: Start Paperless (1 minute)

```bash
# Create directories
mkdir -p consume export

# Start all services
docker-compose up -d

# Watch the logs (wait for "Application startup complete")
docker-compose logs -f webserver
```

Press `Ctrl+C` to exit logs when ready.

## Step 4: Access Paperless (1 minute)

Open your browser and go to:
- `http://homeserverx:8000`
- OR `http://<your-server-ip>:8000`

Login with your credentials from Step 2.

## Step 5: Add Your First Document

### Option A: Web Upload
1. Click the upload button in the web interface
2. Select your document
3. Wait for it to process

### Option B: Consume Folder (Bulk Upload)
```bash
# Copy your documents to the consume folder
cp /path/to/your/documents/* ./consume/

# Paperless will automatically detect and process them
```

## That's it! 🎉

For more details, see [README.md](README.md)

## Quick Commands

```bash
# View logs
docker-compose logs -f

# Restart
docker-compose restart

# Stop
docker-compose down

# Update
docker-compose pull && docker-compose up -d

# Backup
docker-compose exec db pg_dump -U paperless paperless > backup.sql
```

## Need Help?

Check the full README.md or visit https://docs.paperless-ngx.com/
