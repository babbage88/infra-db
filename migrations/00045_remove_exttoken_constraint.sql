-- +goose Up
-- +goose StatementBegin
ALTER TABLE public.external_auth_tokens DROP CONSTRAINT IF EXISTS external_auth_tokens_user_id_external_app_id_key;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE public.external_auth_tokens ADD CONSTRAINT external_auth_tokens_user_id_external_app_id_key UNIQUE (user_id, external_app_id);
-- +goose StatementEnd
