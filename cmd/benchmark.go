package cmd

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"time"

	"github.com/spf13/cobra"
)

var benchmarkRuns int

var benchmarkCmd = &cobra.Command{
	Use:   "benchmark",
	Short: "Test shell startup time",
	RunE:  runBenchmark,
}

func init() {
	benchmarkCmd.Flags().IntVarP(&benchmarkRuns, "runs", "n", 10, "Number of iterations")
	rootCmd.AddCommand(benchmarkCmd)
}

func runBenchmark(cmd *cobra.Command, args []string) error {
	return Benchmark(benchmarkRuns)
}

func Benchmark(runs int) error {
	shell := os.Getenv("SHELL")
	if shell == "" {
		shell = "zsh"
	}

	log.Printf("=== %s Startup Benchmark ===", shell)
	log.Printf("Running %d iterations...", runs)

	var total time.Duration

	for range runs {
		start := time.Now()
		c := exec.Command(shell, "-i", "-c", "exit")
		c.Stdout = nil
		c.Stderr = nil
		if err := c.Run(); err != nil {
			return fmt.Errorf("running shell: %w", err)
		}
		total += time.Since(start)
	}

	avg := total / time.Duration(runs)
	log.Printf("Average startup time: %v", avg.Round(time.Millisecond))

	return nil
}
