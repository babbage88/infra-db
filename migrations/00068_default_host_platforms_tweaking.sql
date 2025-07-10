-- +goose Up
-- +goose StatementBegin
DELETE FROM public.host_server_types WHERE name = 'Full Linux OS';
-- +goose StatementEnd

-- +goose StatementBegin
INSERT INTO public.host_server_types (name) VALUES
    ('Linux Server'),
    ('Linux Workstation'),
    ('LDAP Server'),
    ('RADIUS Server')
ON CONFLICT (name) DO NOTHING;
-- +goose StatementEnd

-- +goose StatementBegin
INSERT INTO public.platform_types (name) VALUES
    ('IIS Server'),
    ('Active Directory'),
    ('Exchange Server'),
    ('SQL Server'),
    ('MySQL'),
    ('MariaDB'),
    ('MSSQL Server'),
    ('Exchange Server'),
    ('FreeIPA Server'),
    ('FreeRADIUS Server'),
    ('DHCP Server'),
    ('DNS Server'),
    ('NTP Server'),
    ('SMTP Server'),
    ('POP3 Server'),
    ('IMAP Server'),
    ('FTP Server')
ON CONFLICT (name) DO NOTHING;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM public.host_server_types WHERE name IN ('Linux Server', 'Linux Workstation', 'LDAP Server', 'RADIUS Server');
DELETE FROM public.platform_types WHERE name IN (
    'IIS Server', 
    'Active Directory', 
    'Exchange Server', 
    'SQL Server', 
    'MySQL', 
    'MariaDB', 
    'MSSQL Server', 
    'FreeIPA Server', 
    'FreeRADIUS Server', 
    'DHCP Server', 
    'DNS Server', 
    'NTP Server', 
    'SMTP Server', 
    'POP3 Server', 
    'IMAP Server', 
    'FTP Server');
-- +goose StatementEnd

-- +goose StatementBegin
INSERT INTO public.host_server_types (name) VALUES
    ('Full Linux OS')
ON CONFLICT (name) DO NOTHING;
-- +goose StatementEnd
