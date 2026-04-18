package linker

import (
	"errors"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/tkozakas/dots/internal/config"
)

const (
	colorReset  = "\033[0m"
	colorGreen  = "\033[32m"
	colorYellow = "\033[33m"
	colorRed    = "\033[31m"
	colorCyan   = "\033[36m"

	xdgConfigHome    = "$XDG_CONFIG_HOME"
	xdgConfigHomeLen = 16
	defaultConfig    = ".config"
	dirPerm          = 0755
)

type linkAction int

const (
	actionCreate linkAction = iota
	actionSkip
	actionUpdate
)

type symlinkStatus int

const (
	statusOK symlinkStatus = iota
	statusMissing
	statusBroken
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
	target, err := expandPath(s.Target)
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

	if err := os.MkdirAll(filepath.Dir(target), dirPerm); err != nil {
		if !errors.Is(err, os.ErrPermission) {
			return err
		}
		if err := sudoRun("mkdir", "-p", filepath.Dir(target)); err != nil {
			return err
		}
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

	if err := os.Symlink(source, target); err != nil {
		if !errors.Is(err, os.ErrPermission) {
			return err
		}
		return sudoRun("ln", "-sfn", source, target)
	}
	return nil
}

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
		if err := os.Remove(target); err != nil {
			_ = sudoRun("rm", "-f", target)
		}
		return actionUpdate, existing
	}

	if info.IsDir() {
		if err := os.RemoveAll(target); err != nil {
			_ = sudoRun("rm", "-rf", target)
		}
	} else {
		if err := os.Remove(target); err != nil {
			_ = sudoRun("rm", "-f", target)
		}
	}
	return actionCreate, ""
}

func sudoRun(args ...string) error {
	cmd := exec.Command("sudo", args...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
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
	target, _ := expandPath(s.Target)

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
		if !errors.Is(err, os.ErrPermission) {
			return fmt.Errorf("removing %s: %w", target, err)
		}
		if err := sudoRun("rm", "-f", target); err != nil {
			return fmt.Errorf("removing %s with sudo: %w", target, err)
		}
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

func checkOne(s config.Symlink, baseDir string) symlinkStatus {
	source := filepath.Join(baseDir, s.Source)
	target, _ := expandPath(s.Target)

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

func expandPath(path string) (string, error) {
	if len(path) == 0 {
		return filepath.Abs(path)
	}

	if len(path) >= xdgConfigHomeLen && path[:xdgConfigHomeLen] == xdgConfigHome {
		xdg := os.Getenv("XDG_CONFIG_HOME")
		if xdg == "" {
			home, err := os.UserHomeDir()
			if err != nil {
				return "", err
			}
			xdg = filepath.Join(home, defaultConfig)
		}
		return filepath.Join(xdg, path[xdgConfigHomeLen:]), nil
	}

	if path[0] == '~' {
		home, err := os.UserHomeDir()
		if err != nil {
			return "", err
		}
		return filepath.Join(home, path[1:]), nil
	}

	return filepath.Abs(path)
}

func resolveBaseDir(configPath string) string {
	dir := filepath.Dir(configPath)
	if dir == "." {
		dir, _ = filepath.Abs(".")
	}
	return dir
}
