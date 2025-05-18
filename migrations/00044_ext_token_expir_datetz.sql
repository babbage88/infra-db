-- +goose Up

-- +goose StatementBegin
DO $$
BEGIN
  RAISE NOTICE 'Altering expiration colmn on external_auth_tokens to be timestamptz';
END $$;
-- +goose StatementEnd

-- +goose StatementBegin
DROP VIEW public.user_auth_app_mappings;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE public.external_auth_tokens ALTER COLUMN expiration TYPE timestamptz;
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
DROP VIEW public.user_auth_app_mappings;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE public.external_auth_tokens ALTER COLUMN expiration TYPE timestamp;
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
