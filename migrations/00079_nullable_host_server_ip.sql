-- +goose Up
ALTER TABLE public.host_servers
  ALTER COLUMN ip_address DROP NOT NULL;

-- +goose Down
UPDATE public.host_servers
SET ip_address = '0.0.0.0'::inet
WHERE ip_address IS NULL;

ALTER TABLE public.host_servers
  ALTER COLUMN ip_address SET NOT NULL;
