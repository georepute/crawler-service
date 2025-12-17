#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🧪 Local Testing Script (Without Docker)${NC}\n"

# Check if dist folder exists
if [ ! -d "dist" ]; then
    echo -e "${YELLOW}📦 Building TypeScript...${NC}"
    npm run build
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Build failed!${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ TypeScript compiled${NC}\n"

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    npm install
fi

# Start server in background
echo -e "${YELLOW}🚀 Starting server...${NC}"
node dist/server.js &
SERVER_PID=$!

# Wait for server to start
sleep 3

# Test health endpoint
echo -e "${YELLOW}🏥 Testing health endpoint...${NC}"
HEALTH_RESPONSE=$(curl -s http://localhost:3001/health)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Health check passed:${NC}"
    echo "$HEALTH_RESPONSE" | jq . 2>/dev/null || echo "$HEALTH_RESPONSE"
else
    echo -e "${RED}❌ Health check failed!${NC}"
    kill $SERVER_PID 2>/dev/null
    exit 1
fi

echo ""

# Test crawl endpoint
echo -e "${YELLOW}🕷️  Testing crawl endpoint with Apple.com...${NC}"
CRAWL_RESPONSE=$(curl -s -X POST http://localhost:3001/crawl \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.apple.com"}')

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Crawl test completed:${NC}"
    echo "$CRAWL_RESPONSE" | jq . 2>/dev/null || echo "$CRAWL_RESPONSE"
    
    # Check if success is true
    if echo "$CRAWL_RESPONSE" | grep -q '"success":true'; then
        echo -e "\n${GREEN}✅✅✅ Crawler is working correctly!${NC}"
    else
        echo -e "\n${YELLOW}⚠️  Crawler returned but success is false. Check the response above.${NC}"
    fi
else
    echo -e "${RED}❌ Crawl test failed!${NC}"
    kill $SERVER_PID 2>/dev/null
    exit 1
fi

echo ""
echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"
echo -e "${GREEN}Server is running on http://localhost:3001${NC}"
echo -e "${YELLOW}To stop manually, run: kill $SERVER_PID${NC}"

# Wait for user interrupt
trap "kill $SERVER_PID 2>/dev/null; exit" INT TERM
wait $SERVER_PID

