package hooks

import (
	"log"
	"os"
	"os/exec"

	"github.com/tkozakas/dots/internal/config"
)

func RunPostInstall(hooks config.Hooks, dryRun bool) error {
	for _, cmd := range hooks.PostInstall {
		if err := runCmd(cmd, dryRun); err != nil {
			return err
		}
	}
	return nil
}

func runCmd(command string, dryRun bool) error {
	if dryRun {
		log.Printf("[dry-run] %s", command)
		return nil
	}

	log.Printf("Running: %s", command)

	cmd := exec.Command("sh", "-c", command)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}
