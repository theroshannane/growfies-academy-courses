#!/bin/sh
set -e
echo "=== STARTING GROWFIES ACADEMY DEPLOYMENT ==="

TARGET="/var/www/growfies-static"

# 1. Copy files to target root
echo "Copying root files to $TARGET..."
cp -v /src/*.html "$TARGET/"

# 2. Copy courses directory
echo "Copying courses directory to $TARGET/courses..."
mkdir -p "$TARGET/courses"
cp -rv /src/courses/* "$TARGET/courses/"

# 3. Check and update redirects.map
if [ -f "$TARGET/redirects.map" ]; then
    echo "Inspecting redirects.map for /courses redirect..."
    grep -i "courses" "$TARGET/redirects.map" || echo "No /courses found in redirects.map"
    # Comment out any redirect from /courses
    sed -i -E "s|^([[:space:]]*[^#[:space:]]*courses[^\;]*\;)|# disabled for academy: \1|g" "$TARGET/redirects.map"
    echo "Updated redirects.map:"
    grep -i "courses" "$TARGET/redirects.map" || true
fi

# 4. Set permissions
chmod -R 755 "$TARGET/courses"
chmod 644 "$TARGET"/*.html

echo "=== DEPLOYMENT COMPLETED SUCCESSFULLY ==="
ls -la "$TARGET/courses"
