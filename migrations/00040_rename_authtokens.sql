-- +goose Up
-- +goose StatementBegin
DROP TABLE IF EXISTS public.auth_tokens;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.external_integration_apps (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL UNIQUE,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL
);
-- +goose StatementEnd

-- +goose StatementBegin
INSERT INTO public.external_integration_apps (name)
SELECT 'cloudflare'
WHERE NOT EXISTS (
    SELECT 1 FROM public.external_integration_apps WHERE name = 'cloudflare'
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.external_auth_tokens (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    external_app_id uuid NOT NULL REFERENCES public.external_integration_apps(id) ON DELETE CASCADE,
    token text NULL,
    expiration timestamp NULL,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE (user_id, external_app_id)
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS idx_auth_tokens_user_id ON public.external_auth_tokens (user_id);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS idx_auth_tokens_external_app_id ON public.external_auth_tokens (external_app_id);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS idx_auth_tokens_created_at ON public.external_auth_tokens (created_at);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE OR REPLACE VIEW public.user_auth_app_mappings AS
SELECT
    u.id AS user_id,
    u.username,
    u.email,
    a.id AS application_id,
    a.name AS application_name,
    t.id AS auth_token_id,
    t.created_at AS token_created_at,
    t.expiration
FROM public.users u
JOIN public.external_auth_tokens t ON u.id = t.user_id
JOIN public.external_integration_apps a ON t.external_app_id = a.id
WHERE u.is_deleted = false AND u.enabled = true;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP VIEW IF EXISTS public.user_auth_app_mappings;
DROP VIEW IF EXISTS public.user_external_tokens_view;

-- +goose StatementEnd

-- +goose StatementBegin
-- Drop foreign key constraints before dropping the table
ALTER TABLE public.external_auth_tokens DROP CONSTRAINT IF EXISTS external_auth_tokens_user_id_fkey;
ALTER TABLE public.external_auth_tokens DROP CONSTRAINT IF EXISTS external_auth_tokens_external_app_id_fkey;
ALTER TABLE public.external_integration_apps DROP CONSTRAINT IF EXISTS external_integration_apps_pkey;
ALTER TABLE public.external_integration_apps DROP CONSTRAINT IF EXISTS external_integration_apps_name_key;

-- +goose StatementEnd

-- +goose StatementBegin
DROP TABLE IF EXISTS public.external_auth_tokens;
-- +goose StatementEnd

-- +goose StatementBegin
DROP TABLE IF EXISTS public.external_integration_apps;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.auth_tokens (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    token text NULL,
    expiration timestamp NULL,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS idx_auth_tokens_user_id ON public.auth_tokens (user_id);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS idx_auth_tokens_created_at ON public.auth_tokens (created_at);
-- +goose StatementEnd
