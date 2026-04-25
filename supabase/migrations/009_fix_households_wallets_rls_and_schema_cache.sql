-- 009_fix_households_wallets_rls_and_schema_cache.sql
-- Fix:
-- 1. households RLS forbidden 42501
-- 2. wallets schema cache / missing user_id
-- 3. insert/update gagal di households dan wallets
-- 4. menjaga flow shared account tetap jalan

ALTER TABLE public.households
    ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE public.wallets
    ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;

CREATE OR REPLACE FUNCTION public.is_household_member(
    p_household_id UUID,
    p_user_id UUID DEFAULT auth.uid()
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.household_members
        WHERE household_id = p_household_id
          AND user_id = COALESCE(p_user_id, auth.uid())
    );
$$;

-- Backfill households.user_id dari member paling awal jika belum ada.
WITH first_members AS (
    SELECT DISTINCT ON (hm.household_id)
        hm.household_id,
        hm.user_id
    FROM public.household_members hm
    ORDER BY hm.household_id, hm.joined_at ASC
)
UPDATE public.households h
SET user_id = fm.user_id
FROM first_members fm
WHERE h.id = fm.household_id
  AND h.user_id IS NULL;

-- Backfill wallets.user_id dari owner household jika belum ada.
UPDATE public.wallets w
SET user_id = h.user_id
FROM public.households h
WHERE h.id = w.household_id
  AND w.user_id IS NULL
  AND h.user_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_households_user_id
    ON public.households (user_id);

CREATE INDEX IF NOT EXISTS idx_wallets_user_id
    ON public.wallets (user_id);

-- HOUSEHOLDS RLS
DROP POLICY IF EXISTS "Users can create own households" ON public.households;
DROP POLICY IF EXISTS "Users can view own households" ON public.households;
DROP POLICY IF EXISTS "Users can update accessible households" ON public.households;
DROP POLICY IF EXISTS "Users can delete owned households" ON public.households;
DROP POLICY IF EXISTS "Members can view their households" ON public.households;

CREATE POLICY "Users can create own households" ON public.households
    FOR INSERT
    WITH CHECK (
        auth.uid() IS NOT NULL
        AND auth.uid() = user_id
    );

CREATE POLICY "Users can view own households" ON public.households
    FOR SELECT
    USING (
        auth.uid() IS NOT NULL
        AND (
            auth.uid() = user_id
            OR public.is_household_member(id)
        )
    );

CREATE POLICY "Users can update accessible households" ON public.households
    FOR UPDATE
    USING (
        auth.uid() IS NOT NULL
        AND (
            auth.uid() = user_id
            OR public.is_household_member(id)
        )
    )
    WITH CHECK (
        auth.uid() IS NOT NULL
        AND (
            auth.uid() = user_id
            OR public.is_household_member(id)
        )
    );

CREATE POLICY "Users can delete owned households" ON public.households
    FOR DELETE
    USING (
        auth.uid() IS NOT NULL
        AND auth.uid() = user_id
    );

-- HOUSEHOLD_MEMBERS RLS
DROP POLICY IF EXISTS "Users can join households as themselves" ON public.household_members;
DROP POLICY IF EXISTS "Users can leave their own household membership" ON public.household_members;
DROP POLICY IF EXISTS "Members can view household peers" ON public.household_members;

CREATE POLICY "Members can view household peers" ON public.household_members
    FOR SELECT
    USING (
        auth.uid() IS NOT NULL
        AND public.is_household_member(household_id)
    );

CREATE POLICY "Users can join households as themselves" ON public.household_members
    FOR INSERT
    WITH CHECK (
        auth.uid() IS NOT NULL
        AND auth.uid() = user_id
        AND EXISTS (
            SELECT 1
            FROM public.households h
            WHERE h.id = household_id
              AND (
                  h.user_id = auth.uid()
                  OR public.is_household_member(h.id)
              )
        )
    );

CREATE POLICY "Users can leave their own household membership" ON public.household_members
    FOR DELETE
    USING (
        auth.uid() IS NOT NULL
        AND auth.uid() = user_id
    );

-- WALLETS RLS
DROP POLICY IF EXISTS "Users can view accessible wallets" ON public.wallets;
DROP POLICY IF EXISTS "Users can create own wallets" ON public.wallets;
DROP POLICY IF EXISTS "Users can update accessible wallets" ON public.wallets;
DROP POLICY IF EXISTS "Users can delete accessible wallets" ON public.wallets;
DROP POLICY IF EXISTS "Members can access household wallets" ON public.wallets;

CREATE POLICY "Users can view accessible wallets" ON public.wallets
    FOR SELECT
    USING (
        auth.uid() IS NOT NULL
        AND (
            auth.uid() = user_id
            OR public.is_household_member(household_id)
        )
    );

CREATE POLICY "Users can create own wallets" ON public.wallets
    FOR INSERT
    WITH CHECK (
        auth.uid() IS NOT NULL
        AND auth.uid() = user_id
        AND public.is_household_member(household_id)
    );

CREATE POLICY "Users can update accessible wallets" ON public.wallets
    FOR UPDATE
    USING (
        auth.uid() IS NOT NULL
        AND (
            auth.uid() = user_id
            OR public.is_household_member(household_id)
        )
    )
    WITH CHECK (
        auth.uid() IS NOT NULL
        AND (
            auth.uid() = user_id
            OR public.is_household_member(household_id)
        )
    );

CREATE POLICY "Users can delete accessible wallets" ON public.wallets
    FOR DELETE
    USING (
        auth.uid() IS NOT NULL
        AND (
            auth.uid() = user_id
            OR public.is_household_member(household_id)
        )
    );

-- RPC untuk join household tanpa bocorin select policy invite_code.
CREATE OR REPLACE FUNCTION public.join_household_by_invite_code_v1(p_invite_code TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    current_user_id UUID := auth.uid();
    target_household_id UUID;
BEGIN
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'User belum login';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM public.household_members
        WHERE user_id = current_user_id
    ) THEN
        RAISE EXCEPTION 'Keluar dari shared account saat ini terlebih dahulu';
    END IF;

    SELECT id
    INTO target_household_id
    FROM public.households
    WHERE invite_code = UPPER(TRIM(COALESCE(p_invite_code, '')))
    LIMIT 1;

    IF target_household_id IS NULL THEN
        RAISE EXCEPTION 'Kode invite tidak ditemukan';
    END IF;

    INSERT INTO public.household_members (household_id, user_id)
    VALUES (target_household_id, current_user_id)
    ON CONFLICT (household_id, user_id) DO NOTHING;

    UPDATE public.households
    SET
        invite_code = NULL,
        invite_expiry = NULL,
        updated_at = NOW()
    WHERE id = target_household_id;
END;
$$;

NOTIFY pgrst, 'reload schema';
