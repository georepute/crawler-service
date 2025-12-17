# Crawler Service

Website crawler service using Playwright to extract metadata, descriptions, and images from websites.

## Local Development

### 1. Install Dependencies

```bash
npm install
```

### 2. Install Playwright Browsers

```bash
npx playwright install chromium
```

### 3. Setup Environment

```bash
cp .env.example .env
# Edit .env and add your OPENAI_API_KEY
```

### 4. Start Server

```bash
npm start
```

### 5. Test

```bash
# Health check
curl http://localhost:3001/health

# Crawl endpoint
curl -X POST http://localhost:3001/crawl \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com"}'
```

## Docker

### Build Image

```bash
docker build -t georepute-crawler .
```

### Run Container

```bash
docker run -p 3001:3001 \
  -e PORT=3001 \
  -e OPENAI_API_KEY=your_key_here \
  georepute-crawler
```

## API Endpoints

### GET /health

Health check endpoint.

**Response:**
```json
{
  "status": "ok",
  "service": "crawler"
}
```

### POST /crawl

Crawl a website and extract metadata.

**Request:**
```json
{
  "url": "https://example.com"
}
```

**Response:**
```json
{
  "success": true,
  "description": "Company description...",
  "imageUrl": "https://example.com/logo.png",
  "metadata": {
    "title": "Page Title",
    "metaDescription": "Meta description",
    "ogDescription": "OG description"
  }
}
```

