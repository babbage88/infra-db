-- +goose Up
-- +goose StatementBegin
DELETE FROM public.host_server_types WHERE name IN (
    'Container Host', 
    'RADIUS Server', 
    'DNS Server', 
    'DHCP Server', 
    'LDAP Server');

INSERT INTO public.host_server_types (name) VALUES
    ('LXC Container Host'),
    ('LXC Container'),
    ('Network Services Provider'),
    ('LDAP Provider'),
    ('RADIUS Provider')
ON CONFLICT (name) DO NOTHING;
-- +goose StatementEnd

-- +goose StatementBegin
INSERT INTO public.platform_types (name) VALUES
    ('DHCP Server'),
    ('DNS Server'),
    ('RADIUS Server'),
    ('LDAP Server')
ON CONFLICT (name) DO NOTHING;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM public.platform_types WHERE name IN (
    'DHCP Server',
    'DNS Server',
    'LDAP Server',
    'RADIUS Server');
-- +goose StatementEnd

-- +goose StatementBegin
DELETE FROM public.host_server_types WHERE name IN (
    'LXC Container Host',
    'LXC Container',
    'Network Services Provider',
    'LDAP Provider',
    'RADIUS Provider');
-- +goose StatementEnd

-- +goose StatementBegin
INSERT INTO public.host_server_types (name) VALUES
    ('Container Host'), 
    ('RADIUS Server'), 
    ('DNS Server'), 
    ('DHCP Server'), 
    ('LDAP Server')
ON CONFLICT (name) DO NOTHING;
-- +goose StatementEnd
