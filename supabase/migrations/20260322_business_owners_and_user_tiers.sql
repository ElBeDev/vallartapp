-- Migration: Business owners table + user tier update
-- Run in Supabase Dashboard > SQL Editor

-- ============================================================
-- 1. business_owners table
--    One row per business owner account.
--    user_id references auth.users
-- ============================================================
CREATE TABLE IF NOT EXISTS business_owners (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan             TEXT NOT NULL DEFAULT 'free',
  -- plan values: 'free' | 'biz_standard' | 'biz_premium' | 'biz_standard_yearly' | 'biz_premium_yearly'
  plan_started_at  TIMESTAMPTZ,
  is_active        BOOLEAN NOT NULL DEFAULT false,
  business_name    TEXT,
  listing_id       UUID REFERENCES listings(id) ON DELETE SET NULL,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id)
);

-- RLS
ALTER TABLE business_owners ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owner can read own record"
  ON business_owners FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Owner can update own record"
  ON business_owners FOR UPDATE
  USING (auth.uid() = user_id);

-- Admin (service role) can do everything — handled by service key bypass

-- ============================================================
-- 2. Update profiles — rename premium_tier values to new scheme
--    Old: monthly_standard / monthly_premium / yearly_standard / yearly_premium
--    New (user): user_explorer / user_explorer_yearly
-- ============================================================

-- No data migration needed — existing test rows can stay.
-- New rows will use the new tier values.

-- ============================================================
-- 3. Index for fast lookup of active business owners by plan
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_business_owners_plan
  ON business_owners(plan) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_business_owners_user
  ON business_owners(user_id);

-- ============================================================
-- 4. View: enriched business owners (join with profiles)
-- ============================================================
CREATE OR REPLACE VIEW business_owners_view AS
  SELECT
    bo.*,
    p.name          AS owner_name,
    p.avatar_url,
    p.is_premium    AS owner_is_explorer
  FROM business_owners bo
  LEFT JOIN profiles p ON p.id::text = bo.user_id::text;
