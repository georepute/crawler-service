# Quick Start Guide - Test Locally First

## Phase 1: Local Testing (Without Docker)

### Step 1: Install Dependencies

```bash
cd crawler-service
npm install
```

### Step 2: Install Playwright Browser

```bash
npx playwright install chromium
```

This will download the Chromium browser (~200MB). It may take a few minutes.

### Step 3: Create Environment File

```bash
cp .env.example .env
```

Then edit `.env` and add your OpenAI API key (optional, but recommended for AI summaries):
```
PORT=3001
OPENAI_API_KEY=sk-your-key-here
```

**Note:** If you don't have an OpenAI key, the service will still work but will use fallback descriptions.

### Step 4: Start the Service

```bash
npm start
```

You should see:
```
Crawler service running on port 3001
```

**Keep this terminal open!**

### Step 5: Test the Service

Open a **new terminal** and run:

**Test 1: Health Check**
```bash
curl http://localhost:3001/health
```

Expected output:
```json
{"status":"ok","service":"crawler"}
```

**Test 2: Crawl a Website**
```bash
curl -X POST http://localhost:3001/crawl \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com"}'
```

Expected output (JSON with description, imageUrl, metadata):
```json
{
  "success": true,
  "description": "...",
  "imageUrl": "...",
  "metadata": {...}
}
```

**Test 3: Test with Real Website**
```bash
curl -X POST http://localhost:3001/crawl \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.apple.com"}'
```

**Or use the test script:**
```bash
./test.sh
```

### Step 6: Stop the Service

Press `Ctrl+C` in the terminal where the service is running.

---

## Phase 2: Docker Testing (After Local Tests Pass)

### Step 1: Build Docker Image

```bash
docker build -t georepute-crawler .
```

This will take 5-10 minutes the first time (downloads all dependencies and browsers).

### Step 2: Run Docker Container

```bash
docker run -p 3001:3001 \
  -e PORT=3001 \
  -e OPENAI_API_KEY=your_key_here \
  georepute-crawler
```

**Note:** Make sure port 3001 is free (stop the local Node.js service first).

### Step 3: Test Docker Container

In a **new terminal**, test with the same curl commands:

```bash
# Health check
curl http://localhost:3001/health

# Crawl test
curl -X POST http://localhost:3001/crawl \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com"}'
```

### Step 4: Stop Docker Container

```bash
# Find container ID
docker ps

# Stop container
docker stop <container_id>
```

Or press `Ctrl+C` if running in foreground.

---

## Troubleshooting

### Issue: "Cannot find module 'playwright'"
**Solution:** Run `npm install` again

### Issue: "Browser not found"
**Solution:** Run `npx playwright install chromium`

### Issue: "Port 3001 already in use"
**Solution:** 
- Stop the service running on port 3001
- Or change PORT in .env to a different port (e.g., 3002)

### Issue: Docker build fails
**Solution:**
- Check Docker is running: `docker ps`
- Check Dockerfile syntax
- Check internet connection (needs to download packages)

### Issue: Service crashes
**Solution:**
- Check logs in terminal
- Verify .env file exists and has correct values
- Try with a simpler URL first (example.com)

---

## Next Steps

Once both local and Docker tests pass:
1. ✅ Push code to GitHub
2. ✅ Deploy to Render
3. ✅ Update Vercel to use Render service

See `../docs/CRAWLER_DOCKER_DEPLOYMENT.md` for full deployment guide.

