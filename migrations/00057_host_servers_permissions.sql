-- +goose Up
-- +goose StatementBegin
-- Insert host server permissions if they don't exist (idempotent)
INSERT INTO public.app_permissions (permission_name, permission_description)
VALUES 
    ('ManageHostServers', 'Permission to manage host servers (create, update, delete)'),
    ('ReadHostServers', 'Permission to read host server properties')
ON CONFLICT (permission_name) DO NOTHING;
-- +goose StatementEnd

-- +goose StatementBegin
-- Map host server permissions to Admin role if not already mapped
WITH admin_role AS (
    SELECT id FROM public.user_roles WHERE role_name = 'Admin'
)
INSERT INTO public.role_permission_mapping (role_id, permission_id)
SELECT 
    admin_role.id,
    p.id
FROM public.app_permissions p
CROSS JOIN admin_role
WHERE p.permission_name IN ('ManageHostServers', 'ReadHostServers')
AND NOT EXISTS (
    SELECT 1 FROM public.role_permission_mapping rpm
    WHERE rpm.role_id = admin_role.id 
    AND rpm.permission_id = p.id
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Remove host server permissions from Admin role
WITH admin_role AS (
    SELECT id FROM public.user_roles WHERE role_name = 'Admin'
)
DELETE FROM public.role_permission_mapping
WHERE role_id IN (SELECT id FROM admin_role)
AND permission_id IN (
    SELECT id FROM public.app_permissions 
    WHERE permission_name IN ('ManageHostServers', 'ReadHostServers')
);
-- +goose StatementEnd