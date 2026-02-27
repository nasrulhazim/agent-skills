# Phase 2 Comprehensive Preview Mockup Template

Use this structure for `logo-preview.html`. Embed SVGs inline for reliable rendering.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[BrandName] — Logo Preview</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: system-ui, -apple-system, sans-serif; background: #F1F5F9; }

    .section { margin-bottom: 3rem; }
    .section-label {
      font-size: 0.75rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.1em;
      color: #64748B;
      padding: 0 2rem;
      margin-bottom: 1rem;
    }

    /* ── Navigation Mockup ── */
    .nav-mockup {
      display: flex;
      flex-direction: column;
      gap: 0;
    }
    .nav-dark {
      background: #0B1120;
      padding: 0.75rem 2rem;
      display: flex;
      align-items: center;
      gap: 2rem;
    }
    .nav-light {
      background: #FFFFFF;
      border-bottom: 1px solid #E2E8F0;
      padding: 0.75rem 2rem;
      display: flex;
      align-items: center;
      gap: 2rem;
    }
    .nav-logo { height: 32px; }
    .nav-links { display: flex; gap: 1.5rem; }
    .nav-dark .nav-links span { color: #94A3B8; font-size: 0.875rem; }
    .nav-light .nav-links span { color: #64748B; font-size: 0.875rem; }

    /* ── Browser Frame ── */
    .browser-frame {
      margin: 0 2rem;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 4px 24px rgba(0,0,0,0.15);
    }
    .browser-chrome {
      background: #E8ECEF;
      padding: 0.6rem 1rem;
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }
    .browser-dots { display: flex; gap: 6px; }
    .browser-dots span {
      width: 12px; height: 12px;
      border-radius: 50%;
      background: #CBD5E1;
    }
    .browser-url {
      flex: 1;
      background: #fff;
      border-radius: 6px;
      padding: 0.25rem 0.75rem;
      font-size: 0.75rem;
      color: #64748B;
      margin-left: 0.5rem;
    }
    .browser-content {
      background: #0B1120;
      padding: 2rem;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 180px;
    }
    .browser-content img, .browser-content svg { max-height: 80px; }

    /* ── Mobile Splash ── */
    .mobile-wrap {
      display: flex;
      justify-content: center;
      padding: 0 2rem;
    }
    .mobile-frame {
      width: 220px;
      border-radius: 32px;
      overflow: hidden;
      box-shadow: 0 0 0 2px #CBD5E1, 0 4px 20px rgba(0,0,0,0.2);
    }
    .mobile-status { background: #0B1120; padding: 0.5rem 1rem; height: 28px; }
    .mobile-screen {
      background: #0B1120;
      height: 380px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .mobile-screen img, .mobile-screen svg { max-width: 80px; max-height: 80px; }
    .mobile-home { background: #0B1120; padding: 0.75rem; display: flex; justify-content: center; }
    .mobile-home-bar {
      width: 100px; height: 4px;
      background: #475569;
      border-radius: 2px;
    }

    /* ── Favicon Sizes ── */
    .favicon-grid {
      display: flex;
      gap: 2rem;
      align-items: flex-end;
      padding: 0 2rem;
      flex-wrap: wrap;
    }
    .favicon-item { display: flex; flex-direction: column; align-items: center; gap: 0.5rem; }
    .favicon-bg-dark {
      background: #0B1120;
      padding: 0.5rem;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .favicon-bg-light {
      background: #FFFFFF;
      border: 1px solid #E2E8F0;
      padding: 0.5rem;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .favicon-label { font-size: 0.7rem; color: #94A3B8; }

    /* ── Footer ── */
    .footer-dark {
      background: #0B1120;
      padding: 2rem;
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    .footer-dark img, .footer-dark svg { height: 24px; opacity: 0.8; }
    .footer-copy { color: #475569; font-size: 0.75rem; }

    /* ── Color Palette ── */
    .palette {
      display: flex;
      gap: 1rem;
      padding: 0 2rem;
      flex-wrap: wrap;
    }
    .swatch {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 0.5rem;
    }
    .swatch-color {
      width: 80px;
      height: 80px;
      border-radius: 12px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    }
    .swatch-name { font-size: 0.75rem; font-weight: 600; color: #374151; }
    .swatch-hex { font-size: 0.7rem; color: #6B7280; font-family: monospace; }

    h2 { font-size: 1.25rem; padding: 2rem 2rem 0; color: #1E293B; }
    hr { margin: 2rem; border: none; border-top: 1px solid #E2E8F0; }
  </style>
</head>
<body>

  <!-- ── Section 1: Navigation ── -->
  <h2>[BrandName] — Logo System Preview</h2>
  <hr>

  <div class="section">
    <div class="section-label">Navigation Bar</div>
    <div class="nav-mockup">
      <div class="nav-dark">
        <!-- REPLACE with inline logo-dark.svg or <img src="logo-dark.svg"> -->
        <img src="logo-dark.svg" class="nav-logo" alt="Logo dark">
        <div class="nav-links">
          <span>Products</span><span>Pricing</span><span>Docs</span><span>Blog</span>
        </div>
      </div>
      <div class="nav-light">
        <img src="logo-light.svg" class="nav-logo" alt="Logo light">
        <div class="nav-links">
          <span>Products</span><span>Pricing</span><span>Docs</span><span>Blog</span>
        </div>
      </div>
    </div>
  </div>

  <!-- ── Section 2: Browser Frame ── -->
  <div class="section">
    <div class="section-label">Browser Frame</div>
    <div class="browser-frame">
      <div class="browser-chrome">
        <div class="browser-dots">
          <span style="background:#FC5F57"></span>
          <span style="background:#FDBC2C"></span>
          <span style="background:#25C940"></span>
        </div>
        <div class="browser-url">https://[brandname].com</div>
      </div>
      <div class="browser-content">
        <img src="logo-dark.svg" alt="Logo in browser">
      </div>
    </div>
  </div>

  <!-- ── Section 3: Mobile Splash ── -->
  <div class="section">
    <div class="section-label">Mobile Splash Screen</div>
    <div class="mobile-wrap">
      <div class="mobile-frame">
        <div class="mobile-status"></div>
        <div class="mobile-screen">
          <img src="logo-icon-dark.svg" alt="App icon">
        </div>
        <div class="mobile-home">
          <div class="mobile-home-bar"></div>
        </div>
      </div>
    </div>
  </div>

  <!-- ── Section 4: Favicon Sizes ── -->
  <div class="section">
    <div class="section-label">Favicon Sizes (Dark &amp; Light)</div>
    <div class="favicon-grid">
      <div class="favicon-item">
        <div class="favicon-bg-dark"><img src="logo-icon-dark.svg" width="64" height="64" alt="64px dark"></div>
        <span class="favicon-label">64px dark</span>
      </div>
      <div class="favicon-item">
        <div class="favicon-bg-dark"><img src="logo-icon-dark.svg" width="32" height="32" alt="32px dark"></div>
        <span class="favicon-label">32px dark</span>
      </div>
      <div class="favicon-item">
        <div class="favicon-bg-dark"><img src="logo-icon-dark.svg" width="16" height="16" alt="16px dark"></div>
        <span class="favicon-label">16px dark</span>
      </div>
      <div class="favicon-item">
        <div class="favicon-bg-light"><img src="logo-icon-light.svg" width="64" height="64" alt="64px light"></div>
        <span class="favicon-label">64px light</span>
      </div>
      <div class="favicon-item">
        <div class="favicon-bg-light"><img src="logo-icon-light.svg" width="32" height="32" alt="32px light"></div>
        <span class="favicon-label">32px light</span>
      </div>
      <div class="favicon-item">
        <div class="favicon-bg-light"><img src="logo-icon-light.svg" width="16" height="16" alt="16px light"></div>
        <span class="favicon-label">16px light</span>
      </div>
    </div>
  </div>

  <!-- ── Section 5: Footer ── -->
  <div class="section">
    <div class="section-label">Footer Placement</div>
    <div class="footer-dark">
      <img src="logo-dark.svg" alt="Logo footer">
      <span class="footer-copy">© 2026 [BrandName]. All rights reserved.</span>
    </div>
  </div>

  <!-- ── Section 6: Brand Colors ── -->
  <div class="section">
    <div class="section-label">Brand Color Palette</div>
    <div class="palette">
      <!-- Repeat one .swatch per brand color -->
      <div class="swatch">
        <div class="swatch-color" style="background:#0B1120"></div>
        <div class="swatch-name">Night</div>
        <div class="swatch-hex">#0B1120</div>
      </div>
      <!-- Add primary, secondary, accent, neutral colors here -->
    </div>
  </div>

</body>
</html>
```

## Notes
- All `<img src="...">` paths are relative — files must be in the same `tinker/` directory.
- For guaranteed rendering in Claude.ai downloads, consider inlining SVG content directly.
- Replace `[BrandName]` throughout with the actual brand name.
- The color palette section should reflect the actual brand colors extracted from the final logo.
