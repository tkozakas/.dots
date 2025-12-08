package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/tom/dots/internal/config"
	"github.com/tom/dots/internal/linker"
)

var unlinkCmd = &cobra.Command{
	Use:   "unlink",
	Short: "Remove symlinks created by dots",
	RunE:  runUnlink,
}

func init() {
	rootCmd.AddCommand(unlinkCmd)
}

func runUnlink(cmd *cobra.Command, args []string) error {
	cfg, err := config.Load(configPath)
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}

	return linker.Unlink(cfg.SymlinksForCurrentOS(), configPath, dryRun)
}
