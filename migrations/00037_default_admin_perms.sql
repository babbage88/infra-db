-- +goose Up
-- +goose StatementBegin
-- Create a temporary table only if it doesn't exist, and clear it to avoid duplication
DROP TABLE IF EXISTS temp_admin_info;

CREATE TEMP TABLE temp_admin_info (
    dev_adminroleid uuid,
    devuser_id uuid
);

-- Insert Admin role ID and default Admin user ID into the temporary table
INSERT INTO temp_admin_info (dev_adminroleid, devuser_id)
SELECT 
    (SELECT id FROM public.user_roles WHERE role_name = 'Admin'),
-- +goose envsub on
    (SELECT id FROM public.users WHERE username = '${DEV_APP_USER}');
-- +goose envsub off
-- +goose StatementEnd

-- +goose StatementBegin
-- Insert permissions (idempotent via ON CONFLICT)
INSERT INTO public.app_permissions (permission_name, permission_description) VALUES
    ('CreatePermission', 'Create Permission'),
    ('CreateRole', 'Permission to Create User Roles'),
    ('CreateUser', 'Permission to Create Users'),
    ('AlterRole', 'Alter Role properties and Permissions to Create User Roles'),
    ('AlterUsers', 'Alter User properties and settings'),
    ('AlterPermission', 'Alter Permission properties'),
    ('ReadUsers', 'Read properties for all users on system'),
    ('DeleteUser', 'Delete Users'),
    ('DeleteRole', 'Delete Roles'),
    ('DeletePermission', 'Delete Permissions')
ON CONFLICT (permission_name) DO NOTHING;
-- +goose StatementEnd

-- +goose StatementBegin
INSERT INTO public.role_permission_mapping (role_id, permission_id)
SELECT t.dev_adminroleid, p.id
FROM public.app_permissions p
JOIN temp_admin_info t ON TRUE
WHERE p.permission_name IN (
    'CreateUser', 'AlterUsers', 'CreatePermission', 'AlterPermission',
    'AlterRole', 'DeleteUser', 'DeleteRole', 'DeletePermission'
)
AND NOT EXISTS (
    SELECT 1 FROM public.role_permission_mapping rpm
    WHERE rpm.role_id = t.dev_adminroleid AND rpm.permission_id = p.id
);
-- +goose StatementEnd


-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS temp_permissions;
CREATE TEMP TABLE temp_permissions AS
SELECT id FROM public.app_permissions
WHERE permission_name IN (
    'DeleteUser', 'DeleteRole', 'DeletePermission',
    'CreateRole', 'AlterRole', 'CreatePermission', 'AlterPermission', 'CreateUser', 'AlterUsers', 'ReadUsers'
);
-- +goose StatementEnd

-- +goose StatementBegin
DROP TABLE IF EXISTS temp_admin_info;
CREATE TEMP TABLE temp_admin_info (
    dev_adminroleid uuid
);

INSERT INTO temp_admin_info (dev_adminroleid)
SELECT id FROM public.user_roles WHERE role_name = 'Admin';
-- +goose StatementEnd

-- +goose StatementBegin
DELETE FROM public.role_permission_mapping
WHERE role_id IN (SELECT dev_adminroleid FROM temp_admin_info)
AND permission_id IN (SELECT id FROM temp_permissions);
-- +goose StatementEnd

-- +goose StatementBegin
DELETE FROM public.app_permissions
WHERE id IN (SELECT id FROM temp_permissions);
-- +goose StatementEnd
