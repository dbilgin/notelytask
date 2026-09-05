#!/usr/bin/env bash
set -euo pipefail

: "${DOKPLOY_API_KEY:?Missing DOKPLOY_API_KEY}"
: "${DOKPLOY_URL:?Missing DOKPLOY_URL}"
: "${DOKPLOY_APPLICATION_ID:?Missing DOKPLOY_APPLICATION_ID}"
: "${WEB_IMAGE:?Missing WEB_IMAGE}"
: "${GITHUB_SHA:?Missing GITHUB_SHA}"

post() {
  curl --fail --silent --show-error --connect-timeout 15 --max-time 120 \
    -H "x-api-key: $DOKPLOY_API_KEY" \
    -H 'Content-Type: application/json' \
    --data-binary @- "$DOKPLOY_URL/api/$1" > /dev/null
}

# Public images need no credentials. Private GHCR images need a persistent
# read:packages token; the Actions GITHUB_TOKEN expires after the job.
registry_username=''
if [[ -n "${GHCR_READ_TOKEN:-}" ]]; then
  registry_username="${GHCR_USERNAME:?Missing GHCR_USERNAME}"
fi
jq -n --arg applicationId "$DOKPLOY_APPLICATION_ID" \
  --arg dockerImage "$WEB_IMAGE" \
  --arg username "$registry_username" --arg password "${GHCR_READ_TOKEN:-}" \
  '{applicationId: $applicationId, dockerImage: $dockerImage,
    username: $username, password: $password, registryUrl: "ghcr.io"}' \
  | post application.saveDockerProvider

jq -n --arg applicationId "$DOKPLOY_APPLICATION_ID" \
  '{applicationId: $applicationId}' | post application.deploy

# Verify the actual release at the public endpoint, not just API acceptance.
for attempt in {1..60}; do
  deployed=$(curl --fail --silent --connect-timeout 5 --max-time 10 \
    "https://notelytask.dbilgin.com/release.txt?attempt=$attempt" || true)
  if [[ "$deployed" == "$GITHUB_SHA" ]]; then
    echo 'Dokploy is serving the released web app.'
    exit 0
  fi
  sleep 10
done
echo 'Timed out waiting for Dokploy to serve the new release.' >&2
exit 1
