package cmd

import (
	"fmt"
	"log"

	"github.com/spf13/cobra"
	"github.com/tkozakas/dots/internal/config"
	"github.com/tkozakas/dots/internal/extensions"
	"github.com/tkozakas/dots/internal/hooks"
	"github.com/tkozakas/dots/internal/linker"
	"github.com/tkozakas/dots/internal/packages"
)

var installCmd = &cobra.Command{
	Use:   "install",
	Short: "Setup: symlinks → packages → health → benchmark",
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

	symlinks := cfg.SymlinksForCurrentOS()

	if err := linker.Link(symlinks, configPath, dryRun); err != nil {
		return fmt.Errorf("creating symlinks: %w", err)
	}

	if !skipPackages {
		if err := packages.Install(cfg, distro, dryRun); err != nil {
			return fmt.Errorf("installing packages: %w", err)
		}
	}

	if err := hooks.RunPostInstall(cfg.Hooks, dryRun); err != nil {
		return fmt.Errorf("running hooks: %w", err)
	}

	extensions.Run(distro, dryRun, skipPackages)

	if dryRun {
		return nil
	}

	if err := checkHealth(symlinks); err != nil {
		return err
	}

	return benchmark(10)
}

func checkHealth(symlinks []config.Symlink) error {
	log.Println("\n=== Health Check ===")

	ok, missing, broken := linker.Health(symlinks, configPath)
	log.Printf("Total: %d OK, %d missing, %d broken", ok, missing, broken)

	if broken > 0 || missing > 0 {
		return fmt.Errorf("health check failed")
	}
	return nil
}
