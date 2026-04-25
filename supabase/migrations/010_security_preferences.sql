-- 010_security_preferences.sql
-- Menyimpan preferensi keamanan akun per user.

ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS pin_hash TEXT,
    ADD COLUMN IF NOT EXISTS pin_enabled BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS biometric_enabled BOOLEAN NOT NULL DEFAULT false;

UPDATE public.profiles
SET
    language = COALESCE(NULLIF(language, ''), 'id'),
    theme = COALESCE(NULLIF(theme, ''), 'system'),
    pin_enabled = COALESCE(pin_enabled, false),
    biometric_enabled = COALESCE(biometric_enabled, false)
WHERE true;
