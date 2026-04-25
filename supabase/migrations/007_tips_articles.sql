-- 007_tips_articles.sql
-- Sumber data halaman Tips agar kontennya diambil dari database.

CREATE TABLE IF NOT EXISTS public.tips_articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    summary TEXT NOT NULL,
    content TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'Tips',
    accent_color TEXT NOT NULL DEFAULT '#2563EB',
    reading_minutes INT NOT NULL DEFAULT 3,
    cover_url TEXT,
    is_published BOOLEAN NOT NULL DEFAULT true,
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.tips_articles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated users can view published tips" ON public.tips_articles;
CREATE POLICY "Authenticated users can view published tips" ON public.tips_articles
    FOR SELECT
    USING (auth.uid() IS NOT NULL AND is_published = true);

DROP POLICY IF EXISTS "Service role can manage tips articles" ON public.tips_articles;
CREATE POLICY "Service role can manage tips articles" ON public.tips_articles
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

CREATE INDEX IF NOT EXISTS idx_tips_articles_published_at
    ON public.tips_articles (published_at DESC);

CREATE INDEX IF NOT EXISTS idx_tips_articles_is_published
    ON public.tips_articles (is_published);

DROP TRIGGER IF EXISTS update_tips_articles_updated_at ON public.tips_articles;
CREATE TRIGGER update_tips_articles_updated_at
    BEFORE UPDATE ON public.tips_articles
    FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

INSERT INTO public.tips_articles (
    title,
    summary,
    content,
    category,
    accent_color,
    reading_minutes,
    is_published,
    published_at
)
VALUES
    (
        'Pisahkan uang harian dan uang tujuan',
        'Biar cashflow lebih rapi, bedakan uang yang boleh dipakai setiap hari dengan uang yang memang disiapkan untuk target tertentu.',
        'Cara paling aman untuk menjaga cashflow adalah memberi fungsi yang jelas pada tiap saldo. Pakai satu dompet untuk kebutuhan harian seperti makan, transportasi, dan tagihan rutin. Lalu siapkan dompet lain untuk tujuan khusus seperti dana darurat, liburan, atau gadget baru. Dengan cara ini, kamu tidak perlu terus menebak saldo mana yang aman dipakai dan mana yang sebaiknya tetap disimpan.',
        'Manajemen Uang',
        '#2563EB',
        3,
        true,
        NOW()
    ),
    (
        'Cek pengeluaran kecil sebelum akhir minggu',
        'Pengeluaran receh sering terasa ringan, padahal totalnya bisa cukup besar kalau tidak dipantau.',
        'Luangkan beberapa menit sebelum akhir minggu untuk melihat transaksi kecil yang paling sering muncul. Biasanya justru pengeluaran seperti kopi, biaya admin, atau belanja impulsif yang membuat budget bocor pelan-pelan. Begitu pola itu kelihatan, kamu akan lebih mudah menentukan pengeluaran mana yang memang perlu dan mana yang bisa dikurangi.',
        'Budget',
        '#0F766E',
        2,
        true,
        NOW() - INTERVAL '1 day'
    ),
    (
        'Pakai target tabungan yang realistis',
        'Target yang terlalu tinggi sering bikin progres cepat berhenti. Mulai dari nominal yang ringan tapi konsisten jauh lebih efektif.',
        'Supaya target tabungan benar-benar jalan, buat nominal yang terasa realistis untuk ritme pemasukan kamu sekarang. Tidak harus besar. Yang penting stabil dan terus bertambah. Saat nominal awal sudah terasa ringan, baru naikkan perlahan. Progres yang konsisten biasanya jauh lebih kuat daripada target besar yang hanya sempat dijalankan sebentar.',
        'Target',
        '#7C3AED',
        3,
        true,
        NOW() - INTERVAL '2 days'
    )
ON CONFLICT DO NOTHING;
