-- +goose Up
-- +goose StatementBegin
-- Drop the view that depends on the table
DROP VIEW IF EXISTS public.user_ssh_key_mappings;
-- +goose StatementEnd

-- +goose StatementBegin
-- Drop the redundant ssh_key_host_mappings table and its indexes
DROP TABLE IF EXISTS public.ssh_key_host_mappings;
-- +goose StatementEnd

-- +goose StatementBegin
-- Update the view to use host_server_ssh_mappings instead
CREATE OR REPLACE VIEW public.user_ssh_key_mappings AS
SELECT 
    hssm.id as mapping_id,
    u.id as user_id,
    u.username,
    hs.hostname as host_server_name,
    hs.id as host_server_id,
    sk.public_key,
    sk.id as ssh_key_id,
    COALESCE(sk.priv_secret_id, '00000000-0000-0000-0000-000000000000'::uuid) as external_auth_token_id,
    skt.name as ssh_key_type,
    hssm.hostserver_username,
    COALESCE(hssm.sudo_password_token_id, '00000000-0000-0000-0000-000000000000'::uuid) as sudo_password_token_id,
    hssm.created_at,
    hssm.last_modified
FROM public.host_server_ssh_mappings hssm
JOIN public.users u ON u.id = hssm.user_id
JOIN public.host_servers hs ON hs.id = hssm.host_server_id
JOIN public.ssh_keys sk ON sk.id = hssm.ssh_key_id
JOIN public.ssh_key_types skt ON skt.id = sk.key_type_id;

-- Add comment to the view
COMMENT ON VIEW public.user_ssh_key_mappings IS 'View showing all SSH key mappings for users, including host server details and key information';
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Drop the view first
DROP VIEW IF EXISTS public.user_ssh_key_mappings;
-- +goose StatementEnd

-- +goose StatementBegin
-- Recreate the ssh_key_host_mappings table
CREATE TABLE IF NOT EXISTS public.ssh_key_host_mappings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    ssh_key_id uuid NOT NULL REFERENCES public.ssh_keys(id) ON DELETE CASCADE,
    host_server_id uuid NOT NULL REFERENCES public.host_servers(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    hostserver_username text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT unique_ssh_key_host_user UNIQUE (ssh_key_id, host_server_id, user_id)
);

-- Create indexes for better query performance
CREATE INDEX ssh_key_host_mappings_ssh_key_id_idx ON public.ssh_key_host_mappings(ssh_key_id);
CREATE INDEX ssh_key_host_mappings_host_server_id_idx ON public.ssh_key_host_mappings(host_server_id);
CREATE INDEX ssh_key_host_mappings_user_id_idx ON public.ssh_key_host_mappings(user_id);
-- +goose StatementEnd

-- +goose StatementBegin
-- Restore the original view
CREATE OR REPLACE VIEW public.user_ssh_key_mappings AS
SELECT 
    u.id as user_id,
    u.username,
    hs.hostname as host_server_name,
    hs.id as host_server_id,
    sk.public_key,
    sk.id as ssh_key_id,
    sk.priv_secret_id as external_auth_token_id,
    skt.name as ssh_key_type,
    skhm.hostserver_username
FROM public.ssh_key_host_mappings skhm
JOIN public.users u ON u.id = skhm.user_id
JOIN public.host_servers hs ON hs.id = skhm.host_server_id
JOIN public.ssh_keys sk ON sk.id = skhm.ssh_key_id
JOIN public.ssh_key_types skt ON skt.id = sk.key_type_id;
-- +goose StatementEnd 