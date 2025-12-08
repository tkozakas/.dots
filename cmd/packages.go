package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
	"github.com/tom/dots/internal/config"
	"github.com/tom/dots/internal/packages"
)

var packagesCmd = &cobra.Command{
	Use:   "packages",
	Short: "Install packages",
	RunE:  runPackages,
}

func init() {
	rootCmd.AddCommand(packagesCmd)
}

func runPackages(cmd *cobra.Command, args []string) error {
	cfg, err := config.Load(configPath)
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}

	return packages.Install(cfg, distro, dryRun)
}
