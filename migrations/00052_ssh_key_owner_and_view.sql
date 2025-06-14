-- +goose Up
-- +goose StatementBegin
-- Add owner_user_id to ssh_keys table
ALTER TABLE public.ssh_keys 
ADD COLUMN owner_user_id uuid NOT NULL REFERENCES public.users(id);

-- Create an index for the foreign key
CREATE INDEX ssh_keys_owner_user_id_idx ON public.ssh_keys(owner_user_id);

-- Create view for user SSH key mappings
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

-- Add comment to the view
COMMENT ON VIEW public.user_ssh_key_mappings IS 'View showing all SSH key mappings for users, including host server details and key information';
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Drop the view
DROP VIEW IF EXISTS public.user_ssh_key_mappings;

-- Remove the owner column and its index
DROP INDEX IF EXISTS public.ssh_keys_owner_user_id_idx;
ALTER TABLE public.ssh_keys DROP COLUMN IF EXISTS owner_user_id;
-- +goose StatementEnd 