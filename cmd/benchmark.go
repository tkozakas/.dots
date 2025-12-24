package cmd

import (
	"log"
	"os"
	"os/exec"
	"time"

	"github.com/spf13/cobra"
)

var benchmarkCmd = &cobra.Command{
	Use:   "benchmark",
	Short: "Test shell startup time",
	RunE: func(cmd *cobra.Command, args []string) error {
		return benchmark(10)
	},
}

func init() {
	rootCmd.AddCommand(benchmarkCmd)
}

func benchmark(runs int) error {
	shell := os.Getenv("SHELL")
	if shell == "" {
		shell = "zsh"
	}

	log.Printf("\n=== %s Startup Benchmark ===", shell)
	log.Printf("Running %d iterations...", runs)

	var total time.Duration
	for range runs {
		total += measureShellStartup(shell)
	}

	avg := total / time.Duration(runs)
	log.Printf("Average: %v", avg.Round(time.Millisecond))

	return nil
}

func measureShellStartup(shell string) time.Duration {
	start := time.Now()
	cmd := exec.Command(shell, "-i", "-c", "exit")
	cmd.Stdout = nil
	cmd.Stderr = nil
	_ = cmd.Run()
	return time.Since(start)
}
