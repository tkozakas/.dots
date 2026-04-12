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

type Symlink struct {
	Source string   `yaml:"source"`
	Target string   `yaml:"target"`
	OS     []string `yaml:"os"`
}

type Packages struct {
	Darwin darwinPackages `yaml:"darwin"`
	Linux  linuxPackages  `yaml:"linux"`
}

type darwinPackages struct {
	Brew []string `yaml:"brew"`
	Cask []string `yaml:"cask"`
}

type linuxPackages struct {
	Common []string `yaml:"common"`
	Arch   []string `yaml:"arch"`
	Fedora []string `yaml:"fedora"`
	Ubuntu []string `yaml:"ubuntu"`
	Yay    []string `yaml:"yay"`
}

type Hook struct {
	Cmd string   `yaml:"cmd"`
	OS  []string `yaml:"os"`
}

type Hooks struct {
	PostInstall []Hook `yaml:"post_install"`
}

func (h *Hook) MatchesOS(osName string) bool {
	return len(h.OS) == 0 || slices.Contains(h.OS, osName)
}

func (h *Hook) UnmarshalYAML(value *yaml.Node) error {
	if value.Kind == yaml.ScalarNode {
		h.Cmd = value.Value
		h.OS = nil
		return nil
	}

	type hookAlias Hook
	var alias hookAlias
	if err := value.Decode(&alias); err != nil {
		return err
	}
	*h = Hook(alias)
	return nil
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
	var result []Symlink
	for _, s := range c.Symlinks {
		if s.matchesOS(runtime.GOOS) {
			result = append(result, s)
		}
	}
	return result
}

func (s *Symlink) matchesOS(osName string) bool {
	return len(s.OS) == 0 || slices.Contains(s.OS, osName)
}
