package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/tom/dots/internal/config"
	"github.com/tom/dots/internal/linker"
)

var linkCmd = &cobra.Command{
	Use:   "link",
	Short: "Create symlinks",
	RunE:  runLink,
}

func init() {
	rootCmd.AddCommand(linkCmd)
}

func runLink(cmd *cobra.Command, args []string) error {
	cfg, err := config.Load(configPath)
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}

	return linker.Link(cfg.SymlinksForCurrentOS(), configPath, dryRun)
}
