-- 003_indexes.sql
-- Optimasi Performa Database

-- Index untuk memfilter transaksi berdasarkan household dan tanggal (paling sering dipakai)
CREATE INDEX IF NOT EXISTS idx_transactions_household_date ON public.transactions(household_id, date DESC);

-- Index untuk foreign keys agar JOIN lebih cepat
CREATE INDEX IF NOT EXISTS idx_transactions_wallet ON public.transactions(wallet_id);
CREATE INDEX IF NOT EXISTS idx_transactions_category ON public.transactions(category_id);
CREATE INDEX IF NOT EXISTS idx_transactions_to_wallet ON public.transactions(to_wallet_id);

-- Index untuk memfilter budget berdasarkan periode
CREATE INDEX IF NOT EXISTS idx_budgets_period ON public.budgets(household_id, period_year, period_month);

-- Index untuk notifikasi yang belum dibaca
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON public.notifications(user_id, is_read) WHERE is_read = false;

-- Index untuk mencari member household berdasarkan user_id
CREATE INDEX IF NOT EXISTS idx_household_members_user ON public.household_members(user_id);

-- Index untuk invite code (untuk mempercepat pencarian saat join household)
CREATE INDEX IF NOT EXISTS idx_households_invite_code ON public.households(invite_code);
