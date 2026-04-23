-- 004_admin_logic.sql
-- 1. Fungsi Trigger untuk Pembuatan Profil Otomatis
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, avatar_url, role)
    VALUES (
        NEW.id, 
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email), 
        NEW.raw_user_meta_data->>'avatar_url',
        CASE 
            WHEN NEW.email = 'nawawimahinutsman@gmail.com' THEN 'admin'
            ELSE 'user'
        END
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Trigger saat User baru mendaftar di Auth
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 3. Fungsi Helper untuk Cek Admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Update RLS agar Admin bisa melihat semua profil
CREATE POLICY "Admins can view all profiles" ON public.profiles
    FOR SELECT USING (public.is_admin());

-- 5. Kategori Default (Global)
INSERT INTO public.categories (name, icon, color, type, is_default)
VALUES 
    ('Makanan & Minuman', 'restaurant', '#FF7043', 'expense', true),
    ('Transportasi', 'directions_car', '#42A5F5', 'expense', true),
    ('Belanja', 'shopping_bag', '#AB47BC', 'expense', true),
    ('Hiburan', 'sports_esports', '#FFA726', 'expense', true),
    ('Kesehatan', 'medical_services', '#66BB6A', 'expense', true),
    ('Gaji', 'payments', '#43A047', 'income', true),
    ('Investasi', 'trending_up', '#1E88E5', 'income', true),
    ('Lain-lain', 'more_horiz', '#78909C', 'both', true);
