-- +goose Up
-- +goose StatementBegin
-- Add "Valkey", "Redis", and "S3 Object Storage" as platform types
INSERT INTO public.platform_types (name) VALUES
    ('Valkey'),
    ('Redis'),
    ('S3 Object Storage')
ON CONFLICT (name) DO NOTHING;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Remove "Valkey", "Redis", and "S3 Object Storage" platform types
DELETE FROM public.platform_types 
WHERE name IN ('Valkey', 'Redis', 'S3 Object Storage');
-- +goose StatementEnd
