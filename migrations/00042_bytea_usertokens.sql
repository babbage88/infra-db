-- +goose Up
-- +goose StatementBegin
DO $$
BEGIN
  RAISE NOTICE 'Altering column token in external_auth_tokens to BYTEA';
END $$;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE public.external_auth_tokens
ALTER COLUMN token TYPE BYTEA
USING decode(token, 'escape');  -- Converts old TEXT to BYTEA if stored in escaped format
-- +goose StatementEnd



-- +goose Down
-- +goose StatementBegin
DO $$
BEGIN
  RAISE NOTICE 'Reverting column token in external_auth_tokens back to TEXT';
END $$;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE public.external_auth_tokens
ALTER COLUMN token TYPE TEXT
USING encode(token, 'escape');  -- Converts BYTEA back to a TEXT representation
-- +goose StatementEnd

