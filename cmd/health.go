package cmd

import (
	"fmt"
	"log"

	"github.com/spf13/cobra"
	"github.com/tkozakas/dots/internal/config"
	"github.com/tkozakas/dots/internal/linker"
)

const (
	colorReset  = "\033[0m"
	colorGreen  = "\033[32m"
	colorYellow = "\033[33m"
	colorRed    = "\033[31m"
)

var healthCmd = &cobra.Command{
	Use:   "health",
	Short: "Verify symlinks",
	RunE:  runHealth,
}

func init() {
	rootCmd.AddCommand(healthCmd)
}

func runHealth(cmd *cobra.Command, args []string) error {
	cfg, err := config.Load(configPath)
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}

	ok, missing, broken := linker.Health(cfg.SymlinksForCurrentOS(), configPath)
	log.Printf("Total: %s%d OK%s, %s%d missing%s, %s%d broken%s",
		colorGreen, ok, colorReset,
		colorYellow, missing, colorReset,
		colorRed, broken, colorReset)

	if broken > 0 || missing > 0 {
		return fmt.Errorf("health check failed")
	}
	return nil
}
