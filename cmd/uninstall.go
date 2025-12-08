package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/tkozakas/dots/internal/config"
	"github.com/tkozakas/dots/internal/linker"
)

var uninstallCmd = &cobra.Command{
	Use:   "uninstall",
	Short: "Cleanup: remove symlinks",
	RunE:  runUninstall,
}

func init() {
	rootCmd.AddCommand(uninstallCmd)
}

func runUninstall(cmd *cobra.Command, args []string) error {
	cfg, err := config.Load(configPath)
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}

	return linker.Unlink(cfg.SymlinksForCurrentOS(), configPath, dryRun)
}
