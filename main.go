package main

import (
	"embed"
	"log/slog"
	"os"

	"github.com/babbage88/infra-db/infra_db"
	"github.com/joho/godotenv"
	"github.com/pressly/goose/v3"
)

//go:embed migrations/*
var embedMigrations embed.FS

func main() {
	err := godotenv.Load(".env")
	if err != nil {
		slog.Error("Error loading .env", slog.String("error", err.Error()))
	}

	db, err := infra_db.InitializeDbConnectionFromUrl(os.Getenv("DATABASE_URL"))

	if err != nil {
		slog.Error("Error Initializing db", slog.String("error", err.Error()))
	}

	slog.Info("Starting migratioms")
	goose.SetBaseFS(embedMigrations)

	if err := goose.SetDialect("postgres"); err != nil {
		panic(err)
	}

	if err := goose.Up(db, "migrations"); err != nil {
		panic(err)
	}
}
