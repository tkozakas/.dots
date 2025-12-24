package linker

import (
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/tkozakas/dots/internal/config"
)

const (
	colorReset  = "\033[0m"
	colorGreen  = "\033[32m"
	colorYellow = "\033[33m"
	colorRed    = "\033[31m"
	colorCyan   = "\033[36m"
)

func Link(symlinks []config.Symlink, configPath string, dryRun bool) error {
	baseDir := resolveBaseDir(configPath)
	for _, s := range symlinks {
		if err := processSymlink(s, baseDir, dryRun); err != nil {
			return err
		}
	}
	return nil
}

func processSymlink(s config.Symlink, baseDir string, dryRun bool) error {
	source := filepath.Join(baseDir, s.Source)
	target, err := expandHome(s.Target)
	if err != nil {
		return fmt.Errorf("expanding path %s: %w", s.Target, err)
	}

	if dryRun {
		log.Printf("%s[dry-run]%s %s -> %s", colorYellow, colorReset, target, source)
		return nil
	}

	return createSymlink(source, target)
}

func createSymlink(source, target string) error {
	if _, err := os.Stat(source); os.IsNotExist(err) {
		return fmt.Errorf("source not found: %s", source)
	}

	if err := os.MkdirAll(filepath.Dir(target), 0755); err != nil {
		return err
	}

	action, oldTarget := prepareTarget(source, target)

	switch action {
	case actionSkip:
		log.Printf("%s✓%s %s", colorGreen, colorReset, target)
		return nil
	case actionUpdate:
		log.Printf("%s~%s %s (was %s)", colorYellow, colorReset, target, oldTarget)
	case actionCreate:
		log.Printf("%s+%s %s", colorCyan, colorReset, target)
	}

	return os.Symlink(source, target)
}

type linkAction int

const (
	actionCreate linkAction = iota
	actionSkip
	actionUpdate
)

func prepareTarget(source, target string) (linkAction, string) {
	info, err := os.Lstat(target)
	if os.IsNotExist(err) {
		return actionCreate, ""
	}
	if err != nil {
		return actionCreate, ""
	}

	if info.Mode()&os.ModeSymlink != 0 {
		existing, _ := os.Readlink(target)
		if existing == source {
			return actionSkip, ""
		}
		_ = os.Remove(target)
		return actionUpdate, existing
	}

	if info.IsDir() {
		_ = os.RemoveAll(target)
	} else {
		_ = os.Remove(target)
	}
	return actionCreate, ""
}

func Unlink(symlinks []config.Symlink, configPath string, dryRun bool) error {
	baseDir := resolveBaseDir(configPath)
	for _, s := range symlinks {
		if err := unlinkOne(s, baseDir, dryRun); err != nil {
			return err
		}
	}
	return nil
}

func unlinkOne(s config.Symlink, baseDir string, dryRun bool) error {
	source := filepath.Join(baseDir, s.Source)
	target, _ := expandHome(s.Target)

	info, err := os.Lstat(target)
	if os.IsNotExist(err) {
		return nil
	}

	if info.Mode()&os.ModeSymlink == 0 {
		return nil
	}

	existing, _ := os.Readlink(target)
	if existing != source {
		return nil
	}

	if dryRun {
		log.Printf("%s[dry-run]%s remove %s", colorYellow, colorReset, target)
		return nil
	}

	if err := os.Remove(target); err != nil {
		return fmt.Errorf("removing %s: %w", target, err)
	}

	log.Printf("%s-%s %s", colorRed, colorReset, target)
	return nil
}

func Health(symlinks []config.Symlink, configPath string) (ok, missing, broken int) {
	baseDir := resolveBaseDir(configPath)
	for _, s := range symlinks {
		status := checkOne(s, baseDir)
		switch status {
		case statusOK:
			ok++
		case statusMissing:
			missing++
		default:
			broken++
		}
	}
	return
}

type symlinkStatus int

const (
	statusOK symlinkStatus = iota
	statusMissing
	statusBroken
)

func checkOne(s config.Symlink, baseDir string) symlinkStatus {
	source := filepath.Join(baseDir, s.Source)
	target, _ := expandHome(s.Target)

	info, err := os.Lstat(target)
	if os.IsNotExist(err) {
		log.Printf("%sMISSING%s  %s", colorYellow, colorReset, target)
		return statusMissing
	}

	if info.Mode()&os.ModeSymlink == 0 {
		log.Printf("%sBROKEN%s   %s (not a symlink)", colorRed, colorReset, target)
		return statusBroken
	}

	actual, _ := os.Readlink(target)
	if actual != source {
		log.Printf("%sBROKEN%s   %s -> %s (expected %s)", colorRed, colorReset, target, actual, source)
		return statusBroken
	}

	if _, err := os.Stat(source); os.IsNotExist(err) {
		log.Printf("%sBROKEN%s   %s (source missing)", colorRed, colorReset, target)
		return statusBroken
	}

	log.Printf("%sOK%s       %s", colorGreen, colorReset, target)
	return statusOK
}

func expandHome(path string) (string, error) {
	if len(path) == 0 || path[0] != '~' {
		return filepath.Abs(path)
	}
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(home, path[1:]), nil
}

func resolveBaseDir(configPath string) string {
	dir := filepath.Dir(configPath)
	if dir == "." {
		dir, _ = filepath.Abs(".")
	}
	return dir
}
