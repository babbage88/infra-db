package main

import (
	"embed"
	"log/slog"

	"github.com/babbage88/infra-db/infra_db"
)

//go:embed migrations/*
var embededMigrations embed.FS

func main() {
	err := godotenv.Load(".env")
	if err != nil {
		slog.Error("Error loading .env",  slog.String("error", err.Error()))
	}
	db, err := infra_db.InitializeDbConnectionFromUrl(dbUrl string)
	
	slog.Info("Starting migratioms")
	goose.SetBaseFS(embedMigrations)

	if err := goose.SetDialect("postgres"); err != nil {
		    panic(err)
	}

	if err := goose.Up(db, "migrations"); err != nil {
		    panic(err)
	}	
}
