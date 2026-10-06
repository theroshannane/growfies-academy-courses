#!/bin/bash
set -e
echo "=== STARTING GROWFIES ACADEMY DEPLOYMENT ==="

TARGET="/var/www/growfies-static"
if [ ! -d "$TARGET" ] && [ -d "/target" ]; then
    TARGET="/target"
fi

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Using repo dir: $REPO_DIR"
echo "Target dir: $TARGET"

# 1. Copy root files to target root
echo "Copying root files to $TARGET..."
cp -v "$REPO_DIR"/*.html "$TARGET/" 2>/dev/null || true

# 2. Copy courses directory
echo "Copying courses directory to $TARGET/courses..."
mkdir -p "$TARGET/courses"
cp -rv "$REPO_DIR"/courses/* "$TARGET/courses/"

# 3. Copy assets directory
if [ -d "$REPO_DIR/courses/assets" ]; then
    echo "Copying courses assets to $TARGET/assets..."
    mkdir -p "$TARGET/assets"
    cp -rv "$REPO_DIR"/courses/assets/* "$TARGET/assets/"
fi

# 4. Check and update redirects.map
if [ -f "$TARGET/redirects.map" ]; then
    echo "Inspecting redirects.map for /courses redirect..."
    grep -i "courses" "$TARGET/redirects.map" || echo "No /courses found in redirects.map"
    sed -i -E "s|^([[:space:]]*[^#[:space:]]*courses[^\;]*\;)|# disabled for academy: \1|g" "$TARGET/redirects.map"
    echo "Updated redirects.map:"
    grep -i "courses" "$TARGET/redirects.map" || true
fi

# 5. Inject Academy Link into Homepage Navigation
if [ -f "$TARGET/index.html" ]; then
    echo "Checking $TARGET/index.html navigation..."
    node -e '
    const fs = require("fs");
    const p = process.argv[1];
    if (fs.existsSync(p)) {
      let html = fs.readFileSync(p, "utf8");
      
      if (!html.includes("/courses/\"") && html.includes("<a href=\"/pricing/\" class=\"gf-menu-link\">Pricing</a>")) {
        const academyLink = `<a href="/pricing/" class=\"gf-menu-link\">Pricing</a>\n      <a href="/courses/" class=\"gf-menu-link\" style=\"font-weight:700;color:#0284C7;display:inline-flex;align-items:center;gap:6px\">Academy <span style=\"background:rgba(2,132,199,0.12);color:#0284C7;font-size:10px;font-weight:800;padding:2px 7px;border-radius:999px;letter-spacing:0.02em\">100% Live</span></a>`;
        html = html.replace("<a href=\"/pricing/\" class=\"gf-menu-link\">Pricing</a>", academyLink);
        console.log("Injected Academy into desktop nav");
      }
      
      if (!html.includes("Growfies Academy · MarketInc") && html.includes("<!-- Section 3: Resources & Pricing -->")) {
        const drawerSec = `<!-- Section: Academy -->\n    <div class=\"gf-drawer-sec\">\n      <span class=\"gf-drawer-title\">Growfies Academy · MarketInc</span>\n      <a href=\"/courses/\" class=\"gf-drawer-link\" style=\"color:#0284C7;font-weight:700\">🎓 All Live Programs (100% Online)</a>\n      <a href=\"/courses/postgraduate-ai-digital-marketing/\" class=\"gf-drawer-link\">⭐ PG in AI Marketing & MarTech (6 Mo)</a>\n      <a href=\"/courses/performance-marketing/\" class=\"gf-drawer-link\">📈 Performance & Paid Media (3 Mo)</a>\n      <a href=\"/courses/agentic-ai-marketing-systems/\" class=\"gf-drawer-link\">🤖 Agentic AI & Vibe Coding (4 Mo)</a>\n      <a href=\"/courses/undergraduate-digital-business/\" class=\"gf-drawer-link\">🏛️ Undergraduate Degree Track (3 Yr)</a>\n      <a href=\"/courses/executive-ai-sprint/\" class=\"gf-drawer-link\">⚡ Executive Growth Sprint (6 Wk)</a>\n    </div>\n\n    <!-- Section 3: Resources & Pricing -->`;
        html = html.replace("<!-- Section 3: Resources & Pricing -->", drawerSec);
        console.log("Injected Academy into mobile drawer");
      }

      if (!html.includes("Academy (Live)") && html.includes("<a href=\"/pricing/\">Pricing</a></div>")) {
        html = html.replace("<a href=\"/pricing/\">Pricing</a></div>", "<a href=\"/pricing/\">Pricing</a><a href=\"/courses/\" style=\"color:#0284C7;font-weight:700\">Academy (Live)</a></div>");
        console.log("Injected Academy into footer");
      }
      
      fs.writeFileSync(p, html);
      console.log("Successfully updated homepage navigation in " + p);
    }
    ' "$TARGET/index.html"
fi

# 6. Set permissions
chmod -R 755 "$TARGET/courses" "$TARGET/assets" 2>/dev/null || true
chmod 644 "$TARGET"/*.html 2>/dev/null || true

echo "=== DEPLOYMENT SUCCEEDED ==="
ls -la "$TARGET/courses"
