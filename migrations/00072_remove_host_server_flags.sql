-- +goose Up
ALTER TABLE public.host_servers
  DROP COLUMN IF EXISTS is_container_host,
  DROP COLUMN IF EXISTS is_vm_host,
  DROP COLUMN IF EXISTS is_virtual_machine,
  DROP COLUMN IF EXISTS id_db_host;

-- +goose Down
ALTER TABLE public.host_servers
  ADD COLUMN is_container_host boolean DEFAULT false,
  ADD COLUMN is_vm_host boolean DEFAULT false,
  ADD COLUMN is_virtual_machine boolean DEFAULT false,
  ADD COLUMN id_db_host boolean DEFAULT false; 