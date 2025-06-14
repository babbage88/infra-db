-- +goose Up
-- +goose StatementBegin
-- Create the ssh_key_types table
CREATE TABLE IF NOT EXISTS public.ssh_key_types (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL UNIQUE,
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Insert common SSH key types
INSERT INTO public.ssh_key_types (name, description) VALUES
    ('rsa', 'RSA (Rivest-Shamir-Adleman) key type'),
    ('ed25519', 'Ed25519 key type - modern, recommended for new deployments'),
    ('ecdsa', 'ECDSA (Elliptic Curve Digital Signature Algorithm) key type'),
    ('dsa', 'DSA (Digital Signature Algorithm) key type - legacy'),
    ('ecdsa-sk', 'ECDSA with security key'),
    ('ed25519-sk', 'Ed25519 with security key');

-- Create an index on the name column
CREATE INDEX ssh_key_types_name_idx ON public.ssh_key_types(name);

-- Modify ssh_keys table to reference ssh_key_types
ALTER TABLE public.ssh_keys 
    DROP COLUMN key_type,
    ADD COLUMN key_type_id uuid NOT NULL REFERENCES public.ssh_key_types(id);

-- Create an index for the foreign key
CREATE INDEX ssh_keys_key_type_id_idx ON public.ssh_keys(key_type_id);

-- Set default key type to RSA for existing records
UPDATE public.ssh_keys 
SET key_type_id = (SELECT id FROM public.ssh_key_types WHERE name = 'rsa')
WHERE key_type_id IS NULL;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Remove the foreign key and column from ssh_keys
ALTER TABLE public.ssh_keys 
    DROP COLUMN key_type_id,
    ADD COLUMN key_type text NOT NULL DEFAULT 'rsa';

-- Drop the ssh_key_types table
DROP TABLE IF EXISTS public.ssh_key_types;
-- +goose StatementEnd 