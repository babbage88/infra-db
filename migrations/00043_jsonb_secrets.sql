-- +goose Up
-- +goose StatementBegin
DO $$
BEGIN
  RAISE NOTICE 'Altering column token to JSONB in external_auth_tokens';
END $$;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE public.external_auth_tokens
ALTER COLUMN token TYPE JSONB
USING CASE
         WHEN token IS NULL THEN NULL
         ELSE jsonb_build_object(
           'userId', user_id::text,
           'applicationId', external_app_id::text,
           'userSecret', jsonb_build_object('ciphertext', encode(token, 'base64'))
         )
       END;
-- +goose StatementEnd


-- +goose Down
-- +goose StatementBegin
DO $$
BEGIN
  RAISE NOTICE 'Reverting token column from JSONB to BYTEA';
END $$;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE public.external_auth_tokens
ALTER COLUMN token TYPE BYTEA
USING CASE
         WHEN token IS NULL THEN NULL
         ELSE decode(token->'userSecret'->>'ciphertext', 'base64')
       END;
-- +goose StatementEnd

