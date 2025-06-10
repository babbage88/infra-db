-- +goose Up
-- +goose StatementBegin
ALTER TABLE public.host_servers DROP CONSTRAINT IF EXISTS unique_hostname_ip;
ALTER TABLE public.host_servers DROP CONSTRAINT IF EXISTS check_servers_id_nonzero;
-- +goose StatementEnd
-- +goose StatementBegin
DROP TABLE IF EXISTS public.host_servers;
-- +goose StatementEnd


-- +goose StatementBegin 
CREATE TABLE IF NOT EXISTS public.ssh_keys (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    description text NULL,
    priv_secret_id uuid REFERENCES public.external_auth_tokens (id) ON DELETE CASCADE,
    public_key text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
-- +goose StatementEnd

-- +goose StatementBegin 
CREATE TABLE IF NOT EXISTS public.host_servers (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    hostname text NOT NULL,
    ip_address inet NOT NULL,
    is_container_host boolean,
    is_vm_host boolean,
    is_virtual_machine boolean,
    id_db_host boolean,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
   	CONSTRAINT unique_hostname_ip UNIQUE (hostname, ip_address)

);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE public.host_servers DROP CONSTRAINT IF EXISTS unique_hostname_ip;
ALTER TABLE public.host_servers DROP CONSTRAINT IF EXISTS check_servers_id_nonzero;
-- +goose StatementEnd

-- +goose StatementBegin
DROP TABLE public.host_servers;
-- +goose StatementEnd

-- +goose StatementBegin
CREATE TABLE public.host_servers (
	id serial4  NOT NULL,
	hostname varchar(255) NOT NULL,
	ip_address inet NOT NULL,
	username varchar(255) NULL,
	public_ssh_keyname varchar(255) NULL,
	hosted_domains _varchar NULL,
	ssl_key_path varchar(4098) NULL,
	is_container_host bool NULL,
	is_vm_host bool NULL,
	is_virtual_machine bool NULL,
	id_db_host bool NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	last_modified timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT check_servers_id_nonzero CHECK ((id > 0)),
	CONSTRAINT host_servers_pkey PRIMARY KEY (id),
	CONSTRAINT unique_hostname_ip UNIQUE (hostname, ip_address)
);
CREATE INDEX host_servers_idx_hostname ON public.host_servers USING btree (hostname);
CREATE INDEX host_servers_idx_username ON public.host_servers USING btree (username);
-- +goose StatementEnd

-- +goose StatementBegin
DROP TABLE IF EXISTS public.ssh_keys;
-- +goose StatementEnd
