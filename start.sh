#!/bin/bash
# Start Paperless-ngx services

echo "🚀 Starting Paperless-ngx..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 5

echo ""
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "✅ Paperless-ngx is starting up!"
echo "📍 Access it at: http://homeserverx:8000"
echo ""
echo "💡 To view logs, run: docker-compose logs -f"
echo "💡 To stop services, run: ./stop.sh"
