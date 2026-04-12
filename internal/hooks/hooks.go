package hooks

import (
	"log"
	"os"
	"os/exec"
	"runtime"

	"github.com/tkozakas/dots/internal/config"
)

func RunPostInstall(hooks config.Hooks, dryRun bool) error {
	for _, hook := range hooks.PostInstall {
		if !hook.MatchesOS(runtime.GOOS) {
			log.Printf("[skip] %s (os: %v, current: %s)", hook.Cmd, hook.OS, runtime.GOOS)
			continue
		}
		if err := runCmd(hook.Cmd, dryRun); err != nil {
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
