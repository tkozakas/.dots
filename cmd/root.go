package cmd

import (
	"log"
	"os"
	"path/filepath"

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
	home, _ := os.UserHomeDir()
	defaultConfig := filepath.Join(home, ".dots", "dotfiles.yaml")
	rootCmd.PersistentFlags().StringVarP(&configPath, "config", "c", defaultConfig, "Config file path")
	rootCmd.PersistentFlags().StringVar(&distro, "distro", "", "Override detected distribution")
	rootCmd.PersistentFlags().BoolVar(&dryRun, "dry-run", false, "Preview changes")
}
