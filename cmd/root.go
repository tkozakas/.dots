package cmd

import (
	"log"

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
	log.SetFlags(0)
	if err := rootCmd.Execute(); err != nil {
		log.Fatal(err)
	}
}

func init() {
	rootCmd.PersistentFlags().StringVarP(&configPath, "config", "c", "dotfiles.yaml", "Config file path")
	rootCmd.PersistentFlags().StringVar(&distro, "distro", "", "Override detected distribution")
	rootCmd.PersistentFlags().BoolVar(&dryRun, "dry-run", false, "Preview changes")
}
