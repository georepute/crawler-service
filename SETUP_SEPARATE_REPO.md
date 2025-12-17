# Setup Separate Repository for Crawler Service

## ✅ Files Check - All Present

- ✅ `package.json` - Dependencies configured
- ✅ `server.js` - Main server file
- ✅ `Dockerfile` - Docker configuration
- ✅ `.gitignore` - Ignores node_modules, .env
- ✅ `.dockerignore` - Docker build optimization
- ✅ `README.md` - Documentation
- ✅ `RENDER_DEPLOYMENT.md` - Deployment guide

---

## Step 1: Initialize Git Repository

```bash
cd /path/to/crawler-service
git init
git add .
git commit -m "Initial commit: Crawler service with Playwright"
```

---

## Step 2: Create GitHub Repository

### 2.1 Create New Repo on GitHub

1. Go to https://github.com/new
2. **Repository name:** `georepute-crawler` (or your preferred name)
3. **Description:** "Website crawler service using Playwright for GeoRepute.ai"
4. **Visibility:** Private (recommended) or Public
5. **DO NOT** initialize with README, .gitignore, or license (we already have these)
6. Click **"Create repository"**

### 2.2 Push to GitHub

GitHub will show you commands. Use these:

```bash
cd /path/to/crawler-service

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/georepute-crawler.git

# Push to GitHub
git branch -M main
git push -u origin main
```

---

## Step 3: Deploy to Render

### 3.1 Create Render Account

1. Go to https://render.com
2. Sign up/Login (use GitHub to sign in for easier setup)

### 3.2 Create Web Service

1. Click **"New +"** → **"Web Service"**
2. **Connect Repository:**
   - Click "Connect GitHub" if not connected
   - Authorize Render
   - Select repository: `georepute-crawler`

3. **Configure Service:**
   - **Name:** `georepute-crawler`
   - **Region:** Choose closest (e.g., `Oregon (US West)`)
   - **Branch:** `main`
   - **Root Directory:** (leave empty - we're at root)
   - **Runtime:** `Docker`
   - **Dockerfile Path:** `Dockerfile` (or leave empty if at root)

4. **Environment Variables:**
   Click "Add Environment Variable" and add:
   ```
   PORT=3001
   OPENAI_API_KEY=your_openai_api_key_here
   ```

5. **Advanced Settings:**
   - **Health Check Path:** `/health`

6. Click **"Create Web Service"**

7. **Wait for Build:**
   - First build takes 5-10 minutes
   - Watch the logs for progress

### 3.3 Get Render URL

After deployment, you'll get a URL like:
```
https://georepute-crawler.onrender.com
```

**Save this URL!** You'll need it for GEORepute.ai

---

## Step 4: Test Render Service

```bash
# Health check
curl https://georepute-crawler.onrender.com/health

# Test crawl
curl -X POST https://georepute-crawler.onrender.com/crawl \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com"}'
```

---

## Step 5: Connect to GEORepute.ai

### 5.1 Update Vercel Environment Variables

1. Go to your **Vercel Dashboard**
2. Select your **GEORepute.ai** project
3. Go to **Settings** → **Environment Variables**
4. Add new variable:
   - **Name:** `CRAWLER_SERVICE_URL`
   - **Value:** `https://georepute-crawler.onrender.com` (your Render URL)
   - **Environment:** Select all (Production, Preview, Development)

5. Click **"Save"**

### 5.2 Update GEORepute.ai Code (if needed)

Check `app/api/crawl-website/route.ts` - it should already use:
```typescript
const CRAWLER_SERVICE_URL = process.env.CRAWLER_SERVICE_URL || 'http://localhost:3001';
```

If it doesn't, update it to call the Render service.

### 5.3 Redeploy Vercel

1. Go to **Deployments** tab
2. Click **"Redeploy"** on latest deployment
3. Or push a new commit to trigger auto-deploy

---

## Step 6: Test Integration

1. Go to your deployed GEORepute.ai app
2. Navigate to **AI Visibility** page
3. Enter a website URL (e.g., `https://www.apple.com`)
4. Click **"Launch Analysis"**
5. Check browser console - should see request to Render service
6. Verify website is crawled and description is generated

---

## Architecture Overview

```
GEORepute.ai (Vercel)
    ↓ HTTP Request
    ↓ Uses CRAWLER_SERVICE_URL env variable
    ↓
georepute-crawler (Render)
    ↓ Crawls website with Playwright
    ↓ Generates AI description
    ↓ Returns JSON
    ↓
GEORepute.ai (receives response)
```

---

## File Structure

```
crawler-service/
├── .dockerignore          # Docker ignore rules
├── .gitignore            # Git ignore rules
├── Dockerfile            # Docker configuration
├── package.json          # Dependencies
├── server.js             # Main server
├── README.md             # Documentation
├── RENDER_DEPLOYMENT.md  # Deployment guide
└── SETUP_SEPARATE_REPO.md # This file
```

---

## Important Notes

1. **Separate Repos:**
   - `georepute-crawler` - Standalone service (this repo)
   - `GEORepute.ai` - Main app (uses crawler via HTTP)

2. **Environment Variables:**
   - **Render:** Needs `PORT` and `OPENAI_API_KEY`
   - **Vercel:** Needs `CRAWLER_SERVICE_URL`

3. **Free Tier:**
   - Render free tier spins down after 15 min
   - First request after sleep: 30-60 seconds
   - Consider health check ping or paid plan

4. **Security:**
   - `.env` is in `.gitignore` (not committed)
   - API keys set in Render dashboard (secure)

---

## Troubleshooting

### Render Build Fails
- Check Dockerfile is at root
- Check package.json is correct
- Check build logs for specific errors

### Service Not Responding
- Check Render logs
- Verify environment variables
- Test health endpoint

### GEORepute.ai Can't Connect
- Verify `CRAWLER_SERVICE_URL` is set in Vercel
- Check Render service is running
- Test Render URL directly with curl

---

## Next Steps

1. ✅ Initialize git repo
2. ✅ Create GitHub repo
3. ✅ Push to GitHub
4. ✅ Deploy to Render
5. ✅ Get Render URL
6. ✅ Update Vercel env variable
7. ✅ Test integration

---

## Support

If you need help:
1. Check Render build logs
2. Check Render service logs
3. Test Render service directly
4. Check Vercel function logs
5. Verify environment variables

