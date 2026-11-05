#!/bin/sh
set -eu
umask 077

fail() { printf '%s\n' "$1" >&2; exit 1; }

# Validate before creating files or starting the server. Never log secret values.
[ -n "${GLANCE_SECRET_KEY:-}" ] || fail 'Set GLANCE_SECRET_KEY before deploying.'
[ -n "${GLANCE_PASSWORD_HASH:-}" ] || fail 'Set GLANCE_PASSWORD_HASH before deploying.'
[ "${#GLANCE_PASSWORD_HASH}" -eq 60 ] || fail 'GLANCE_PASSWORD_HASH must be a 60-character bcrypt hash.'
[ "${#GLANCE_SECRET_KEY}" -eq 88 ] || fail 'GLANCE_SECRET_KEY must encode 64 random bytes as base64.'
printf '%s' "$GLANCE_SECRET_KEY" | grep -Eq '^[A-Za-z0-9+/]{86}==$' || fail 'GLANCE_SECRET_KEY has an invalid format.'
secret_bytes=$(printf '%s' "$GLANCE_SECRET_KEY" | base64 -d | wc -c)
[ "$secret_bytes" -eq 64 ] || fail 'GLANCE_SECRET_KEY must encode 64 bytes.'
printf '%s' "$GLANCE_PASSWORD_HASH" | grep -Eq '^\$2[aby]\$1[0-4]\$[./A-Za-z0-9]{53}$' || fail 'Use a bcrypt password hash with cost 10 through 14.'

export GLANCE_RSS_URL="${GLANCE_RSS_URL:-https://hnrss.org/frontpage}"
export GLANCE_BOOKMARK_URL="${GLANCE_BOOKMARK_URL:-https://github.com/glanceapp/glance}"
for url in "$GLANCE_RSS_URL" "$GLANCE_BOOKMARK_URL"; do
    # These values are inserted into YAML. Reject quoting/newline injection.
    printf '%s' "$url" | grep -Eq '^https://[A-Za-z0-9._~:/?#@!&()*+,;=%-]+$' || fail 'Use a single-line HTTPS URL without quotes or spaces.'
    case "$url" in *'
'*) fail 'URLs must not contain newlines.' ;; esac
done

# Mount /app/data through VibeNest before the first launch. Existing pages survive
# redeploys; authentication is always loaded from the image, outside that volume.
mkdir -p /app/data/assets
if [ ! -e /app/data/pages.yml ]; then
    cp /app/vibenest/pages.yml /app/data/pages.yml
fi
exec /app/glance --config /app/vibenest/glance.yml
