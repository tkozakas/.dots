package cmd

import (
	"fmt"
	"os"
	"os/exec"

	"github.com/spf13/cobra"
	"github.com/tom/dots/internal/linker"
)

var updateCmd = &cobra.Command{
	Use:   "update",
	Short: "Update dots: git pull, rebuild, and reinstall",
	RunE:  runUpdate,
}

func init() {
	rootCmd.AddCommand(updateCmd)
}

func runUpdate(cmd *cobra.Command, args []string) error {
	baseDir := linker.ResolveBaseDir(configPath)

	if dryRun {
		fmt.Println("[dry-run] git pull")
		fmt.Println("[dry-run] go build -o dots .")
		fmt.Println("[dry-run] ./dots install")
		return nil
	}

	steps := []struct {
		name string
		cmd  []string
	}{
		{"Pulling latest changes...", []string{"git", "pull"}},
		{"Rebuilding...", []string{"go", "build", "-o", "dots", "."}},
	}

	for _, step := range steps {
		fmt.Println(step.name)
		if err := runCmd(baseDir, step.cmd...); err != nil {
			return err
		}
	}

	fmt.Println("Reinstalling...")
	installArgs := []string{"./dots", "install"}
	if distro != "" {
		installArgs = append(installArgs, "--distro", distro)
	}
	return runCmd(baseDir, installArgs...)
}

func runCmd(dir string, args ...string) error {
	cmd := exec.Command(args[0], args[1:]...)
	cmd.Dir = dir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	return cmd.Run()
}
