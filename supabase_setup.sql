-- ================================================================
-- MAMA Members Table — Run this in Supabase SQL Editor
-- Project: tjxposrskeoobldopbac (AIShort / B3D)
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
  lang                TEXT DEFAULT 'ms',
  role                TEXT DEFAULT 'member',
  permissions         JSONB DEFAULT '{"can_view_mom": false}'
);

-- Safely add new columns if the table already existed before running this
ALTER TABLE public.mama_members 
  ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'member',
  ADD COLUMN IF NOT EXISTS permissions JSONB DEFAULT '{"can_view_mom": false}';

-- Enable Row Level Security
ALTER TABLE public.mama_members ENABLE ROW LEVEL SECURITY;

-- Allow public INSERT (new registrations)
DROP POLICY IF EXISTS "mama_allow_insert" ON public.mama_members;
CREATE POLICY "mama_allow_insert" ON public.mama_members
  FOR INSERT TO anon WITH CHECK (true);

-- Allow SELECT (Admins see all, Members see only their own)
DROP POLICY IF EXISTS "mama_auth_select" ON public.mama_members;
CREATE POLICY "mama_auth_select" ON public.mama_members
  FOR SELECT TO authenticated 
  USING (
    auth.jwt()->>'email' = 'Bruce@B3D-online.com' 
    OR email = auth.jwt()->>'email'
  );

-- Allow UPDATE (Admins can update all, Members update their own)
DROP POLICY IF EXISTS "mama_auth_update" ON public.mama_members;
CREATE POLICY "mama_auth_update" ON public.mama_members
  FOR UPDATE TO authenticated 
  USING (
    auth.jwt()->>'email' = 'Bruce@B3D-online.com' 
    OR email = auth.jwt()->>'email'
  );

-- ================================================================
-- MAMA Member Files (Invoices)
-- ================================================================

CREATE TABLE IF NOT EXISTS public.mama_member_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  member_id UUID REFERENCES public.mama_members(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  file_url TEXT NOT NULL,
  file_type TEXT NOT NULL DEFAULT 'invoice'
);

ALTER TABLE public.mama_member_files ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "files_auth_select" ON public.mama_member_files;
CREATE POLICY "files_auth_select" ON public.mama_member_files
  FOR SELECT TO authenticated 
  USING (
    auth.jwt()->>'email' = 'Bruce@B3D-online.com'
    OR member_id IN (
        SELECT id FROM public.mama_members WHERE email = auth.jwt()->>'email'
    )
  );

DROP POLICY IF EXISTS "files_admin_all" ON public.mama_member_files;
CREATE POLICY "files_admin_all" ON public.mama_member_files
  FOR ALL TO authenticated
  USING (auth.jwt()->>'email' = 'Bruce@B3D-online.com')
  WITH CHECK (auth.jwt()->>'email' = 'Bruce@B3D-online.com');

-- Note: You also need to create a Storage Bucket named 'mama_files' inside 
-- your Supabase Dashboard -> Storage -> Create Bucket. Set it to 'Public'.
