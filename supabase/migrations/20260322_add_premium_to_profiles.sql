-- Migration: Add premium fields to profiles table
-- Run in Supabase Dashboard > SQL Editor

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS is_premium        BOOLEAN      DEFAULT false,
  ADD COLUMN IF NOT EXISTS premium_tier      TEXT,
  ADD COLUMN IF NOT EXISTS premium_started_at TIMESTAMPTZ;

-- Update RLS policy to allow users to read their own premium status
-- (profiles already has RLS — this just documents the expectation)
-- Existing policy "Users can read own profile" covers these new columns automatically.

-- Optional: index for querying premium users
CREATE INDEX IF NOT EXISTS idx_profiles_is_premium ON profiles(is_premium) WHERE is_premium = true;
