package cmd

import (
	"fmt"
	"log"
	"os"
	"path/filepath"

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

	extSymlinks := extensions.Run(distro, dryRun, skipPackages)

	if dryRun {
		return nil
	}

	if err := checkHealth(symlinks, extSymlinks); err != nil {
		return err
	}

	return benchmark(10)
}

func checkHealth(symlinks, extSymlinks []config.Symlink) error {
	log.Println("\n=== Health Check ===")

	overrides := make(map[string]bool)
	for _, s := range extSymlinks {
		overrides[s.Target] = true
	}

	var filtered []config.Symlink
	for _, s := range symlinks {
		if !overrides[s.Target] {
			filtered = append(filtered, s)
		}
	}

	ok, missing, broken := linker.Health(filtered, configPath)

	if len(extSymlinks) > 0 {
		home, _ := os.UserHomeDir()
		extCfgPath := filepath.Join(home, ".dots-work", "dotfiles.yaml")
		extOk, extMissing, extBroken := linker.Health(extSymlinks, extCfgPath)
		ok += extOk
		missing += extMissing
		broken += extBroken
	}

	log.Printf("Total: %d OK, %d missing, %d broken", ok, missing, broken)

	if broken > 0 || missing > 0 {
		return fmt.Errorf("health check failed")
	}
	return nil
}
