package hooks

import (
	"log"
	"os"
	"os/exec"
	"strings"

	"github.com/tkozakas/dots/internal/config"
)

func RunPostInstall(hooks config.Hooks, dryRun bool) error {
	for _, cmd := range hooks.PostInstall {
		if err := run(cmd, dryRun); err != nil {
			return err
		}
	}
	return nil
}

func run(command string, dryRun bool) error {
	if dryRun {
		log.Printf("[dry-run] %s", command)
		return nil
	}

	log.Printf("Running: %s", command)

	parts := strings.Fields(command)
	cmd := exec.Command(parts[0], parts[1:]...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}
