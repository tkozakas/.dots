package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/tom/dots/internal/config"
	"github.com/tom/dots/internal/linker"
	"github.com/tom/dots/internal/packages"
	"github.com/tom/dots/internal/submodule"
)

var installCmd = &cobra.Command{
	Use:   "install",
	Short: "Run full dotfiles setup",
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

	baseDir := linker.ResolveBaseDir(configPath)

	if err := submodule.Init(baseDir, dryRun); err != nil {
		return fmt.Errorf("initializing submodules: %w", err)
	}

	if err := linker.Link(cfg.SymlinksForCurrentOS(), configPath, dryRun); err != nil {
		return fmt.Errorf("creating symlinks: %w", err)
	}

	if err := packages.Install(cfg, distro, dryRun); err != nil {
		return fmt.Errorf("installing packages: %w", err)
	}

	if !dryRun {
		if err := Benchmark(10); err != nil {
			return fmt.Errorf("running benchmark: %w", err)
		}
	}

	return nil
}
