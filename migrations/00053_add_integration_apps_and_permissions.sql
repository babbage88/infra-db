-- +goose Up
-- +goose StatementBegin
-- Add app_description column if it doesn't exist
ALTER TABLE public.external_integration_apps 
ADD COLUMN IF NOT EXISTS app_description TEXT;
-- +goose StatementEnd

-- +goose StatementBegin
-- Insert external integration apps if they don't exist
INSERT INTO public.external_integration_apps (name, app_description)
VALUES 
    ('ssh_keys', 'SSH Key Management Integration'),
    ('CloudflareDNS', 'Cloudflare DNS Integration')
ON CONFLICT (name) DO NOTHING;
-- +goose StatementEnd

-- +goose StatementBegin
-- Insert new permissions if they don't exist
INSERT INTO public.app_permissions (permission_name, permission_description)
VALUES 
    ('ManageHostServers', 'Permission to manage host servers'),
    ('ReadHostServers', 'Permission to read host server properties'),
    ('ManageSshKeys', 'Permission to manage SSH keys')
ON CONFLICT (permission_name) DO NOTHING;
-- +goose StatementEnd

-- +goose StatementBegin
-- Map new permissions to Admin role
WITH admin_role AS (
    SELECT id FROM public.user_roles WHERE role_name = 'Admin'
)
INSERT INTO public.role_permission_mapping (role_id, permission_id)
SELECT 
    admin_role.id,
    p.id
FROM public.app_permissions p
CROSS JOIN admin_role
WHERE p.permission_name IN ('ManageHostServers', 'ReadHostServers', 'ManageSshKeys')
AND NOT EXISTS (
    SELECT 1 FROM public.role_permission_mapping rpm
    WHERE rpm.role_id = admin_role.id 
    AND rpm.permission_id = p.id
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Remove permissions from Admin role
WITH admin_role AS (
    SELECT id FROM public.user_roles WHERE role_name = 'Admin'
)
DELETE FROM public.role_permission_mapping
WHERE role_id IN (SELECT id FROM admin_role)
AND permission_id IN (
    SELECT id FROM public.app_permissions 
    WHERE permission_name IN ('ManageHostServers', 'ReadHostServers', 'ManageSshKeys')
);
-- +goose StatementEnd

-- +goose StatementBegin
-- Remove the permissions
DELETE FROM public.app_permissions
WHERE permission_name IN ('ManageHostServers', 'ReadHostServers', 'ManageSshKeys');
-- +goose StatementEnd

-- +goose StatementBegin
-- Remove the external integration apps
DELETE FROM public.external_integration_apps
WHERE name IN ('ssh_keys', 'CloudflareDNS');
-- +goose StatementEnd

-- +goose StatementBegin
-- Remove the app_description column
ALTER TABLE public.external_integration_apps 
DROP COLUMN IF EXISTS app_description;
-- +goose StatementEnd 