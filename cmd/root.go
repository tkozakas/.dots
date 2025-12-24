package cmd

import (
	"log"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
)

var (
	configPath   string
	distro       string
	dryRun       bool
	skipPackages bool
)

var rootCmd = &cobra.Command{
	Use:               "dots",
	Short:             "Dotfiles manager",
	CompletionOptions: cobra.CompletionOptions{DisableDefaultCmd: true},
}

func Execute() {
	log.SetFlags(0)
	if err := rootCmd.Execute(); err != nil {
		log.Fatal(err)
	}
}

func init() {
	rootCmd.PersistentFlags().StringVarP(&configPath, "config", "c", defaultConfigPath(), "config file")
	rootCmd.PersistentFlags().StringVar(&distro, "distro", "", "override distro")
	rootCmd.PersistentFlags().BoolVar(&dryRun, "dry-run", false, "preview changes")
	rootCmd.PersistentFlags().BoolVar(&skipPackages, "skip-packages", false, "skip package installation")
}

func defaultConfigPath() string {
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".dots", "dotfiles.yaml")
}
