package packages

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strings"

	"github.com/tom/dots/internal/config"
	"github.com/tom/dots/internal/env"
)

func Install(cfg *config.Config, distro string, dryRun bool) error {
	if runtime.GOOS == "darwin" {
		return installDarwin(cfg.Packages.Darwin, dryRun)
	}
	return installLinux(cfg.Packages.Linux, distro, dryRun)
}

func installDarwin(pkgs config.DarwinPackages, dryRun bool) error {
	if len(pkgs.Brew) > 0 {
		if err := run("brew", "install", pkgs.Brew, dryRun); err != nil {
			return err
		}
	}
	if len(pkgs.Cask) > 0 {
		if err := run("brew", "install --cask", pkgs.Cask, dryRun); err != nil {
			return err
		}
	}
	return nil
}

func installLinux(pkgs config.LinuxPackages, distro string, dryRun bool) error {
	if distro == "" {
		distro = env.DetectDistro()
	}

	if len(pkgs.Common) > 0 {
		if err := installForDistro(pkgs.Common, distro, dryRun); err != nil {
			return err
		}
	}

	distroPackages := getDistroPackages(pkgs, distro)
	if len(distroPackages) > 0 {
		if err := installForDistro(distroPackages, distro, dryRun); err != nil {
			return err
		}
	}

	if distro == "arch" && len(pkgs.Yay) > 0 {
		if err := run("yay", "-S --noconfirm --needed", pkgs.Yay, dryRun); err != nil {
			return err
		}
	}

	return nil
}

func getDistroPackages(pkgs config.LinuxPackages, distro string) []string {
	switch distro {
	case "arch":
		return pkgs.Arch
	case "fedora":
		return pkgs.Fedora
	case "ubuntu", "debian":
		return pkgs.Ubuntu
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

func run(pm, action string, packages []string, dryRun bool) error {
	cmdStr := fmt.Sprintf("%s %s %s", pm, action, strings.Join(packages, " "))

	if dryRun {
		fmt.Printf("[dry-run] %s\n", cmdStr)
		return nil
	}

	fmt.Printf("Running: %s\n", cmdStr)

	parts := strings.Fields(pm)
	args := append(strings.Fields(action), packages...)

	cmd := exec.Command(parts[0], append(parts[1:], args...)...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	return cmd.Run()
}
