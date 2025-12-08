package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var (
	distro     string
	dryRun     bool
	configPath string
)

var rootCmd = &cobra.Command{
	Use:   "dots",
	Short: "Dotfiles manager",
}

func Execute() {
	err := rootCmd.Execute()
	if err == nil {
		return
	}
	fmt.Fprintln(os.Stderr, err)
	os.Exit(1)
}

func init() {
	rootCmd.PersistentFlags().StringVarP(&configPath, "config", "c", "dotfiles.yaml", "Config file path")
	rootCmd.PersistentFlags().StringVar(&distro, "distro", "", "Override detected distribution")
	rootCmd.PersistentFlags().BoolVar(&dryRun, "dry-run", false, "Preview changes")
}
