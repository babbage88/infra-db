-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.user_applications (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    repository_url TEXT NOT NULL,
    manifest_path TEXT,
    source_kind TEXT NOT NULL DEFAULT 'manual',
    module_name TEXT,
    package_name TEXT,
    package_manager TEXT,
    deploy_kind TEXT NOT NULL,
    registerable BOOLEAN NOT NULL DEFAULT TRUE,
    deploy_config JSONB NOT NULL DEFAULT '{}'::jsonb,
    build_config JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_modified timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.user_application_infra_dependencies (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_application_id uuid NOT NULL REFERENCES public.user_applications(id) ON DELETE CASCADE,
    dependency_type TEXT NOT NULL,
    dependency_name TEXT NOT NULL,
    host_server_type_id uuid REFERENCES public.host_server_types(host_server_type_id) ON DELETE SET NULL,
    platform_type_id uuid REFERENCES public.platform_types(platform_type_id) ON DELETE SET NULL,
    dependency_config JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_modified timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX IF NOT EXISTS idx_user_applications_repository_url
    ON public.user_applications(repository_url);

CREATE INDEX IF NOT EXISTS idx_user_application_infra_dependencies_app_id
    ON public.user_application_infra_dependencies(user_application_id);
-- +goose StatementEnd

-- +goose StatementBegin
INSERT INTO public.platform_types (name) VALUES
    ('Valkey'),
    ('Garage S3')
ON CONFLICT (name) DO NOTHING;
-- +goose StatementEnd

-- +goose StatementBegin
INSERT INTO public.app_permissions (permission_name, permission_description)
VALUES
    ('CreateUserApplication', 'Permission to register deployable user applications'),
    ('ReadUserApplications', 'Permission to read deployable user application registrations'),
    ('UpdateUserApplication', 'Permission to update deployable user application registrations'),
    ('DeleteUserApplication', 'Permission to delete deployable user application registrations')
ON CONFLICT (permission_name) DO NOTHING;
-- +goose StatementEnd

-- +goose StatementBegin
WITH admin_role AS (
    SELECT id FROM public.user_roles WHERE role_name = 'Admin'
)
INSERT INTO public.role_permission_mapping (role_id, permission_id)
SELECT
    admin_role.id,
    p.id
FROM public.app_permissions p
CROSS JOIN admin_role
WHERE p.permission_name IN ('CreateUserApplication', 'ReadUserApplications', 'UpdateUserApplication', 'DeleteUserApplication')
AND NOT EXISTS (
    SELECT 1
    FROM public.role_permission_mapping rpm
    WHERE rpm.role_id = admin_role.id
      AND rpm.permission_id = p.id
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
WITH admin_role AS (
    SELECT id FROM public.user_roles WHERE role_name = 'Admin'
)
DELETE FROM public.role_permission_mapping
WHERE role_id IN (SELECT id FROM admin_role)
  AND permission_id IN (
      SELECT id
      FROM public.app_permissions
      WHERE permission_name IN ('CreateUserApplication', 'ReadUserApplications', 'UpdateUserApplication', 'DeleteUserApplication')
  );
-- +goose StatementEnd

-- +goose StatementBegin
DELETE FROM public.app_permissions
WHERE permission_name IN ('CreateUserApplication', 'ReadUserApplications', 'UpdateUserApplication', 'DeleteUserApplication');
-- +goose StatementEnd

-- +goose StatementBegin
DROP INDEX IF EXISTS idx_user_application_infra_dependencies_app_id;
DROP INDEX IF EXISTS idx_user_applications_repository_url;
DROP TABLE IF EXISTS public.user_application_infra_dependencies;
DROP TABLE IF EXISTS public.user_applications;
-- +goose StatementEnd
