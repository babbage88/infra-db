package main

import (
	"embed"
	"log/slog"
)

//go:embed migrations/*
var migrations embed.FS

func main() {
	slog.Info("Starting migratioms")
}
