-- +goose Up
-- +goose StatementBegin
-- Add user_id column to host_server_ssh_mappings table
ALTER TABLE public.host_server_ssh_mappings 
ADD COLUMN user_id uuid REFERENCES public.users(id) ON DELETE CASCADE;

-- Add hostserver_username column to host_server_ssh_mappings table
ALTER TABLE public.host_server_ssh_mappings 
ADD COLUMN hostserver_username text;

-- Create an index for the foreign key for better query performance
CREATE INDEX IF NOT EXISTS host_server_ssh_mappings_user_id_idx 
ON public.host_server_ssh_mappings(user_id);

-- Create an index for the hostserver_username column
CREATE INDEX IF NOT EXISTS host_server_ssh_mappings_hostserver_username_idx 
ON public.host_server_ssh_mappings(hostserver_username);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Drop the indexes first
DROP INDEX IF EXISTS host_server_ssh_mappings_hostserver_username_idx;
DROP INDEX IF EXISTS host_server_ssh_mappings_user_id_idx;

-- Drop the columns
ALTER TABLE public.host_server_ssh_mappings 
DROP COLUMN IF EXISTS hostserver_username;

ALTER TABLE public.host_server_ssh_mappings 
DROP COLUMN IF EXISTS user_id;
-- +goose StatementEnd 