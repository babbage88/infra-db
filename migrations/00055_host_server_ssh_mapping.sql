-- +goose Up
-- +goose StatementBegin
-- Add username column to host_servers if it doesn't exist
ALTER TABLE public.host_servers 
ADD COLUMN IF NOT EXISTS username TEXT;

-- Create a unique index on hostname and username combination
CREATE UNIQUE INDEX IF NOT EXISTS host_servers_hostname_username_idx 
ON public.host_servers(hostname, username) 
WHERE username IS NOT NULL;
-- +goose StatementEnd

-- +goose StatementBegin
-- Create table for mapping host servers to SSH keys
CREATE TABLE IF NOT EXISTS public.host_server_ssh_mappings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    host_server_id uuid NOT NULL REFERENCES public.host_servers(id) ON DELETE CASCADE,
    ssh_key_id uuid NOT NULL REFERENCES public.ssh_keys(id) ON DELETE CASCADE,
    sudo_password_token_id uuid REFERENCES public.external_auth_tokens(id) ON DELETE SET NULL,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT unique_host_server_ssh_key UNIQUE (host_server_id, ssh_key_id)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS host_server_ssh_mappings_host_server_id_idx 
ON public.host_server_ssh_mappings(host_server_id);

CREATE INDEX IF NOT EXISTS host_server_ssh_mappings_ssh_key_id_idx 
ON public.host_server_ssh_mappings(ssh_key_id);

CREATE INDEX IF NOT EXISTS host_server_ssh_mappings_sudo_password_token_id_idx 
ON public.host_server_ssh_mappings(sudo_password_token_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Drop the SSH mappings table and its indexes
DROP TABLE IF EXISTS public.host_server_ssh_mappings;
-- +goose StatementEnd

-- +goose StatementBegin
-- Drop the username column and its index
DROP INDEX IF EXISTS host_servers_hostname_username_idx;
ALTER TABLE public.host_servers 
DROP COLUMN IF EXISTS username;
-- +goose StatementEnd 