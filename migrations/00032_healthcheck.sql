-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS public.health_check (
    id integer not NULL,
    status character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_modified timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE SEQUENCE IF NOT EXISTS public.health_check_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.health_check_id_seq OWNED BY public.health_check.id;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP SEQUENCE public.health_check_id_seq;
DROP TABLE public.health_check;
-- +goose StatementEnd
