-- +goose Up
-- +goose StatementBegin
ALTER TABLE public.host_servers DROP COLUMN IF EXISTS username;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.host_server_types (
    host_server_type_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.host_server_type_mappings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    host_server_id uuid NOT NULL REFERENCES public.host_servers(id) ON DELETE CASCADE,
    host_server_type_id uuid NOT NULL REFERENCES public.host_server_types(host_server_type_id) ON DELETE CASCADE,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.platform_types (
    platform_type_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.platform_type_mappings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    platform_type_id uuid NOT NULL REFERENCES public.platform_types(platform_type_id) ON DELETE CASCADE,
    host_server_id uuid NOT NULL REFERENCES public.host_servers(id) ON DELETE CASCADE,
    host_server_type_id uuid NOT NULL REFERENCES public.host_server_types(host_server_type_id) ON DELETE CASCADE,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL
);
-- +goose StatementEnd

-- +goose StatementBegin
INSERT INTO public.host_server_types (name) VALUES
    ('Database Server'),
    ('Application Server'),
    ('Hypervisor'),
    ('Container Host'),
    ('DNS Server'),
    ('DHCP Server'),
    ('VPN Server'),
    ('Full Linux OS'),
    ('Windows Server OS'),
    ('Windows Workstation OS')

ON CONFLICT (name) DO NOTHING;
-- +goose StatementEnd

-- +goose StatementBegin
INSERT INTO public.platform_types (name) VALUES
    ('LXC Host'),
    ('LXC Container'),
    ('Docker Host'),
    ('Kubernetes API'),
    ('Kubernetes Worker'),
    ('Nginx Server'),
    ('Docker Swarm'),
    ('Linux VM'),
    ('Linux VPS'),
    ('Linux Bare Metal'),
    ('Windows VM'),
    ('Windows VPS'),
    ('Proxmox PVE'),
    ('XCP-NG'),
    ('QEMU/KVM'),
    ('Postgres SQL'),
    ('SQLITE'),
    ('MySQL'),
    ('MariaDB'),
    ('MSSQL Server')
ON CONFLICT (name) DO NOTHING;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS public.platform_type_mappings;
DROP TABLE IF EXISTS public.platform_types;
DROP TABLE IF EXISTS public.host_server_type_mappings;
DROP TABLE IF EXISTS public.host_server_types;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE public.host_servers ADD COLUMN username TEXT;
-- +goose StatementEnd 