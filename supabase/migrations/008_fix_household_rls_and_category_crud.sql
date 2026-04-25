-- 008_fix_household_rls_and_category_crud.sql
-- Perbaikan RLS agar tidak rekursif dan CRUD kategori custom bisa berjalan.

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

DROP POLICY IF EXISTS "Members can view their households" ON public.households;
CREATE POLICY "Members can view their households" ON public.households
    FOR SELECT
    USING (public.is_household_member(id));

DROP POLICY IF EXISTS "Members can view household peers" ON public.household_members;
CREATE POLICY "Members can view household peers" ON public.household_members
    FOR SELECT
    USING (public.is_household_member(household_id));

DROP POLICY IF EXISTS "Members can access household wallets" ON public.wallets;
CREATE POLICY "Members can access household wallets" ON public.wallets
    FOR ALL
    USING (public.is_household_member(household_id))
    WITH CHECK (public.is_household_member(household_id));

DROP POLICY IF EXISTS "Members can access household or default categories" ON public.categories;
CREATE POLICY "Members can access household or default categories" ON public.categories
    FOR SELECT
    USING (
        household_id IS NULL
        OR public.is_household_member(household_id)
    );

DROP POLICY IF EXISTS "Members can manage their own categories" ON public.categories;
CREATE POLICY "Members can insert custom categories" ON public.categories
    FOR INSERT
    WITH CHECK (
        household_id IS NOT NULL
        AND COALESCE(is_default, false) = false
        AND public.is_household_member(household_id)
    );

DROP POLICY IF EXISTS "Members can update custom categories" ON public.categories;
CREATE POLICY "Members can update custom categories" ON public.categories
    FOR UPDATE
    USING (
        household_id IS NOT NULL
        AND COALESCE(is_default, false) = false
        AND public.is_household_member(household_id)
    )
    WITH CHECK (
        household_id IS NOT NULL
        AND COALESCE(is_default, false) = false
        AND public.is_household_member(household_id)
    );

DROP POLICY IF EXISTS "Members can delete custom categories" ON public.categories;
CREATE POLICY "Members can delete custom categories" ON public.categories
    FOR DELETE
    USING (
        household_id IS NOT NULL
        AND COALESCE(is_default, false) = false
        AND public.is_household_member(household_id)
    );

DROP POLICY IF EXISTS "Members can access household transactions" ON public.transactions;
CREATE POLICY "Members can access household transactions" ON public.transactions
    FOR ALL
    USING (public.is_household_member(household_id))
    WITH CHECK (public.is_household_member(household_id));

DROP POLICY IF EXISTS "Members can access household recurring transactions" ON public.recurring_transactions;
CREATE POLICY "Members can access household recurring transactions" ON public.recurring_transactions
    FOR ALL
    USING (public.is_household_member(household_id))
    WITH CHECK (public.is_household_member(household_id));

DROP POLICY IF EXISTS "Members can access household budgets" ON public.budgets;
CREATE POLICY "Members can access household budgets" ON public.budgets
    FOR ALL
    USING (public.is_household_member(household_id))
    WITH CHECK (public.is_household_member(household_id));

DROP POLICY IF EXISTS "Members can access household goals" ON public.goals;
CREATE POLICY "Members can access household goals" ON public.goals
    FOR ALL
    USING (public.is_household_member(household_id))
    WITH CHECK (public.is_household_member(household_id));

DROP POLICY IF EXISTS "Members can access household goal allocations" ON public.goal_allocations;
CREATE POLICY "Members can access household goal allocations" ON public.goal_allocations
    FOR ALL
    USING (
        EXISTS (
            SELECT 1
            FROM public.goals g
            WHERE g.id = public.goal_allocations.goal_id
              AND public.is_household_member(g.household_id)
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.goals g
            WHERE g.id = public.goal_allocations.goal_id
              AND public.is_household_member(g.household_id)
        )
    );
