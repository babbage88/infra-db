-- +goose Up

-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS users_idx_user_id ON users(id, username);
CREATE INDEX IF NOT EXISTS users_idx_created ON users(created_at);
-- +goose StatementEnd

-- +goose StatementBegin

-- Drop and recreate temp table for Admin role and user ID
DROP TABLE IF EXISTS temp_admin_info;

CREATE TEMP TABLE temp_admin_info (
    dev_adminroleid uuid,
    devuser_id uuid
);

-- Insert Admin role ID and default Admin user ID into the temp table
INSERT INTO temp_admin_info (dev_adminroleid, devuser_id)
SELECT 
    (SELECT id FROM public.user_roles WHERE role_name = 'Admin'),
-- +goose envsub on
    (SELECT id FROM public.users WHERE username = '${DEV_APP_USER}')
-- +goose envsub off
;

-- +goose StatementEnd

-- +goose StatementBegin
-- Ensure required permissions exist (idempotent)
INSERT INTO public.app_permissions (permission_name, permission_description)
VALUES
    ('CreatePermission', 'Create Permission'),
    ('CreateRole', 'Permission to Create User Roles'),
    ('CreateUser', 'Permission to Create Users'),
    ('AlterRole', 'Alter Role properties and Permissions to Create User Roles'),
    ('AlterUsers', 'Alter User properties and settings'),
    ('AlterPermission', 'Alter Permission properties'),
    ('AlterDb', 'Alter Database properties'),
    ('ReadUsers', 'Read properties for all users on system'),
    ('ReadRoles', 'Read properties for all roles on system'),
    ('ReadPermissions', 'Read properties for all permissions on system'),
    ('DeleteUser', 'Delete Users'),
    ('DeleteDb', 'Delete Databases'),
    ('DeleteRole', 'Delete Roles'),
    ('DeletePermission', 'Delete Permissions')
ON CONFLICT (permission_name) DO NOTHING;
-- +goose StatementEnd

-- +goose StatementBegin
-- Grant all permissions to Admin role if not already mapped
INSERT INTO public.role_permission_mapping (role_id, permission_id)
SELECT t.dev_adminroleid, p.id
FROM public.app_permissions p
JOIN temp_admin_info t ON TRUE
WHERE p.permission_name IN (
    'CreateUser', 
    'AlterUsers', 
    'CreatePermission', 
    'AlterPermission',
    'AlterRole', 
    'AlterDb',
    'DeleteUser', 
    'DeleteRole', 
    'DeletePermission',
    'DeleteDb', 
    'ReadUsers', 
    'ReadRoles', 
    'ReadPermissions'
)
AND NOT EXISTS (
    SELECT 1 FROM public.role_permission_mapping rpm
    WHERE rpm.role_id = t.dev_adminroleid AND rpm.permission_id = p.id
);
-- +goose StatementEnd

-- +goose Down

-- +goose StatementBegin
DROP INDEX IF EXISTS users_idx_user_id;
DROP INDEX IF EXISTS users_idx_created;
-- +goose StatementEnd

-- +goose StatementBegin
-- Collect permission IDs to remove
DROP TABLE IF EXISTS temp_permissions;
CREATE TEMP TABLE temp_permissions AS
SELECT id FROM public.app_permissions
WHERE permission_name IN (
    'CreateUser', 
    'AlterUsers', 
    'CreatePermission', 
    'AlterPermission',
    'AlterRole', 
    'AlterDb',
    'DeleteUser', 
    'DeleteRole', 
    'DeletePermission',
    'DeleteDb', 
    'ReadUsers', 
    'ReadRoles', 
    'ReadPermissions');
-- +goose StatementEnd

-- +goose StatementBegin
-- Recreate temp_admin_info to get Admin role ID
DROP TABLE IF EXISTS temp_admin_info;
CREATE TEMP TABLE temp_admin_info (
    dev_adminroleid uuid
);

INSERT INTO temp_admin_info (dev_adminroleid)
SELECT id FROM public.user_roles WHERE role_name = 'Admin';
-- +goose StatementEnd

-- +goose StatementBegin
-- Remove permission mappings for Admin role
DELETE FROM public.role_permission_mapping
WHERE role_id IN (SELECT dev_adminroleid FROM temp_admin_info)
AND permission_id IN (SELECT id FROM temp_permissions);
-- +goose StatementEnd

-- +goose StatementBegin
-- Remove the permissions themselves
DELETE FROM public.app_permissions
WHERE id IN (SELECT id FROM temp_permissions);
-- +goose StatementEnd
