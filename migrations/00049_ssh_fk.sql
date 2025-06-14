-- +goose Up
-- +goose StatementBegin
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

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS public.ssh_key_host_mappings;
-- +goose StatementEnd
