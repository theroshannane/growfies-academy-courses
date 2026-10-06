#!/bin/sh
set -e
echo "=== STARTING GROWFIES ACADEMY DEPLOYMENT ==="

TARGET="/var/www/growfies-static"

# 1. Copy root files to target root
echo "Copying root files to $TARGET..."
cp -v /src/*.html "$TARGET/" 2>/dev/null || true

# 2. Copy courses directory
echo "Copying courses directory to $TARGET/courses..."
mkdir -p "$TARGET/courses"
cp -rv /src/courses/* "$TARGET/courses/"

# 3. Copy assets directory
if [ -d "/src/courses/assets" ]; then
    echo "Copying courses assets to $TARGET/assets..."
    mkdir -p "$TARGET/assets"
    cp -rv /src/courses/assets/* "$TARGET/assets/"
fi

# 4. Check and update redirects.map
if [ -f "$TARGET/redirects.map" ]; then
    echo "Inspecting redirects.map for /courses redirect..."
    grep -i "courses" "$TARGET/redirects.map" || echo "No /courses found in redirects.map"
    sed -i -E "s|^([[:space:]]*[^#[:space:]]*courses[^\;]*\;)|# disabled for academy: \1|g" "$TARGET/redirects.map"
    echo "Updated redirects.map:"
    grep -i "courses" "$TARGET/redirects.map" || true
fi

# 5. Set permissions
chmod -R 755 "$TARGET/courses" "$TARGET/assets" 2>/dev/null || true
chmod 644 "$TARGET"/*.html 2>/dev/null || true

echo "=== DEPLOYMENT COMPLETED SUCCESSFULLY ==="
ls -la "$TARGET/courses"
