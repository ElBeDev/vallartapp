#!/bin/bash
# deploy-edge-function.sh
# Run this once with your Supabase personal access token.
# Get it from: https://supabase.com/dashboard/account/tokens
#
# Usage:
#   export SUPABASE_PAT=sbp_xxxxxxxxxxxx
#   export STRIPE_SECRET_KEY=sk_test_... (or sk_live_...)
#   bash scripts/deploy-edge-function.sh

set -e

PROJECT_REF="nvubaobivraevlnlpsjr"
PAT="${SUPABASE_PAT}"
STRIPE_SECRET="${STRIPE_SECRET_KEY}"

if [ -z "$PAT" ]; then
  echo "Error: SUPABASE_PAT not set."
  echo "Get your token from https://supabase.com/dashboard/account/tokens"
  exit 1
fi

if [ -z "$STRIPE_SECRET" ]; then
  echo "Error: STRIPE_SECRET_KEY not set."
  echo "Set it with: export STRIPE_SECRET_KEY=sk_test_..."
  exit 1
fi

echo "Setting STRIPE_SECRET_KEY secret..."
curl -s -X POST \
  "https://api.supabase.com/v1/projects/${PROJECT_REF}/secrets" \
  -H "Authorization: Bearer ${PAT}" \
  -H "Content-Type: application/json" \
  -d "[{\"name\":\"STRIPE_SECRET_KEY\",\"value\":\"${STRIPE_SECRET}\"}]"

echo ""
echo "Deploying create-payment-intent Edge Function..."
supabase functions deploy create-payment-intent \
  --project-ref "${PROJECT_REF}" \
  --access-token "${PAT}"

echo ""
echo "Done! Edge Function deployed."
