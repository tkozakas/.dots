package config

import (
	"fmt"
	"os"
	"runtime"
	"slices"

	"gopkg.in/yaml.v3"
)

type Config struct {
	Symlinks []Symlink `yaml:"symlinks"`
	Packages Packages  `yaml:"packages"`
	Hooks    Hooks     `yaml:"hooks"`
}

type Hooks struct {
	PostInstall []string `yaml:"post_install"`
}

type Symlink struct {
	Source    string   `yaml:"source"`
	Target    string   `yaml:"target"`
	OS        []string `yaml:"os"`
	Submodule bool     `yaml:"submodule"`
}

type Packages struct {
	Darwin DarwinPackages `yaml:"darwin"`
	Linux  LinuxPackages  `yaml:"linux"`
}

type DarwinPackages struct {
	Brew []string `yaml:"brew"`
	Cask []string `yaml:"cask"`
}

type LinuxPackages struct {
	Common []string `yaml:"common"`
	Arch   []string `yaml:"arch"`
	Fedora []string `yaml:"fedora"`
	Ubuntu []string `yaml:"ubuntu"`
	Yay    []string `yaml:"yay"`
}

func Load(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("reading config: %w", err)
	}

	var cfg Config
	if err := yaml.Unmarshal(data, &cfg); err != nil {
		return nil, fmt.Errorf("parsing config: %w", err)
	}

	return &cfg, nil
}

func (c *Config) SymlinksForCurrentOS() []Symlink {
	return c.filterSymlinks(runtime.GOOS)
}

func (c *Config) filterSymlinks(osName string) []Symlink {
	var result []Symlink
	for _, s := range c.Symlinks {
		if s.matchesOS(osName) {
			result = append(result, s)
		}
	}
	return result
}

func (s *Symlink) matchesOS(osName string) bool {
	if len(s.OS) == 0 {
		return true
	}
	return slices.Contains(s.OS, osName)
}
