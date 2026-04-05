-- +goose Up

-- +goose StatementBegin
-- Add DeleteRole permission to Admin role if not already assigned
INSERT INTO public.role_permission_mapping (role_id, permission_id)
SELECT 
    (SELECT id FROM public.user_roles WHERE role_name = 'Admin'),
    (SELECT id FROM public.app_permissions WHERE permission_name = 'DeleteRole')
WHERE NOT EXISTS (
    SELECT 1 FROM public.role_permission_mapping
    WHERE role_id = (SELECT id FROM public.user_roles WHERE role_name = 'Admin')
    AND permission_id = (SELECT id FROM public.app_permissions WHERE permission_name = 'DeleteRole')
);
-- +goose StatementEnd

-- +goose Down

-- +goose StatementBegin
-- Remove DeleteRole permission from Admin role
DELETE FROM public.role_permission_mapping
WHERE role_id = (SELECT id FROM public.user_roles WHERE role_name = 'Admin')
AND permission_id = (SELECT id FROM public.app_permissions WHERE permission_name = 'DeleteRole');
-- +goose StatementEnd
