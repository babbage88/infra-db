package main

import (
	"database/sql"
	"embed"
	"log/slog"
	"os"

	_ "github.com/jackc/pgx/v5/stdlib"
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

	db, err := sql.Open("pgx", os.Getenv("DATABASE_URL"))
	if err != nil {
		slog.Error("Error Initializing db", slog.String("error", err.Error()))
	}
	slog.Info("Starting migratioms")
	goose.SetBaseFS(embedMigrations)

	if err := goose.SetDialect("pgx"); err != nil {
		slog.Error("Error configuring driver for migration", slog.String("error", err.Error()))
	}

	if err := goose.Up(db, "migrations"); err != nil {
		slog.Error("Error configuring driver for migration", slog.String("error", err.Error()))
	}
}
