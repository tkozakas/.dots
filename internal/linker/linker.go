package linker

import (
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/tkozakas/dots/internal/config"
)

type SymlinkStatus int

const (
	StatusOK SymlinkStatus = iota
	StatusMissing
	StatusWrongTarget
	StatusNotSymlink
	StatusSourceMissing
)

type SymlinkInfo struct {
	Source string
	Target string
	Status SymlinkStatus
	Actual string
}

func Link(symlinks []config.Symlink, configPath string, dryRun bool) error {
	baseDir := ResolveBaseDir(configPath)

	for _, s := range symlinks {
		if err := processSymlink(s, baseDir, dryRun); err != nil {
			return err
		}
	}
	return nil
}

func Unlink(symlinks []config.Symlink, configPath string, dryRun bool) error {
	baseDir := ResolveBaseDir(configPath)

	for _, s := range symlinks {
		info := CheckSymlink(s, baseDir)
		if info.Status == StatusMissing {
			continue
		}
		if info.Status != StatusOK {
			continue
		}

		if dryRun {
			log.Printf("[dry-run] remove %s", info.Target)
			continue
		}

		if err := os.Remove(info.Target); err != nil {
			return fmt.Errorf("removing %s: %w", info.Target, err)
		}
		log.Printf("Removed %s", info.Target)
	}
	return nil
}

func Health(symlinks []config.Symlink, configPath string) (ok, missing, broken int) {
	baseDir := ResolveBaseDir(configPath)

	for _, s := range symlinks {
		info := CheckSymlink(s, baseDir)

		switch info.Status {
		case StatusOK:
			log.Printf("OK       %s", info.Target)
			ok++
		case StatusMissing:
			log.Printf("MISSING  %s", info.Target)
			missing++
		case StatusWrongTarget:
			log.Printf("BROKEN   %s -> %s (expected %s)", info.Target, info.Actual, info.Source)
			broken++
		case StatusNotSymlink:
			log.Printf("BROKEN   %s (not a symlink)", info.Target)
			broken++
		case StatusSourceMissing:
			log.Printf("BROKEN   %s -> %s (source missing)", info.Target, info.Source)
			broken++
		}
	}
	return
}

func CheckSymlink(s config.Symlink, baseDir string) SymlinkInfo {
	source := filepath.Join(baseDir, s.Source)
	target, _ := ExpandHome(s.Target)

	info := SymlinkInfo{Source: source, Target: target}

	stat, err := os.Lstat(target)
	if os.IsNotExist(err) {
		info.Status = StatusMissing
		return info
	}

	if stat.Mode()&os.ModeSymlink == 0 {
		info.Status = StatusNotSymlink
		return info
	}

	actual, err := os.Readlink(target)
	if err != nil {
		info.Status = StatusNotSymlink
		return info
	}
	info.Actual = actual

	if actual != source {
		info.Status = StatusWrongTarget
		return info
	}

	if _, err := os.Stat(source); os.IsNotExist(err) {
		info.Status = StatusSourceMissing
		return info
	}

	info.Status = StatusOK
	return info
}

func processSymlink(s config.Symlink, baseDir string, dryRun bool) error {
	source := filepath.Join(baseDir, s.Source)
	target, err := ExpandHome(s.Target)
	if err != nil {
		return fmt.Errorf("expanding path %s: %w", s.Target, err)
	}

	if dryRun {
		log.Printf("[dry-run] %s -> %s", target, source)
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

	skip, err := removeExistingTarget(source, target)
	if err != nil {
		return err
	}

	if skip {
		log.Printf("%s -> %s (already exists)", target, source)
		return nil
	}

	log.Printf("%s -> %s", target, source)
	return os.Symlink(source, target)
}

func removeExistingTarget(source, target string) (skip bool, err error) {
	info, err := os.Lstat(target)
	if os.IsNotExist(err) {
		return false, nil
	}
	if err != nil {
		return false, err
	}

	if info.Mode()&os.ModeSymlink != 0 {
		existing, err := os.Readlink(target)
		if err == nil && existing == source {
			return true, nil
		}
	}

	if info.IsDir() {
		return false, os.RemoveAll(target)
	}
	return false, os.Remove(target)
}

func ExpandHome(path string) (string, error) {
	if len(path) == 0 || path[0] != '~' {
		return filepath.Abs(path)
	}
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(home, path[1:]), nil
}

func ResolveBaseDir(configPath string) string {
	dir := filepath.Dir(configPath)
	if dir == "." {
		dir, _ = filepath.Abs(".")
	}
	return dir
}
