-- Migration: self-service account deletion (App Store guideline 5.1.1(v))
-- Called from iOS: supabase.rpc("delete_my_account")
-- Deletes the caller's auth user. On the live DB the FKs from profiles, reviews
-- and business_owners to auth.users are NO ACTION, so those rows go first.

CREATE OR REPLACE FUNCTION public.delete_my_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF to_regclass('public.device_tokens') IS NOT NULL THEN
    DELETE FROM public.device_tokens WHERE user_id = uid;
  END IF;
  IF to_regclass('public.notifications') IS NOT NULL THEN
    DELETE FROM public.notifications WHERE user_id = uid;
  END IF;
  DELETE FROM public.business_owners WHERE user_id = uid;
  DELETE FROM public.reviews         WHERE user_id = uid;
  DELETE FROM public.profiles        WHERE id = uid;

  DELETE FROM auth.users WHERE id = uid;
END;
$$;

REVOKE ALL ON FUNCTION public.delete_my_account() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.delete_my_account() TO authenticated;
