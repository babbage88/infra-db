-- +goose Up
-- +goose StatementBegin
-- Insert external integration apps if they don't exist
INSERT INTO public.external_integration_apps (name, app_description)
VALUES 
    ('ssh_passphrase', 'SSH Key Passphrase')
ON CONFLICT (name) DO NOTHING;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM public.external_integration_apps WHERE name = 'ssh_passphrase'
-- +goose StatementEnd
