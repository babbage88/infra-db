-- +goose Up
-- +goose StatementBegin
-- Add additional columns to ssh_sessions table
ALTER TABLE ssh_sessions 
ADD COLUMN client_ip INET,
ADD COLUMN user_agent TEXT;

-- SSH connection logs for audit
CREATE TABLE ssh_connection_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id),
    host_server_id UUID NOT NULL REFERENCES host_servers(id),
    action VARCHAR(50) NOT NULL, -- 'connect', 'disconnect', 'error'
    details JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Additional indexes for performance
CREATE INDEX idx_ssh_sessions_active ON ssh_sessions(is_active) WHERE is_active = true;
CREATE INDEX idx_ssh_connection_logs_session_id ON ssh_connection_logs(session_id);
CREATE INDEX idx_ssh_connection_logs_created_at ON ssh_connection_logs(created_at);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Drop indexes first
DROP INDEX IF EXISTS idx_ssh_connection_logs_created_at;
DROP INDEX IF EXISTS idx_ssh_connection_logs_session_id;
DROP INDEX IF EXISTS idx_ssh_sessions_active;

-- Drop the ssh_connection_logs table
DROP TABLE IF EXISTS ssh_connection_logs;

-- Remove columns from ssh_sessions table
ALTER TABLE ssh_sessions 
DROP COLUMN IF EXISTS user_agent,
DROP COLUMN IF EXISTS client_ip;
-- +goose StatementEnd 
