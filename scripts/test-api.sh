#!/bin/bash
#
# test-api.sh — Test all backend API endpoints for Hey Cape Cod
#
# Usage:
#   ./scripts/test-api.sh [--verbose]
#
# Environment variables:
#   BASE_URL      Base URL of the API (default: https://v0-cape-cod-ai-travel-assistant.vercel.app)
#   AUTH_TOKEN    Bearer token for authenticated endpoints (optional)
#

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
BASE_URL="${BASE_URL:-https://v0-cape-cod-ai-travel-assistant.vercel.app}"
AUTH_TOKEN="${AUTH_TOKEN:-}"
VERBOSE=false

for arg in "$@"; do
  case "$arg" in
    --verbose) VERBOSE=true ;;
  esac
done

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
RESET="\033[0m"

# ---------------------------------------------------------------------------
# Counters
# ---------------------------------------------------------------------------
PASS=0
FAIL=0
SKIP=0

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# run_test <label> <method> <url> [expected_status] [body]
#   expected_status defaults to 200
run_test() {
  local label="$1"
  local method="$2"
  local url="$3"
  local expected="${4:-200}"
  local body="${5:-}"

  local tmpfile
  tmpfile=$(mktemp)

  local curl_args=(-s -o "$tmpfile" -w "%{http_code}" -X "$method")

  if [[ -n "$body" ]]; then
    curl_args+=(-H "Content-Type: application/json" -d "$body")
  fi

  if [[ -n "$AUTH_TOKEN" ]]; then
    curl_args+=(-H "Authorization: Bearer $AUTH_TOKEN")
  fi

  local status
  status=$(curl "${curl_args[@]}" "$url" 2>/dev/null) || status="000"

  if [[ "$status" == "$expected" ]]; then
    printf "${GREEN}PASS${RESET}  %-50s  HTTP %s\n" "$label" "$status"
    PASS=$((PASS + 1))
  else
    printf "${RED}FAIL${RESET}  %-50s  HTTP %s (expected %s)\n" "$label" "$status" "$expected"
    FAIL=$((FAIL + 1))
  fi

  if $VERBOSE; then
    echo "  Response body:"
    cat "$tmpfile" | head -c 2000
    echo
    echo
  fi

  rm -f "$tmpfile"
}

skip_test() {
  local label="$1"
  local reason="$2"
  printf "${YELLOW}SKIP${RESET}  %-50s  %s\n" "$label" "$reason"
  SKIP=$((SKIP + 1))
}

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
echo "=============================================="
echo "  Hey Cape Cod — API Endpoint Tests"
echo "  Base URL: $BASE_URL"
echo "=============================================="
echo

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

# 1. Health check
run_test "GET /api/health" GET "${BASE_URL}/api/health"

# 2. List all POIs
run_test "GET /api/pois" GET "${BASE_URL}/api/pois"

# 3. Nearby POIs
run_test "GET /api/pois/nearby" GET "${BASE_URL}/api/pois/nearby?lat=41.7&lng=-70.3&radius=10000"

# 4. POI detail (use a placeholder id; expect 200 or 404)
run_test "GET /api/pois/:id" GET "${BASE_URL}/api/pois/1"

# 5. List stories
run_test "GET /api/stories" GET "${BASE_URL}/api/stories"

# 6. Story detail
run_test "GET /api/stories/:id" GET "${BASE_URL}/api/stories/1"

# 7. Weather data
run_test "GET /api/weather" GET "${BASE_URL}/api/weather?lat=41.7&lng=-70.3"

# 8. Tide predictions
run_test "GET /api/weather/tides" GET "${BASE_URL}/api/weather/tides?station=8447930"

# 9. Traffic / bridge status
run_test "GET /api/traffic" GET "${BASE_URL}/api/traffic"

# 10. AI chat (requires auth)
if [[ -n "$AUTH_TOKEN" ]]; then
  run_test "POST /api/chat" POST "${BASE_URL}/api/chat" 200 '{"message":"test","mode":"adult"}'
else
  skip_test "POST /api/chat" "no AUTH_TOKEN provided"
fi

# 11. User profile sync (requires auth + uid)
if [[ -n "$AUTH_TOKEN" ]]; then
  run_test "PUT /api/users/:uid" PUT "${BASE_URL}/api/users/test-user" 200 '{"displayName":"Test User"}'
else
  skip_test "PUT /api/users/:uid" "no AUTH_TOKEN provided"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo
echo "----------------------------------------------"
printf "  Results: ${GREEN}%d passed${RESET}, ${RED}%d failed${RESET}, ${YELLOW}%d skipped${RESET}\n" "$PASS" "$FAIL" "$SKIP"
echo "----------------------------------------------"

# Exit with non-zero if any test failed
[[ "$FAIL" -eq 0 ]]
