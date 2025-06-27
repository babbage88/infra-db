-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.ssh_sessions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    host_server_id UUID NOT NULL REFERENCES public.host_servers(id) ON DELETE CASCADE,
    username TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_activity TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS ssh_sessions_user_id_idx ON public.ssh_sessions(user_id);
CREATE INDEX IF NOT EXISTS ssh_sessions_host_server_id_idx ON public.ssh_sessions(host_server_id);
CREATE INDEX IF NOT EXISTS ssh_sessions_is_active_idx ON public.ssh_sessions(is_active);
CREATE INDEX IF NOT EXISTS ssh_sessions_last_activity_idx ON public.ssh_sessions(last_activity);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Drop indexes first
DROP INDEX IF EXISTS public.ssh_sessions_last_activity_idx;
DROP INDEX IF EXISTS public.ssh_sessions_is_active_idx;
DROP INDEX IF EXISTS public.ssh_sessions_host_server_id_idx;
DROP INDEX IF EXISTS public.ssh_sessions_user_id_idx;

-- Drop the table
DROP TABLE IF EXISTS public.ssh_sessions;
-- +goose StatementEnd 
