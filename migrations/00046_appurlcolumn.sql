-- +goose Up
-- +goose StatementBegin
ALTER TABLE external_integration_apps ADD COLUMN endpoint_url text;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE external_integration_apps DROP COLUMN endpoint_url;
-- +goose StatementEnd