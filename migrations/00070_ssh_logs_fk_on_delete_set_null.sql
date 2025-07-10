-- +goose Up
-- +goose StatementBegin
ALTER TABLE ssh_connection_logs ALTER COLUMN host_server_id DROP NOT NULL;
ALTER TABLE ssh_connection_logs DROP CONSTRAINT IF EXISTS ssh_connection_logs_host_server_id_fkey;
ALTER TABLE ssh_connection_logs ADD CONSTRAINT ssh_connection_logs_host_server_id_fkey FOREIGN KEY (host_server_id) REFERENCES host_servers(id) ON DELETE SET NULL;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE ssh_connection_logs DROP CONSTRAINT IF EXISTS ssh_connection_logs_host_server_id_fkey;
ALTER TABLE ssh_connection_logs ALTER COLUMN host_server_id SET NOT NULL;
ALTER TABLE ssh_connection_logs ADD CONSTRAINT ssh_connection_logs_host_server_id_fkey FOREIGN KEY (host_server_id) REFERENCES host_servers(id);
-- +goose StatementEnd 