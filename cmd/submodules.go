package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/tom/dots/internal/linker"
	"github.com/tom/dots/internal/submodule"
)

var submodulesCmd = &cobra.Command{
	Use:   "submodules",
	Short: "Initialize and update git submodules",
	RunE:  runSubmodules,
}

func init() {
	rootCmd.AddCommand(submodulesCmd)
}

func runSubmodules(cmd *cobra.Command, args []string) error {
	baseDir := linker.ResolveBaseDir(configPath)

	if err := submodule.Init(baseDir, dryRun); err != nil {
		return fmt.Errorf("initializing submodules: %w", err)
	}

	return nil
}
