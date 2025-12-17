# Deploy Crawler Service to Render

## Prerequisites

✅ Dockerfile exists  
✅ package.json configured  
✅ server.js ready  
✅ .env file with OpenAI key (will be set in Render)  

---

## Step 1: Commit to GitHub

### 1.1 Add crawler-service to Git

```bash
cd /Users/apple/Projects/GEORepute.ai
git add crawler-service/
git commit -m "Add crawler service for website crawling"
git push origin f1
```

**Note:** Make sure `.env` is NOT committed (it's in `.gitignore`)

---

## Step 2: Create Render Account

1. Go to https://render.com
2. Sign up/Login (you can use GitHub to sign in)
3. Verify your email if needed

---

## Step 3: Create New Web Service on Render

### 3.1 Start Creating Service

1. Click **"New +"** button (top right)
2. Select **"Web Service"**

### 3.2 Connect Repository

1. **Connect GitHub** (if not already connected)
   - Click "Connect GitHub"
   - Authorize Render to access your repositories
   - Select the repository: `GEORepute.ai`

2. **Select Repository**
   - Choose: `GEORepute.ai`
   - Branch: `f1` (or `main` if you merged)

### 3.3 Configure Service Settings

Fill in the following:

**Basic Settings:**
- **Name:** `georepute-crawler` (or any name you prefer)
- **Region:** Choose closest to your users (e.g., `Oregon (US West)`)
- **Branch:** `f1` (or your branch name)
- **Root Directory:** `crawler-service` ⚠️ **IMPORTANT**

**Build & Deploy:**
- **Runtime:** `Docker`
- **Dockerfile Path:** `crawler-service/Dockerfile` (or just `Dockerfile` if root directory is set)
- **Docker Context:** `crawler-service` (or leave empty if root directory is set)

**Advanced Settings (click "Advanced"):**
- **Build Command:** (leave empty - Docker handles it)
- **Start Command:** (leave empty - Docker handles it)
- **Health Check Path:** `/health`

### 3.4 Environment Variables

Click **"Add Environment Variable"** and add:

```
PORT=3001
OPENAI_API_KEY=your_openai_api_key_here
```

**Important:** 
- `PORT` must be `3001` (or update server.js if you use a different port)
- `OPENAI_API_KEY` is your OpenAI API key

### 3.5 Create Service

1. Click **"Create Web Service"**
2. Render will start building your Docker image
3. This will take 5-10 minutes (first time)

---

## Step 4: Monitor Build Process

### 4.1 Watch Build Logs

- You'll see build progress in real-time
- Look for:
  - ✅ "Installing dependencies"
  - ✅ "Installing Playwright browsers"
  - ✅ "Build successful"

### 4.2 Common Build Issues

**Issue: "Cannot find Dockerfile"**
- **Fix:** Check "Root Directory" is set to `crawler-service`
- Or set "Dockerfile Path" to `crawler-service/Dockerfile`

**Issue: "Build timeout"**
- **Fix:** This is normal for first build (Playwright downloads are large)
- Wait 10-15 minutes

**Issue: "npm install failed"**
- **Fix:** Check package.json is correct
- Check build logs for specific error

---

## Step 5: Get Service URL

After successful deployment:

1. Render will provide a URL like:
   ```
   https://georepute-crawler.onrender.com
   ```

2. **Save this URL** - you'll need it for Vercel

3. Test the service:
   ```bash
   # Health check
   curl https://georepute-crawler.onrender.com/health
   
   # Test crawl
   curl -X POST https://georepute-crawler.onrender.com/crawl \
     -H "Content-Type: application/json" \
     -d '{"url": "https://example.com"}'
   ```

---

## Step 6: Update Vercel Environment Variables

### 6.1 Add to Vercel

1. Go to your Vercel project dashboard
2. Navigate to **Settings** → **Environment Variables**
3. Add new variable:
   - **Name:** `CRAWLER_SERVICE_URL`
   - **Value:** `https://georepute-crawler.onrender.com`
   - **Environment:** Production, Preview, Development (select all)

4. Click **"Save"**

### 6.2 Redeploy Vercel

1. Go to **Deployments** tab
2. Click **"Redeploy"** on latest deployment
3. Or push a new commit to trigger auto-deploy

---

## Step 7: Test Integration

### 7.1 Test from Vercel App

1. Go to your deployed Vercel app
2. Navigate to **AI Visibility** page
3. Enter a website URL (e.g., `https://www.apple.com`)
4. Click **"Launch Analysis"**
5. Check browser console for requests to Render service

### 7.2 Verify It Works

- ✅ Website should be crawled
- ✅ Description should be generated
- ✅ Logo/image should be extracted
- ✅ No errors in console

---

## Step 8: Render Free Tier Notes

### Important Limitations:

⚠️ **Free Tier Spins Down:**
- Service goes to sleep after 15 minutes of inactivity
- First request after sleep takes 30-60 seconds (cold start)
- Subsequent requests are fast

### Solutions:

**Option 1: Accept Cold Starts**
- Works fine for most use cases
- Users wait 30-60 seconds on first request

**Option 2: Keep Service Alive**
- Use a service like UptimeRobot to ping `/health` every 10 minutes
- Set up: https://uptimerobot.com
- Ping URL: `https://georepute-crawler.onrender.com/health`
- Interval: 10 minutes

**Option 3: Upgrade to Paid Plan**
- $7/month for always-on service
- No cold starts
- Better performance

---

## Troubleshooting

### Service Not Responding

1. **Check Render Logs:**
   - Go to Render dashboard
   - Click on your service
   - Check "Logs" tab for errors

2. **Check Environment Variables:**
   - Verify `PORT=3001` is set
   - Verify `OPENAI_API_KEY` is correct

3. **Test Health Endpoint:**
   ```bash
   curl https://georepute-crawler.onrender.com/health
   ```

### Build Fails

1. **Check Dockerfile:**
   - Ensure it's in `crawler-service/` directory
   - Check syntax is correct

2. **Check Root Directory:**
   - Should be `crawler-service`
   - Not root of repo

3. **Check Build Logs:**
   - Look for specific error messages
   - Common: missing dependencies, timeout

### CORS Errors

- CORS is already enabled in `server.js` with `app.use(cors())`
- If you still get CORS errors, check Render service is accessible

---

## Quick Checklist

Before deploying:
- [ ] All files committed to GitHub
- [ ] `.env` is in `.gitignore` (not committed)
- [ ] Dockerfile exists and is correct
- [ ] package.json has all dependencies
- [ ] Tested locally (works)

During deployment:
- [ ] Connected GitHub repository
- [ ] Set Root Directory to `crawler-service`
- [ ] Set Runtime to `Docker`
- [ ] Added environment variables (PORT, OPENAI_API_KEY)
- [ ] Build completes successfully

After deployment:
- [ ] Service URL obtained
- [ ] Health endpoint works
- [ ] Crawl endpoint tested
- [ ] Vercel environment variable updated
- [ ] Integration tested from app

---

## Next Steps

Once deployed:
1. ✅ Test service directly from Render URL
2. ✅ Update Vercel with `CRAWLER_SERVICE_URL`
3. ✅ Test from your brand analysis page
4. ✅ Set up health check ping (optional)

---

## Support

If you encounter issues:
1. Check Render build logs
2. Check Render service logs
3. Test service directly with curl
4. Verify environment variables
5. Check Vercel function logs

