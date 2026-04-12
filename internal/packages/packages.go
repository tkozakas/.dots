package packages

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"runtime"
	"strings"

	"github.com/tkozakas/dots/internal/config"
	"github.com/tkozakas/dots/internal/env"
)

func Install(cfg *config.Config, distro string, dryRun bool) error {
	if runtime.GOOS == "darwin" {
		return installDarwin(cfg.Packages, dryRun)
	}
	return installLinux(cfg.Packages, distro, dryRun)
}

func installDarwin(pkgs config.Packages, dryRun bool) error {
	if err := syncSystem("darwin", dryRun); err != nil {
		return fmt.Errorf("system sync failed: %w", err)
	}
	if len(pkgs.Darwin.Brew) > 0 {
		if err := run("brew", "install", pkgs.Darwin.Brew, dryRun); err != nil {
			return err
		}
	}
	if len(pkgs.Darwin.Cask) > 0 {
		if err := run("brew", "install --cask", pkgs.Darwin.Cask, dryRun); err != nil {
			return err
		}
	}
	return nil
}

func installLinux(pkgs config.Packages, distro string, dryRun bool) error {
	if distro == "" {
		distro = env.DetectDistro()
	}

	if err := syncSystem(distro, dryRun); err != nil {
		return fmt.Errorf("system sync failed: %w", err)
	}

	if len(pkgs.Linux.Common) > 0 {
		if err := installForDistro(pkgs.Linux.Common, distro, dryRun); err != nil {
			return err
		}
	}

	distroPackages := getDistroPackages(pkgs, distro)
	if len(distroPackages) > 0 {
		if err := installForDistro(distroPackages, distro, dryRun); err != nil {
			return err
		}
	}

	if distro == "arch" && len(pkgs.Linux.Yay) > 0 {
		if err := run("yay", "-S --noconfirm --needed --sudoloop", pkgs.Linux.Yay, dryRun); err != nil {
			return err
		}
	}

	return nil
}

func getDistroPackages(pkgs config.Packages, distro string) []string {
	switch distro {
	case "arch":
		return pkgs.Linux.Arch
	case "fedora":
		return pkgs.Linux.Fedora
	case "ubuntu", "debian":
		return pkgs.Linux.Ubuntu
	default:
		return nil
	}
}

func installForDistro(packages []string, distro string, dryRun bool) error {
	switch distro {
	case "arch":
		return run("sudo pacman", "-S --noconfirm --needed", packages, dryRun)
	case "fedora":
		return run("sudo dnf", "install -y", packages, dryRun)
	case "ubuntu", "debian":
		return run("sudo apt", "install -y", packages, dryRun)
	default:
		return fmt.Errorf("unsupported distro: %s", distro)
	}
}

func syncSystem(distro string, dryRun bool) error {
	var cmdStr string
	switch distro {
	case "arch":
		cmdStr = "sudo pacman -Syu --noconfirm"
	case "fedora":
		cmdStr = "sudo dnf upgrade -y --refresh"
	case "ubuntu", "debian":
		cmdStr = "sudo apt update && sudo apt upgrade -y"
	case "darwin":
		cmdStr = "brew update && brew upgrade"
	default:
		log.Printf("Skipping system sync for unsupported distro: %s", distro)
		return nil
	}

	if dryRun {
		log.Printf("[dry-run] %s", cmdStr)
		return nil
	}

	log.Printf("Running: %s", cmdStr)
	cmd := exec.Command("sh", "-c", cmdStr)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	return cmd.Run()
}

func run(pm, action string, packages []string, dryRun bool) error {
	cmdStr := fmt.Sprintf("%s %s %s", pm, action, strings.Join(packages, " "))

	if dryRun {
		log.Printf("[dry-run] %s", cmdStr)
		return nil
	}

	log.Printf("Running: %s", cmdStr)

	parts := strings.Fields(pm)
	args := append(strings.Fields(action), packages...)
	cmd := exec.Command(parts[0], append(parts[1:], args...)...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	return cmd.Run()
}
