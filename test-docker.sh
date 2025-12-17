#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🐳 Docker Testing Script for GEORepute Crawler${NC}\n"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker is running${NC}\n"

# Step 1: Build Docker image
echo -e "${YELLOW}📦 Step 1: Building Docker image...${NC}"
docker build -t georepute-crawler .

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Docker build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker image built successfully${NC}\n"

# Step 2: Stop and remove existing container if it exists
echo -e "${YELLOW}🧹 Cleaning up existing containers...${NC}"
docker stop crawler-test 2>/dev/null
docker rm crawler-test 2>/dev/null
echo -e "${GREEN}✅ Cleanup complete${NC}\n"

# Step 3: Run container
echo -e "${YELLOW}🚀 Step 2: Starting Docker container...${NC}"
docker run -d \
  --name crawler-test \
  -p 3001:3001 \
  -e PORT=3001 \
  georepute-crawler

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to start container!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Container started${NC}\n"

# Wait for container to be ready
echo -e "${YELLOW}⏳ Waiting for service to be ready...${NC}"
sleep 5

# Step 4: Test health endpoint
echo -e "${YELLOW}🏥 Step 3: Testing health endpoint...${NC}"
HEALTH_RESPONSE=$(curl -s http://localhost:3001/health)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Health check passed:${NC}"
    echo "$HEALTH_RESPONSE" | jq . 2>/dev/null || echo "$HEALTH_RESPONSE"
else
    echo -e "${RED}❌ Health check failed!${NC}"
    echo -e "${YELLOW}Container logs:${NC}"
    docker logs crawler-test
    exit 1
fi

echo ""

# Step 5: Test crawl endpoint
echo -e "${YELLOW}🕷️  Step 4: Testing crawl endpoint with Apple.com...${NC}"
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
    echo -e "${YELLOW}Container logs:${NC}"
    docker logs crawler-test
    exit 1
fi

echo ""
echo -e "${YELLOW}📋 Container logs (last 20 lines):${NC}"
docker logs --tail 20 crawler-test

echo ""
echo -e "${GREEN}✅✅✅ All tests completed!${NC}"
echo -e "${YELLOW}To stop the container, run:${NC}"
echo "  docker stop crawler-test"
echo -e "${YELLOW}To remove the container, run:${NC}"
echo "  docker rm crawler-test"
echo -e "${YELLOW}To view logs, run:${NC}"
echo "  docker logs -f crawler-test"

