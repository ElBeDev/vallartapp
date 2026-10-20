-- Migration: Row Level Security hardening before App Store launch
--
-- Before this, RLS was OFF on listings, events, profiles and reviews, so anyone
-- holding the public (publishable) key shipped in the iOS app could rewrite or
-- delete them. The admin panel writes with the signed-in user's session (not the
-- service role), so admins are recognised through public.admin_users.

-- ── 1. Admin registry ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.admin_users (
  email      text PRIMARY KEY,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;  -- no policies: invisible to clients
INSERT INTO public.admin_users (email) VALUES ('elbedev90@gmail.com') ON CONFLICT DO NOTHING;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_users
    WHERE lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;
REVOKE ALL ON FUNCTION public.is_admin() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_admin() TO anon, authenticated;

-- ── 2. business_owners ──────────────────────────────────────
-- The business portal reads listing_id; the live table only had listing_ids.
ALTER TABLE public.business_owners
  ADD COLUMN IF NOT EXISTS listing_id uuid REFERENCES public.listings(id) ON DELETE SET NULL;

-- Owners could rewrite their own row (e.g. point it at any listing). Admin-only now.
DROP POLICY IF EXISTS "Owner can update own record" ON public.business_owners;
DROP POLICY IF EXISTS "Admin manages business owners" ON public.business_owners;
CREATE POLICY "Admin manages business owners" ON public.business_owners
  FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE OR REPLACE FUNCTION public.owns_listing(lid uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.business_owners bo
    WHERE bo.user_id = auth.uid()
      AND coalesce(bo.is_active, true)
      AND (bo.listing_id = lid OR lid = ANY (coalesce(bo.listing_ids, '{}')))
  );
$$;
REVOKE ALL ON FUNCTION public.owns_listing(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.owns_listing(uuid) TO authenticated;

-- ── 3. listings ─────────────────────────────────────────────
ALTER TABLE public.listings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Listings are public"        ON public.listings;
DROP POLICY IF EXISTS "Admin writes listings"      ON public.listings;
DROP POLICY IF EXISTS "Owner updates own listing"  ON public.listings;
CREATE POLICY "Listings are public" ON public.listings
  FOR SELECT USING (true);
CREATE POLICY "Admin writes listings" ON public.listings
  FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Owner updates own listing" ON public.listings
  FOR UPDATE TO authenticated USING (public.owns_listing(id)) WITH CHECK (public.owns_listing(id));

-- Owners may edit their info and photos, not ranking fields.
CREATE OR REPLACE FUNCTION public.protect_listing_columns()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF coalesce(auth.jwt() ->> 'role', '') = 'authenticated' AND NOT public.is_admin() THEN
    NEW.id           := OLD.id;
    NEW.rating       := OLD.rating;
    NEW.review_count := OLD.review_count;
    NEW.is_featured  := OLD.is_featured;
    NEW.is_premium   := OLD.is_premium;
    NEW.created_at   := OLD.created_at;
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS protect_listing_columns ON public.listings;
CREATE TRIGGER protect_listing_columns BEFORE UPDATE ON public.listings
  FOR EACH ROW EXECUTE FUNCTION public.protect_listing_columns();

-- ── 4. events ───────────────────────────────────────────────
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Events are public"   ON public.events;
DROP POLICY IF EXISTS "Admin writes events" ON public.events;
CREATE POLICY "Events are public" ON public.events
  FOR SELECT USING (true);
CREATE POLICY "Admin writes events" ON public.events
  FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ── 5. reviews ──────────────────────────────────────────────
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Reviews are public"            ON public.reviews;
DROP POLICY IF EXISTS "Users write own reviews"       ON public.reviews;
DROP POLICY IF EXISTS "Users edit own reviews"        ON public.reviews;
DROP POLICY IF EXISTS "Users or admin delete reviews" ON public.reviews;
CREATE POLICY "Reviews are public" ON public.reviews
  FOR SELECT USING (true);
CREATE POLICY "Users write own reviews" ON public.reviews
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users edit own reviews" ON public.reviews
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users or admin delete reviews" ON public.reviews
  FOR DELETE TO authenticated USING (user_id = auth.uid() OR public.is_admin());

-- ── 6. profiles ─────────────────────────────────────────────
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users read own profile"   ON public.profiles;
DROP POLICY IF EXISTS "Users create own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admin manages profiles"   ON public.profiles;
CREATE POLICY "Users read own profile" ON public.profiles
  FOR SELECT TO authenticated USING (id = auth.uid());
CREATE POLICY "Users create own profile" ON public.profiles
  FOR INSERT TO authenticated WITH CHECK (id = auth.uid());
CREATE POLICY "Users update own profile" ON public.profiles
  FOR UPDATE TO authenticated USING (id = auth.uid()) WITH CHECK (id = auth.uid());
CREATE POLICY "Admin manages profiles" ON public.profiles
  FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Status flags are set by admins only.
CREATE OR REPLACE FUNCTION public.protect_profile_columns()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF coalesce(auth.jwt() ->> 'role', '') = 'authenticated' AND NOT public.is_admin() THEN
    IF TG_OP = 'INSERT' THEN
      NEW.is_business_owner  := false;
      NEW.is_premium         := false;
      NEW.premium_tier       := NULL;
      NEW.premium_started_at := NULL;
    ELSE
      NEW.is_business_owner  := OLD.is_business_owner;
      NEW.is_premium         := OLD.is_premium;
      NEW.premium_tier       := OLD.premium_tier;
      NEW.premium_started_at := OLD.premium_started_at;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS protect_profile_columns ON public.profiles;
CREATE TRIGGER protect_profile_columns BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.protect_profile_columns();

-- ── 7. notifications ────────────────────────────────────────
DROP POLICY IF EXISTS "User reads own and broadcast" ON public.notifications;  -- duplicate
DROP POLICY IF EXISTS "Admin manages notifications"  ON public.notifications;
CREATE POLICY "Admin manages notifications" ON public.notifications
  FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ── 8. Storage (both buckets are public-read) ───────────────
-- Until now there were no write policies at all, so every upload failed.
DROP POLICY IF EXISTS "Admin writes app buckets"         ON storage.objects;
DROP POLICY IF EXISTS "Users manage own avatar"          ON storage.objects;
DROP POLICY IF EXISTS "Owners upload own listing photos" ON storage.objects;
CREATE POLICY "Admin writes app buckets" ON storage.objects
  FOR ALL TO authenticated
  USING (bucket_id IN ('photos', 'listings') AND public.is_admin())
  WITH CHECK (bucket_id IN ('photos', 'listings') AND public.is_admin());
-- iOS uploads avatars/<uid>.jpg with upsert, which needs select + insert + update.
CREATE POLICY "Users manage own avatar" ON storage.objects
  FOR ALL TO authenticated
  USING (bucket_id = 'listings' AND name = 'avatars/' || auth.uid()::text || '.jpg')
  WITH CHECK (bucket_id = 'listings' AND name = 'avatars/' || auth.uid()::text || '.jpg');
-- Business portal uploads listings/<listing_id>_<timestamp>_<rand>.<ext>
CREATE POLICY "Owners upload own listing photos" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'listings'
    AND name LIKE 'listings/%\_%'
    AND public.owns_listing(
      CASE WHEN split_part(substr(name, 10), '_', 1) ~ '^[0-9a-f-]{36}$'
           THEN split_part(substr(name, 10), '_', 1)::uuid END
    )
  );
