#!/bin/bash

# Test script for crawler service
# Usage: ./test.sh

BASE_URL="http://localhost:3001"

echo "🧪 Testing Crawler Service"
echo "=========================="
echo ""

# Test 1: Health Check
echo "1️⃣ Testing Health Endpoint..."
HEALTH_RESPONSE=$(curl -s http://localhost:3001/health)
if [ $? -eq 0 ]; then
  echo "✅ Health check passed: $HEALTH_RESPONSE"
else
  echo "❌ Health check failed. Is the server running?"
  exit 1
fi
echo ""

# Test 2: Crawl Example.com
echo "2️⃣ Testing Crawl Endpoint (example.com)..."
CRAWL_RESPONSE=$(curl -s -X POST http://localhost:3001/crawl \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com"}')
if [ $? -eq 0 ]; then
  echo "✅ Crawl test passed"
  echo "Response: $CRAWL_RESPONSE" | head -c 200
  echo "..."
else
  echo "❌ Crawl test failed"
  exit 1
fi
echo ""
echo ""

# Test 3: Crawl Real Website
echo "3️⃣ Testing Crawl Endpoint (apple.com)..."
CRAWL_RESPONSE2=$(curl -s -X POST http://localhost:3001/crawl \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.apple.com"}')
if [ $? -eq 0 ]; then
  echo "✅ Real website crawl test passed"
  echo "Response preview: $CRAWL_RESPONSE2" | head -c 300
  echo "..."
else
  echo "❌ Real website crawl test failed"
  exit 1
fi
echo ""
echo ""

echo "🎉 All tests passed!"

