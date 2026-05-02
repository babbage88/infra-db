// infractl:name=infra-db
// infractl:description=Database migrations and goose assets consumed by registerable infractl applications.
// infractl:repository_url=https://github.com/babbage88/infra-db
// infractl:manifest_path=go.mod
// infractl:deploy_kind=migrations
// infractl:package_manager=go
// infractl:registerable=false
// infractl:build_config={"migrationBinary":"goosey","migrationPath":"migrations"}
module github.com/babbage88/infra-db

go 1.24.0

toolchain go1.24.3

require (
	github.com/jackc/pgx/v5 v5.7.4
	github.com/joho/godotenv v1.5.1
	github.com/pressly/goose/v3 v3.24.3
)

require (
	github.com/jackc/pgpassfile v1.0.0 // indirect
	github.com/jackc/pgservicefile v0.0.0-20240606120523-5a60cdf6a761 // indirect
	github.com/jackc/puddle/v2 v2.2.2 // indirect
	github.com/mfridman/interpolate v0.0.2 // indirect
	github.com/sethvargo/go-retry v0.3.0 // indirect
	go.uber.org/multierr v1.11.0 // indirect
	golang.org/x/crypto v0.38.0 // indirect
	golang.org/x/sync v0.14.0 // indirect
	golang.org/x/text v0.25.0 // indirect
)
