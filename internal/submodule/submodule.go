package submodule

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
)

func Init(baseDir string, dryRun bool) error {
	if !isGitRepo(baseDir) {
		return nil
	}

	if dryRun {
		fmt.Println("[dry-run] git submodule update --init --recursive")
		return nil
	}

	fmt.Println("Initializing git submodules...")
	return run(baseDir, "update", "--init", "--recursive")
}

func Update(baseDir string, dryRun bool) error {
	if !isGitRepo(baseDir) {
		return nil
	}

	if dryRun {
		fmt.Println("[dry-run] git submodule update --remote --merge")
		return nil
	}

	fmt.Println("Updating git submodules...")
	return run(baseDir, "update", "--remote", "--merge")
}

func isGitRepo(dir string) bool {
	_, err := os.Stat(filepath.Join(dir, ".git"))
	return err == nil
}

func run(baseDir string, args ...string) error {
	cmd := exec.Command("git", append([]string{"submodule"}, args...)...)
	cmd.Dir = baseDir
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
