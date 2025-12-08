package cmd

import (
	"fmt"
	"log"

	"github.com/spf13/cobra"
	"github.com/tkozakas/dots/internal/config"
	"github.com/tkozakas/dots/internal/linker"
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
	log.Printf("Total: %d OK, %d missing, %d broken", ok, missing, broken)

	if broken > 0 || missing > 0 {
		return fmt.Errorf("health check failed")
	}
	return nil
}
