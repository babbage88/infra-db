-- +goose Up
-- +goose StatementBegin
ALTER TABLE public.ssh_keys 
ADD COLUMN key_type text NOT NULL DEFAULT 'rsa';

-- Add an index for the key_type column for better query performance
CREATE INDEX ssh_keys_key_type_idx ON public.ssh_keys(key_type);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS public.ssh_keys_key_type_idx;
ALTER TABLE public.ssh_keys DROP COLUMN IF EXISTS key_type;
-- +goose StatementEnd
