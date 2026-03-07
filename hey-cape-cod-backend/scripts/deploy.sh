#!/bin/bash
# Full deployment pipeline: test → staging → smoke test → production
#
# Usage: ./scripts/deploy.sh
# Requirements: vercel CLI, node 18+

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "======================================"
echo "  Hey Cape Cod — Deployment Pipeline"
echo "======================================"
echo ""

# Step 1: Run unit tests
echo -e "${YELLOW}Step 1/5: Running unit tests...${NC}"
npm test
if [ $? -ne 0 ]; then
  echo -e "${RED}Unit tests failed. Aborting deployment.${NC}"
  exit 1
fi
echo -e "${GREEN}Unit tests passed.${NC}"
echo ""

# Step 2: Deploy to staging
echo -e "${YELLOW}Step 2/5: Deploying to staging...${NC}"
STAGING_OUTPUT=$(npx vercel --confirm 2>&1)
STAGING_URL=$(echo "$STAGING_OUTPUT" | grep -oE 'https://[a-zA-Z0-9._-]+\.vercel\.app' | head -1)

if [ -z "$STAGING_URL" ]; then
  echo -e "${RED}Failed to extract staging URL. Output:${NC}"
  echo "$STAGING_OUTPUT"
  exit 1
fi

echo -e "${GREEN}Staging deployed: ${STAGING_URL}${NC}"
echo ""

# Step 3: Wait for deployment to be ready
echo -e "${YELLOW}Step 3/5: Waiting for staging to be ready...${NC}"
MAX_RETRIES=30
RETRY_DELAY=5
for i in $(seq 1 $MAX_RETRIES); do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${STAGING_URL}/api/health" 2>/dev/null || echo "000")
  if [ "$STATUS" = "200" ] || [ "$STATUS" = "503" ]; then
    echo -e "${GREEN}Staging is ready (HTTP ${STATUS}).${NC}"
    break
  fi
  if [ "$i" = "$MAX_RETRIES" ]; then
    echo -e "${RED}Staging not ready after ${MAX_RETRIES} attempts. Aborting.${NC}"
    exit 1
  fi
  echo "  Attempt ${i}/${MAX_RETRIES}: HTTP ${STATUS}, waiting ${RETRY_DELAY}s..."
  sleep $RETRY_DELAY
done
echo ""

# Step 4: Run smoke tests against staging
echo -e "${YELLOW}Step 4/5: Running smoke tests against staging...${NC}"
STAGING_URL="${STAGING_URL}" node tests/smoke.test.js
if [ $? -ne 0 ]; then
  echo -e "${RED}Smoke tests failed. NOT promoting to production.${NC}"
  echo -e "${YELLOW}Staging URL (for debugging): ${STAGING_URL}${NC}"
  exit 1
fi
echo -e "${GREEN}Smoke tests passed.${NC}"
echo ""

# Step 5: Promote to production
echo -e "${YELLOW}Step 5/5: Promoting to production...${NC}"
npx vercel --prod --confirm
if [ $? -ne 0 ]; then
  echo -e "${RED}Production deployment failed.${NC}"
  exit 1
fi

echo ""
echo "======================================"
echo -e "  ${GREEN}Deployment Complete!${NC}"
echo "======================================"
echo ""
echo "  Staging:    ${STAGING_URL}"
echo "  Production: https://v0-cape-cod-ai-travel-assistant.vercel.app"
echo ""
echo "  Verify: curl https://v0-cape-cod-ai-travel-assistant.vercel.app/api/health"
echo ""
