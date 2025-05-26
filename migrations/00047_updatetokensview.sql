-- +goose Up

-- +goose StatementBegin
DROP VIEW public.user_auth_app_mappings;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE OR REPLACE VIEW public.user_auth_app_mappings
AS SELECT u.id AS user_id,
    u.username,
    u.email,
    a.id AS application_id,
    a.name AS application_name,
    a.endpoint_url,
    t.id AS auth_token_id,
    t.created_at AS token_created_at,
    t.expiration
   FROM users u
     JOIN external_auth_tokens t ON u.id = t.user_id
     JOIN external_integration_apps a ON t.external_app_id = a.id
  WHERE u.is_deleted = false AND u.enabled = true;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP VIEW public.user_auth_app_mappings;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE OR REPLACE VIEW public.user_auth_app_mappings
AS SELECT u.id AS user_id,
    u.username,
    u.email,
    a.id AS application_id,
    a.name AS application_name,
    t.id AS auth_token_id,
    t.created_at AS token_created_at,
    t.expiration
   FROM users u
     JOIN external_auth_tokens t ON u.id = t.user_id
     JOIN external_integration_apps a ON t.external_app_id = a.id
  WHERE u.is_deleted = false AND u.enabled = true;
-- +goose StatementEnd

