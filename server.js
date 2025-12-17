const express = require('express');
const { chromium } = require('playwright');
const cheerio = require('cheerio');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'crawler' });
});

// Crawl endpoint
app.post('/crawl', async (req, res) => {
  let browser = null;
  
  try {
    const { url } = req.body;

    if (!url) {
      return res.status(400).json({
        error: 'URL is required',
        success: false
      });
    }

    // Normalize URL
    let normalizedUrl = url.trim();
    if (!normalizedUrl.startsWith('http://') && !normalizedUrl.startsWith('https://')) {
      normalizedUrl = 'https://' + normalizedUrl;
    }

    console.log(`Crawling website: ${normalizedUrl}`);

    // Launch Playwright browser
    browser = await chromium.launch({
      headless: true,
      args: [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage',
        '--disable-blink-features=AutomationControlled',
      ],
    });

    const context = await browser.newContext({
      userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      viewport: { width: 1920, height: 1080 },
      locale: 'en-US',
    });

    const page = await context.newPage();

    // Navigate to URL
    await page.goto(normalizedUrl, {
      waitUntil: 'networkidle',
      timeout: 30000,
    });

    // Wait for JavaScript to render
    await page.waitForTimeout(2000);

    // Get HTML
    const html = await page.content();
    const $ = cheerio.load(html);

    // Extract metadata
    const metaDescription = $('meta[name="description"]').attr('content') || '';
    const ogDescription = $('meta[property="og:description"]').attr('content') || '';
    const ogTitle = $('meta[property="og:title"]').attr('content') || '';
    const title = $('title').text() || '';

    // Extract about/company content
    const aboutSections = [
      $('section.about').text(),
      $('.company-info').text(),
      $('#about').text(),
      $('[class*="about"]').first().text(),
      $('main').text().substring(0, 2000),
    ].filter(text => text.trim().length > 50);

    const rawContent = aboutSections[0] || metaDescription || ogDescription || title || '';

    // Extract brand logo image
    let imageUrl = null;
    
    // Priority 1: Logo-specific meta tags
    const logoMeta = $('meta[property="og:logo"]').attr('content') || 
                     $('meta[name="logo"]').attr('content');
    if (logoMeta) {
      imageUrl = logoMeta.startsWith('http') ? logoMeta : new URL(logoMeta, normalizedUrl).href;
    }
    
    // Priority 2: Open Graph image
    if (!imageUrl) {
      const ogImage = $('meta[property="og:image"]').attr('content');
      if (ogImage) {
        imageUrl = ogImage.startsWith('http') ? ogImage : new URL(ogImage, normalizedUrl).href;
      }
    }
    
    // Priority 3: Logo from HTML elements
    if (!imageUrl) {
      const logoSelectors = [
        'img[class*="logo" i]',
        'img[id*="logo" i]',
        'img[alt*="logo" i]',
        'img[alt*="brand" i]',
        'header img',
        'nav img',
        '.logo img',
        '#logo img',
      ];
      
      for (const selector of logoSelectors) {
        const logoImg = $(selector).first();
        if (logoImg.length) {
          const src = logoImg.attr('src') || logoImg.attr('data-src') || logoImg.attr('data-lazy-src');
          if (src) {
            try {
              imageUrl = src.startsWith('http') ? src : new URL(src, normalizedUrl).href;
              break;
            } catch (e) {
              // Continue
            }
          }
        }
      }
    }

    // Generate AI summary using OpenAI (optional)
    const openAIApiKey = process.env.OPENAI_API_KEY;
    let description = '';
    
    if (openAIApiKey && rawContent) {
      try {
        const summaryResponse = await fetch('https://api.openai.com/v1/chat/completions', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${openAIApiKey}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            model: 'gpt-4o-mini',
            messages: [
              {
                role: 'system',
                content: 'You are a business analyst. Summarize what this company does in exactly 5 concise lines. Each line should be a complete sentence. Focus on what the company offers, its main products/services, and its value proposition.',
              },
              {
                role: 'user',
                content: `Based on this website content, provide a 5-line summary of what this company does:\n\n${rawContent.substring(0, 3000)}`,
              },
            ],
            max_tokens: 300,
            temperature: 0.7,
          }),
        });

        if (summaryResponse.ok) {
          const summaryData = await summaryResponse.json();
          description = summaryData.choices[0].message.content.trim();
        } else {
          // Fallback
          description = metaDescription || ogDescription || rawContent.split('\n').filter((line) => line.trim().length > 20).slice(0, 5).join('\n');
        }
      } catch (error) {
        console.error('Error generating AI summary:', error);
        description = metaDescription || ogDescription || rawContent.split('\n').filter((line) => line.trim().length > 20).slice(0, 5).join('\n');
      }
    } else {
      // Fallback if no OpenAI key
      description = metaDescription || ogDescription || rawContent.split('\n').filter((line) => line.trim().length > 20).slice(0, 5).join('\n');
    }

    res.json({
      success: true,
      description: description,
      imageUrl: imageUrl,
      metadata: {
        title: title || ogTitle,
        metaDescription: metaDescription,
        ogDescription: ogDescription,
      },
    });
  } catch (error) {
    console.error('Error crawling website:', error);
    res.status(500).json({
      error: error.message || 'Failed to crawl website',
      success: false
    });
  } finally {
    // Always close browser
    if (browser) {
      try {
        await browser.close();
      } catch (closeError) {
        console.error('Error closing browser:', closeError);
      }
    }
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Crawler service running on port ${PORT}`);
});

