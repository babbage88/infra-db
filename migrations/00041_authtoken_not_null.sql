-- +goose Up

-- +goose StatementBegin
DO $$
BEGIN
    RAISE NOTICE 'Starting UP Migration 00040->00041';
    RAISE NOTICE 'Altering external_auth_tokens.token column to SET NOT NULL';
END $$;
-- +goose StatementEnd

-- +goose StatementBegin
DO $$
BEGIN
  RAISE NOTICE 'Setting NULL token records to empty string';
END $$;
-- +goose StatementEnd

-- +goose StatementBegin
-- Replace NULLs with empty string or a placeholder
UPDATE public.external_auth_tokens
SET token = ''
WHERE token IS NULL;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE public.external_auth_tokens
    ALTER COLUMN token SET NOT NULL;
-- +goose StatementEnd

-- +goose Down

-- +goose StatementBegin
DO $$
BEGIN
    RAISE NOTICE 'Starting DOWN Migration 00041->00040';
    RAISE NOTICE 'Altering external_auth_tokens.token column to SET NOT NULL';
END $$;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE public.external_auth_tokens
    ALTER COLUMN token DROP NOT NULL;
-- +goose StatementEnd