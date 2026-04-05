-- +goose Up

-- +goose StatementBegin
-- Add CreateRole permission to Admin role if not already assigned
INSERT INTO public.role_permission_mapping (role_id, permission_id)
SELECT 
    (SELECT id FROM public.user_roles WHERE role_name = 'Admin'),
    (SELECT id FROM public.app_permissions WHERE permission_name = 'CreateRole')
WHERE NOT EXISTS (
    SELECT 1 FROM public.role_permission_mapping
    WHERE role_id = (SELECT id FROM public.user_roles WHERE role_name = 'Admin')
    AND permission_id = (SELECT id FROM public.app_permissions WHERE permission_name = 'CreateRole')
);
-- +goose StatementEnd

-- +goose Down

-- +goose StatementBegin
-- Remove CreateRole permission from Admin role
DELETE FROM public.role_permission_mapping
WHERE role_id = (SELECT id FROM public.user_roles WHERE role_name = 'Admin')
AND permission_id = (SELECT id FROM public.app_permissions WHERE permission_name = 'CreateRole');
-- +goose StatementEnd
