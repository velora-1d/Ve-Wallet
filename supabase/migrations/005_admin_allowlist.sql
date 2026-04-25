-- 005_admin_allowlist.sql
-- Kelola akun admin lewat allowlist email, bukan hardcoded di trigger.

CREATE TABLE IF NOT EXISTS public.admin_allowlist (
    email TEXT PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.admin_allowlist ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE id = auth.uid() AND role = 'admin'
    );
END;
$$;

DROP POLICY IF EXISTS "Admins can view admin allowlist" ON public.admin_allowlist;
CREATE POLICY "Admins can view admin allowlist" ON public.admin_allowlist
    FOR SELECT
    USING (public.is_admin());

DROP POLICY IF EXISTS "Service role can manage admin allowlist" ON public.admin_allowlist;
CREATE POLICY "Service role can manage admin allowlist" ON public.admin_allowlist
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

CREATE OR REPLACE FUNCTION public.is_admin_email(p_email TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.admin_allowlist
        WHERE lower(email) = lower(trim(COALESCE(p_email, '')))
    );
$$;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, avatar_url, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        NEW.raw_user_meta_data->>'avatar_url',
        CASE
            WHEN public.is_admin_email(NEW.email) THEN 'admin'
            ELSE 'user'
        END
    )
    ON CONFLICT (id) DO UPDATE
    SET
        full_name = EXCLUDED.full_name,
        avatar_url = EXCLUDED.avatar_url,
        role = CASE
            WHEN public.is_admin_email(NEW.email) THEN 'admin'
            ELSE public.profiles.role
        END;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

CREATE OR REPLACE FUNCTION public.promote_user_to_admin(p_email TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    normalized_email TEXT := lower(trim(COALESCE(p_email, '')));
BEGIN
    IF normalized_email = '' THEN
        RAISE EXCEPTION 'Email admin tidak boleh kosong';
    END IF;

    INSERT INTO public.admin_allowlist (email)
    VALUES (normalized_email)
    ON CONFLICT (email) DO NOTHING;

    UPDATE public.profiles AS p
    SET
        role = 'admin',
        updated_at = NOW()
    FROM auth.users AS u
    WHERE p.id = u.id
      AND lower(u.email) = normalized_email;
END;
$$;

CREATE OR REPLACE FUNCTION public.demote_user_from_admin(p_email TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    normalized_email TEXT := lower(trim(COALESCE(p_email, '')));
BEGIN
    IF normalized_email = '' THEN
        RAISE EXCEPTION 'Email admin tidak boleh kosong';
    END IF;

    DELETE FROM public.admin_allowlist
    WHERE lower(email) = normalized_email;

    UPDATE public.profiles AS p
    SET
        role = 'user',
        updated_at = NOW()
    FROM auth.users AS u
    WHERE p.id = u.id
      AND lower(u.email) = normalized_email;
END;
$$;

-- Backfill profile yang belum ada untuk user existing.
INSERT INTO public.profiles (id, full_name, avatar_url, role)
SELECT
    u.id,
    COALESCE(u.raw_user_meta_data->>'full_name', u.email),
    u.raw_user_meta_data->>'avatar_url',
    CASE
        WHEN public.is_admin_email(u.email) THEN 'admin'
        ELSE 'user'
    END
FROM auth.users AS u
LEFT JOIN public.profiles AS p
    ON p.id = u.id
WHERE p.id IS NULL;

-- Promote user existing yang email-nya sudah ada di allowlist.
UPDATE public.profiles AS p
SET
    role = 'admin',
    updated_at = NOW()
FROM auth.users AS u
JOIN public.admin_allowlist AS a
    ON lower(a.email) = lower(u.email)
WHERE p.id = u.id
  AND p.role <> 'admin';
