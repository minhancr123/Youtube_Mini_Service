#!/bin/bash

# Quick Demo Script for Mini Service
# This script starts the service and runs a quick demo

echo "🎬 Mini Service Demo - Starting..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Build and start the service
echo "🔨 Building and starting service..."
docker-compose up --build -d

# Wait for service to start
echo "⏳ Waiting for service to start (30 seconds)..."
sleep 30

# Test health endpoint
echo "🏥 Testing health endpoint..."
curl -s http://localhost:8080/health | python3 -m json.tool

echo ""
echo "🎯 Service is ready! Here are some commands to try:"
echo ""
echo "1. Health Check:"
echo "   curl http://localhost:8080/health"
echo ""
echo "2. Analyze a video:"
echo "   curl -X POST http://localhost:8080/analyze -H 'Content-Type: application/json' -d '{\"url\": \"YOUR_VIDEO_URL\"}'"
echo ""
echo "3. Get results (replace ID with actual ID from step 2):"
echo "   curl http://localhost:8080/result/YOUR_ID"
echo ""
echo "4. Run full end-to-end test:"
echo "   ./test-e2e.sh"
echo ""
echo "5. View logs:"
echo "   docker-compose logs -f"
echo ""
echo "6. Stop service:"
echo "   docker-compose down"
echo ""
echo "🌐 Service is running at: http://localhost:8080"
echo "📁 Files will be saved in: audio/, screenshots/, subtitles/"
