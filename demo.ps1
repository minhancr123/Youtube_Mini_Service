# PowerShell Demo Script for Mini Service
# This script starts the service and runs a quick demo on Windows

Write-Host "🎬 Mini Service Demo - Starting..." -ForegroundColor Green

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Build and start the service
Write-Host "🔨 Building and starting service..." -ForegroundColor Yellow
docker-compose up --build -d

# Wait for service to start
Write-Host "⏳ Waiting for service to start (30 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Test health endpoint
Write-Host "🏥 Testing health endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/health" -Method Get
    $response | ConvertTo-Json -Depth 3
    Write-Host "✅ Health check passed!" -ForegroundColor Green
} catch {
    Write-Host "❌ Health check failed. Check if service is running." -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 Service is ready! Here are some commands to try:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Health Check (PowerShell):" -ForegroundColor White
Write-Host "   Invoke-RestMethod -Uri 'http://localhost:8080/health' -Method Get" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Analyze a video (PowerShell):" -ForegroundColor White
Write-Host "   `$body = @{ url = 'YOUR_VIDEO_URL' } | ConvertTo-Json" -ForegroundColor Gray
Write-Host "   Invoke-RestMethod -Uri 'http://localhost:8080/analyze' -Method Post -Body `$body -ContentType 'application/json'" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Get results (PowerShell):" -ForegroundColor White
Write-Host "   Invoke-RestMethod -Uri 'http://localhost:8080/result/YOUR_ID' -Method Get" -ForegroundColor Gray
Write-Host ""
Write-Host "4. View logs:" -ForegroundColor White
Write-Host "   docker-compose logs -f" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Stop service:" -ForegroundColor White
Write-Host "   docker-compose down" -ForegroundColor Gray
Write-Host ""
Write-Host "🌐 Service is running at: http://localhost:8080" -ForegroundColor Green
Write-Host "📁 Files will be saved in: audio/, screenshots/, subtitles/" -ForegroundColor Green
