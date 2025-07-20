-- +goose Up
ALTER TABLE public.host_server_type_mappings
  ADD CONSTRAINT host_server_type_mappings_unique UNIQUE (host_server_id, host_server_type_id);

ALTER TABLE public.platform_type_mappings
  ADD CONSTRAINT platform_type_mappings_unique UNIQUE (platform_type_id, host_server_id, host_server_type_id);

-- +goose Down
ALTER TABLE public.host_server_type_mappings
  DROP CONSTRAINT IF EXISTS host_server_type_mappings_unique;

ALTER TABLE public.platform_type_mappings
  DROP CONSTRAINT IF EXISTS platform_type_mappings_unique; 