#!/bin/bash
# Stop Paperless-ngx services

echo "🛑 Stopping Paperless-ngx..."
docker-compose stop

echo ""
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "✅ Paperless-ngx has been stopped!"
echo "💾 All your data is safely stored in Docker volumes"
echo ""
echo "💡 To start again, run: ./start.sh"
echo "💡 To completely remove (including data), run: docker-compose down -v"
