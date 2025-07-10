-- +goose Up
-- +goose StatementBegin
ALTER TABLE public.host_server_types ADD COLUMN last_modified TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE public.platform_types ADD COLUMN last_modified TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE public.host_server_type_mappings ADD COLUMN last_modified TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE public.platform_type_mappings ADD COLUMN last_modified TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE public.host_server_types DROP COLUMN last_modified;
ALTER TABLE public.platform_types DROP COLUMN last_modified;
ALTER TABLE public.host_server_type_mappings DROP COLUMN last_modified;
ALTER TABLE public.platform_type_mappings DROP COLUMN last_modified;
-- +goose StatementEnd
