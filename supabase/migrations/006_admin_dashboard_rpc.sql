-- 006_admin_dashboard_rpc.sql
-- RPC dashboard admin untuk mengambil agregat data secara aman.

CREATE OR REPLACE FUNCTION public.get_admin_dashboard_data_v1()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    result JSONB;
BEGIN
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Akses admin diperlukan';
    END IF;

    SELECT jsonb_build_object(
        'total_users', (
            SELECT COUNT(*)
            FROM public.profiles
        ),
        'active_today', (
            SELECT COUNT(*)
            FROM auth.users
            WHERE last_sign_in_at IS NOT NULL
              AND timezone('Asia/Jakarta', last_sign_in_at)::date = timezone('Asia/Jakarta', now())::date
        ),
        'total_transactions', (
            SELECT COUNT(*)
            FROM public.transactions
        ),
        'total_households', (
            SELECT COUNT(*)
            FROM public.households
        ),
        'growth', (
            SELECT COALESCE(
                jsonb_agg(
                    jsonb_build_object(
                        'label', label,
                        'value', value
                    )
                    ORDER BY sort_key
                ),
                '[]'::jsonb
            )
            FROM (
                SELECT
                    to_char(day_ref, 'Dy') AS label,
                    COUNT(p.id)::numeric AS value,
                    day_ref AS sort_key
                FROM generate_series(
                    timezone('Asia/Jakarta', now())::date - 6,
                    timezone('Asia/Jakarta', now())::date,
                    interval '1 day'
                ) AS day_ref
                LEFT JOIN public.profiles AS p
                    ON timezone('Asia/Jakarta', p.created_at)::date = day_ref::date
                GROUP BY day_ref
            ) AS growth_rows
        ),
        'activities', (
            SELECT COALESCE(
                jsonb_agg(
                    jsonb_build_object(
                        'title', title,
                        'description', description,
                        'time', to_char(timezone('Asia/Jakarta', happened_at), 'DD Mon HH24:MI')
                    )
                    ORDER BY happened_at DESC
                ),
                '[]'::jsonb
            )
            FROM (
                SELECT *
                FROM (
                    SELECT
                        'User Baru' AS title,
                        COALESCE(full_name, 'User baru') || ' bergabung ke aplikasi' AS description,
                        created_at AS happened_at
                    FROM public.profiles

                    UNION ALL

                    SELECT
                        'Household Baru' AS title,
                        name || ' dibuat' AS description,
                        created_at AS happened_at
                    FROM public.households

                    UNION ALL

                    SELECT
                        'Transaksi Baru' AS title,
                        COALESCE(NULLIF(note, ''), 'Transaksi ' || type) AS description,
                        created_at AS happened_at
                    FROM public.transactions
                ) AS unioned_rows
                ORDER BY happened_at DESC
                LIMIT 6
            ) AS activity_rows
        )
    )
    INTO result;

    RETURN result;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_admin_dashboard_data_v1() TO authenticated;
