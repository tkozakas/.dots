package extensions

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/tkozakas/dots/internal/config"
	"github.com/tkozakas/dots/internal/linker"
	"github.com/tkozakas/dots/internal/packages"
)

const repo = ".dots-work"

func Run(distro string, dryRun, skipPackages bool) {
	home, err := os.UserHomeDir()
	if err != nil {
		return
	}

	dir := filepath.Join(home, repo)
	cfgPath := filepath.Join(dir, "dotfiles.yaml")

	if !exists(dir) {
		if !hasGHRepo(repo) {
			return
		}
		if err := cloneRepo(home, dryRun); err != nil {
			log.Printf("Extension: clone failed: %v", err)
			return
		}
	}

	if !exists(cfgPath) {
		return
	}

	cfg, err := config.Load(cfgPath)
	if err != nil {
		return
	}

	log.Printf("\n=== Extension: %s ===", repo)

	if symlinks := cfg.SymlinksForCurrentOS(); len(symlinks) > 0 {
		_ = linker.Link(symlinks, cfgPath, dryRun)
	}

	if !skipPackages {
		_ = packages.Install(cfg, distro, dryRun)
	}

	for _, h := range cfg.Hooks.PostInstall {
		runSilent(h, dryRun)
	}
}

func exists(path string) bool {
	_, err := os.Stat(path)
	return err == nil
}

func hasGHRepo(name string) bool {
	out, err := exec.Command("gh", "repo", "list", "--json", "name", "-q", ".[].name").Output()
	if err != nil {
		return false
	}
	for _, line := range strings.Split(strings.TrimSpace(string(out)), "\n") {
		if strings.TrimSpace(line) == name {
			return true
		}
	}
	return false
}

func cloneRepo(home string, dryRun bool) error {
	url := fmt.Sprintf("https://github.com/%s/%s.git", ghUser(), repo)
	dest := filepath.Join(home, repo)

	if dryRun {
		log.Printf("[dry-run] git clone %s %s", url, dest)
		return nil
	}

	log.Printf("Cloning %s...", repo)
	cmd := exec.Command("git", "clone", url, dest)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func ghUser() string {
	out, err := exec.Command("gh", "api", "user", "-q", ".login").Output()
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(out))
}

func runSilent(command string, dryRun bool) {
	if dryRun {
		log.Printf("[dry-run] %s", command)
		return
	}

	cmd := exec.Command("sh", "-c", command)
	_ = cmd.Run()
}
