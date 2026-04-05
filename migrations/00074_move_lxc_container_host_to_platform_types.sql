-- +goose Up
-- +goose StatementBegin
-- Move "LXC Container Host" from host_server_types to platform_types
-- This is an idempotent migration that safely handles if the entry already exists

-- First, delete any platform_type_mappings that reference LXC Container Host as a host_server_type
-- (so we can safely remove the host_server_type entry)
DELETE FROM public.platform_type_mappings
WHERE host_server_type_id IN (
    SELECT host_server_type_id FROM public.host_server_types 
    WHERE name = 'LXC Container Host'
);

-- Delete the host_server_type entry if it still exists
DELETE FROM public.host_server_types 
WHERE name = 'LXC Container Host';

-- Add "LXC Container Host" to platform_types if it doesn't exist
INSERT INTO public.platform_types (name) VALUES
    ('LXC Container Host')
ON CONFLICT (name) DO NOTHING;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Reverse: move "LXC Container Host" from platform_types back to host_server_types

-- Delete any platform_type_mappings that reference the platform_type
DELETE FROM public.platform_type_mappings
WHERE platform_type_id IN (
    SELECT platform_type_id FROM public.platform_types 
    WHERE name = 'LXC Container Host'
);

-- Delete the platform_type entry if it still exists
DELETE FROM public.platform_types 
WHERE name = 'LXC Container Host';

-- Add "LXC Container Host" back to host_server_types if it doesn't exist
INSERT INTO public.host_server_types (name) VALUES
    ('LXC Container Host')
ON CONFLICT (name) DO NOTHING;
-- +goose StatementEnd
