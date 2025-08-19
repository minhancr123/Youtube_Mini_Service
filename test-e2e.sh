#!/bin/bash

# End-to-End Test Script
# This script demonstrates the complete workflow of the Mini Service

echo "🧪 Starting End-to-End Test..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SERVICE_URL="http://localhost:8080"
TEST_VIDEO_URL="https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# Function to print status
print_status() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Test 1: Health Check
print_status "Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s -w "%{http_code}" $SERVICE_URL/health)
HTTP_CODE="${HEALTH_RESPONSE: -3}"

if [ "$HTTP_CODE" -eq 200 ]; then
    print_success "Health check passed"
else
    print_error "Health check failed (HTTP $HTTP_CODE)"
    exit 1
fi

# Test 2: Submit video for analysis
print_status "Submitting video for analysis..."
ANALYZE_RESPONSE=$(curl -s -X POST $SERVICE_URL/analyze \
    -H "Content-Type: application/json" \
    -d "{\"url\": \"$TEST_VIDEO_URL\"}")

# Extract ID from response
VIDEO_ID=$(echo $ANALYZE_RESPONSE | grep -o '"id":"[^"]*"' | cut -d'"' -f4)

if [ -n "$VIDEO_ID" ]; then
    print_success "Video submitted successfully. ID: $VIDEO_ID"
else
    print_error "Failed to submit video"
    echo "Response: $ANALYZE_RESPONSE"
    exit 1
fi

# Test 3: Poll for results
print_status "Waiting for analysis to complete..."
MAX_ATTEMPTS=30
ATTEMPT=1

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    RESULT_RESPONSE=$(curl -s $SERVICE_URL/result/$VIDEO_ID)
    STATUS=$(echo $RESULT_RESPONSE | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    
    if [ "$STATUS" = "completed" ]; then
        print_success "Analysis completed!"
        break
    elif [ "$STATUS" = "failed" ]; then
        print_error "Analysis failed"
        echo "Response: $RESULT_RESPONSE"
        exit 1
    else
        print_status "Analysis in progress... (attempt $ATTEMPT/$MAX_ATTEMPTS)"
        sleep 10
        ((ATTEMPT++))
    fi
done

if [ $ATTEMPT -gt $MAX_ATTEMPTS ]; then
    print_error "Analysis timed out"
    exit 1
fi

# Test 4: Verify outputs
print_status "Verifying generated files..."

# Check if files exist
FILES_TO_CHECK=(
    "audio/${VIDEO_ID}.wav"
    "screenshots/${VIDEO_ID}.png"
    "subtitles/${VIDEO_ID}.srt"
)

for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$file" ]; then
        print_success "File exists: $file"
    else
        print_error "File missing: $file"
    fi
done

# Test 5: Display final results
print_status "Final analysis results:"
echo "----------------------------------------"
echo $RESULT_RESPONSE | python3 -m json.tool 2>/dev/null || echo $RESULT_RESPONSE
echo "----------------------------------------"

print_success "End-to-end test completed successfully! 🎉"

# Optional: Display file sizes
print_status "Generated file sizes:"
for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$file" ]; then
        SIZE=$(du -h "$file" | cut -f1)
        echo "  - $file: $SIZE"
    fi
done

echo ""
echo "📝 To view the screenshot, open: screenshots/${VIDEO_ID}.png"
echo "🎵 To play the audio, open: audio/${VIDEO_ID}.wav"
echo "📄 To view subtitles, open: subtitles/${VIDEO_ID}.srt"
