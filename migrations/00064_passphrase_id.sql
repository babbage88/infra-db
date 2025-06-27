-- +goose Up
-- +goose StatementBegin

ALTER TABLE ssh_keys
ADD COLUMN passphrase_id UUID;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE ssh_keys
ADD CONSTRAINT fk_ssh_keys_passphrase
FOREIGN KEY (passphrase_id)
REFERENCES external_auth_tokens(id)
ON DELETE SET NULL;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE ssh_keys
DROP CONSTRAINT IF EXISTS fk_ssh_keys_passphrase;

ALTER TABLE ssh_keys
DROP COLUMN IF EXISTS passphrase_id;
-- +goose StatementEnd

