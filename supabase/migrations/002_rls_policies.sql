-- 002_rls_policies.sql
-- Keamanan Data: Row Level Security (RLS)

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.households ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.household_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recurring_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.goal_allocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;

-- 1. PROFILES: User hanya bisa baca/tulis profilnya sendiri
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- 2. HOUSEHOLDS: Akses jika user adalah member dari household tersebut
CREATE POLICY "Members can view their households" ON public.households FOR SELECT 
USING (EXISTS (SELECT 1 FROM public.household_members WHERE household_id = public.households.id AND user_id = auth.uid()));

-- 3. HOUSEHOLD_MEMBERS: Bisa lihat member lain dalam satu keluarga
CREATE POLICY "Members can view household peers" ON public.household_members FOR SELECT
USING (EXISTS (SELECT 1 FROM public.household_members peer WHERE peer.household_id = public.household_members.household_id AND peer.user_id = auth.uid()));

-- 4. WALLETS: Akses berdasarkan household_id
CREATE POLICY "Members can access household wallets" ON public.wallets FOR ALL
USING (EXISTS (SELECT 1 FROM public.household_members WHERE household_id = public.wallets.household_id AND user_id = auth.uid()));

-- 5. CATEGORIES: Akses jika milik household sendiri ATAU kategori default (household_id NULL)
CREATE POLICY "Members can access household or default categories" ON public.categories FOR SELECT
USING (household_id IS NULL OR EXISTS (SELECT 1 FROM public.household_members WHERE household_id = public.categories.household_id AND user_id = auth.uid()));

CREATE POLICY "Members can manage their own categories" ON public.categories FOR INSERT
WITH CHECK (EXISTS (SELECT 1 FROM public.household_members WHERE household_id = public.categories.household_id AND user_id = auth.uid()));

-- 6. TRANSACTIONS: Akses berdasarkan household_id
CREATE POLICY "Members can access household transactions" ON public.transactions FOR ALL
USING (EXISTS (SELECT 1 FROM public.household_members WHERE household_id = public.transactions.household_id AND user_id = auth.uid()));

-- 7. RECURRING_TRANSACTIONS: Akses berdasarkan household_id
CREATE POLICY "Members can access household recurring transactions" ON public.recurring_transactions FOR ALL
USING (EXISTS (SELECT 1 FROM public.household_members WHERE household_id = public.recurring_transactions.household_id AND user_id = auth.uid()));

-- 8. BUDGETS: Akses berdasarkan household_id
CREATE POLICY "Members can access household budgets" ON public.budgets FOR ALL
USING (EXISTS (SELECT 1 FROM public.household_members WHERE household_id = public.budgets.household_id AND user_id = auth.uid()));

-- 9. GOALS & ALLOCATIONS: Akses berdasarkan household_id
CREATE POLICY "Members can access household goals" ON public.goals FOR ALL
USING (EXISTS (SELECT 1 FROM public.household_members WHERE household_id = public.goals.household_id AND user_id = auth.uid()));

CREATE POLICY "Members can access household goal allocations" ON public.goal_allocations FOR ALL
USING (EXISTS (SELECT 1 FROM public.goals g JOIN public.household_members m ON g.household_id = m.household_id WHERE g.id = public.goal_allocations.goal_id AND m.user_id = auth.uid()));

-- 10. NOTIFICATIONS: User hanya bisa lihat notifikasi mereka sendiri
CREATE POLICY "Users can view own notifications" ON public.notifications FOR SELECT
USING (user_id = auth.uid());

-- 11. APP_SETTINGS: Semua bisa baca (Public), hanya Admin bisa edit (melalui Service Role / Edge Functions)
CREATE POLICY "Anyone can view app settings" ON public.app_settings FOR SELECT USING (true);
