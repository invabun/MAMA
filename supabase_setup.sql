-- ================================================================
-- MAMA Members Table — Run this in Supabase SQL Editor
-- Project: eerdjpvhehndamekevvi (B3D Supabase)
-- ================================================================

CREATE TABLE IF NOT EXISTS public.mama_members (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  member_type         TEXT NOT NULL CHECK (member_type IN ('individual', 'corporate', 'academic')),
  full_name           TEXT NOT NULL,
  org_name            TEXT,
  ic_passport         TEXT,
  email               TEXT NOT NULL,
  phone               TEXT NOT NULL,
  state               TEXT NOT NULL,
  industry            TEXT NOT NULL,
  source              TEXT,
  intro               TEXT,
  payment_status      TEXT NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed')),
  payment_amount      DECIMAL(10,2),
  stripe_session_id   TEXT,
  application_status  TEXT NOT NULL DEFAULT 'new' CHECK (application_status IN ('new', 'paid', 'approved', 'rejected')),
  membership_number   TEXT UNIQUE,
  admin_notes         TEXT,
  renewal_due_date    DATE,
  lang                TEXT DEFAULT 'ms'
);

-- Enable Row Level Security
ALTER TABLE public.mama_members ENABLE ROW LEVEL SECURITY;

-- Allow public INSERT (new registrations)
CREATE POLICY "mama_allow_insert" ON public.mama_members
  FOR INSERT TO anon WITH CHECK (true);

-- Allow SELECT (admin reads via anon key — secured by password gate in admin.html)
CREATE POLICY "mama_allow_select" ON public.mama_members
  FOR SELECT TO anon USING (true);

-- Allow UPDATE (admin approval/rejection)
CREATE POLICY "mama_allow_update" ON public.mama_members
  FOR UPDATE TO anon USING (true);
