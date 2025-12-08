package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/tkozakas/dots/internal/config"
	"github.com/tkozakas/dots/internal/linker"
	"github.com/tkozakas/dots/internal/packages"
)

var installCmd = &cobra.Command{
	Use:   "install",
	Short: "Setup: symlinks → packages → benchmark",
	RunE:  runInstall,
}

func init() {
	rootCmd.AddCommand(installCmd)
}

func runInstall(cmd *cobra.Command, args []string) error {
	cfg, err := config.Load(configPath)
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}

	if err := linker.Link(cfg.SymlinksForCurrentOS(), configPath, dryRun); err != nil {
		return fmt.Errorf("creating symlinks: %w", err)
	}

	if err := packages.Install(cfg, distro, dryRun); err != nil {
		return fmt.Errorf("installing packages: %w", err)
	}

	if !dryRun {
		return Benchmark(10)
	}

	return nil
}
