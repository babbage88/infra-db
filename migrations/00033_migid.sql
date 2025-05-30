-- +goose Up

-- +goose StatementBegin
DROP VIEW role_permissions_view;
DROP VIEW users_with_roles;
DROP VIEW user_permissions_view;
DROP VIEW user_roles_active;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE auth_tokens DROP CONSTRAINT IF EXISTS auth_tokens_user_id_fkey;
ALTER TABLE user_hosted_db DROP CONSTRAINT IF EXISTS user_hosted_db_platforms_id_fkey;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE user_role_mapping DROP CONSTRAINT IF EXISTS fk_user;
ALTER TABLE user_role_mapping DROP CONSTRAINT IF EXISTS fk_role;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE role_permission_mapping DROP CONSTRAINT IF EXISTS fk_permission;
ALTER TABLE role_permission_mapping DROP CONSTRAINT IF EXISTS fk_role;
ALTER TABLE role_permission_mapping DROP CONSTRAINT IF EXISTS unique_perm_role_id;
ALTER TABLE role_permission_mapping DROP CONSTRAINT IF EXISTS role_permission_mapping_pkey;
-- +goose StatementEnd

-- +goose StatementBegin
DROP TABLE IF EXISTS auth_tokens;
DROP TABLE IF EXISTS public.app_permissions;
DROP TABLE IF EXISTS public.user_roles;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.users_audit;
DROP TABLE IF EXISTS public.user_role_mapping;
DROP TABLE IF EXISTS public.role_permission_mapping;
DROP TABLE IF EXISTS public.app_permissions;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.app_permissions (
	id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	permission_name varchar(255) NOT NULL,
	permission_description text NULL,
	CONSTRAINT unique_permission_name UNIQUE (permission_name)
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.user_roles (
	id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	role_name varchar(255) NOT NULL,
	role_description text NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	last_modified timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	enabled bool DEFAULT true NOT NULL,
	is_deleted bool DEFAULT false NOT NULL,
	CONSTRAINT unique_role_name UNIQUE (role_name)
);
CREATE INDEX user_roles_idx_created_at ON public.user_roles USING btree (created_at);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.users (
	id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	username varchar(255) NULL,
	"password" text NULL,
	email varchar(255) NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	last_modified timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	enabled bool DEFAULT true NOT NULL,
	is_deleted bool DEFAULT false NOT NULL,
	CONSTRAINT unique_email UNIQUE (email),
	CONSTRAINT unique_username UNIQUE (username)
);
CREATE INDEX users_idx_created ON public.users USING btree (created_at);
CREATE INDEX users_idx_user_id ON public.users USING btree (id, username);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.role_permission_mapping (
	id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	role_id uuid NOT NULL,
	permission_id uuid NOT NULL,
	enabled bool DEFAULT true NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	last_modified timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT unique_perm_role_id UNIQUE (permission_id, role_id)
);

-- public.role_permission_mapping foreign keys
ALTER TABLE public.role_permission_mapping ADD CONSTRAINT fk_permission FOREIGN KEY (permission_id) REFERENCES public.app_permissions(id) ON DELETE CASCADE;
ALTER TABLE public.role_permission_mapping ADD CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES public.user_roles(id) ON DELETE CASCADE;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.user_role_mapping (
	id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	user_id uuid NOT NULL,
	role_id uuid NOT NULL,
	enabled bool DEFAULT true NOT NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	last_modified timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT unique_user_role_id UNIQUE (user_id, role_id)
);

-- public.user_role_mapping foreign keys
ALTER TABLE public.user_role_mapping ADD CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES public.user_roles(id) ON DELETE CASCADE;
ALTER TABLE public.user_role_mapping ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.users_audit (
    audit_id serial4 PRIMARY KEY,
    user_id uuid NULL,  -- No foreign key constraint
    username varchar(255) NULL,
    email varchar(255) NULL,
    deleted_at timestamptz DEFAULT now() NULL,
    deleted_by varchar(255) NULL
);
-- +goose StatementEnd

-- +goose StatementBegin
CREATE INDEX idx_users_audit_user_id ON public.users_audit(user_id);
-- +goose StatementEnd

-- +goose StatementBegin
-- Create or replace the function to log user deletions
CREATE OR REPLACE FUNCTION log_user_deletion()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO users_audit (user_id, username, email, deleted_at, deleted_by)
    VALUES (OLD.id, OLD.username, OLD.email, now(), current_user);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

-- Table Triggers

-- +goose StatementBegin
DROP TRIGGER IF EXISTS user_delete_trigger ON users;
CREATE TRIGGER user_delete_trigger
--BEFORE DELETE ON users
AFTER DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION log_user_deletion();
-- +goose StatementEnd


-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.auth_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	user_id uuid REFERENCES users (id),
	"token" text NULL,
	expiration timestamp NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	last_modified timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE INDEX auth_token_idx_created_at ON public.auth_tokens USING btree (created_at);
CREATE INDEX auth_token_idx_userid ON public.auth_tokens USING btree (user_id);
-- +goose StatementEnd


-- +goose Down

-- +goose StatementBegin
DELETE FROM public.users WHERE "username" = 'devuser';
DELETE FROM public.user_roles WHERE role_name = 'Admin';
DELETE FROM public.app_permissions WHERE permission_name IN ('CreateUser', 'AlterUser', 'CreateShare');
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE auth_tokens DROP CONSTRAINT IF EXISTS auth_tokens_user_id_fkey;
ALTER TABLE user_hosted_db DROP CONSTRAINT IF EXISTS user_hosted_db_platforms_id_fkey;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE user_role_mapping DROP CONSTRAINT IF EXISTS fk_user;
ALTER TABLE user_role_mapping DROP CONSTRAINT IF EXISTS fk_role;
-- +goose StatementEnd

-- +goose StatementBegin
ALTER TABLE role_permission_mapping DROP CONSTRAINT IF EXISTS fk_permission;
ALTER TABLE role_permission_mapping DROP CONSTRAINT IF EXISTS fk_role;
ALTER TABLE role_permission_mapping DROP CONSTRAINT IF EXISTS unique_perm_role_id;
ALTER TABLE role_permission_mapping DROP CONSTRAINT IF EXISTS role_permission_mapping_pkey;
-- +goose StatementEnd

-- +goose StatementBegin
DROP TABLE IF EXISTS auth_tokens;
DROP TABLE IF EXISTS public.app_permissions;
DROP TABLE IF EXISTS public.user_roles;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.users_audit;
DROP TABLE IF EXISTS public.user_role_mapping;
DROP TABLE IF EXISTS public.role_permission_mapping;
DROP TABLE IF EXISTS public.app_permissions;
-- +goose StatementEnd