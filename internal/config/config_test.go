package config

import (
	"os"
	"path/filepath"
	"testing"
)

func TestLoad(t *testing.T) {
	content := `
symlinks:
  - source: "configs/nvim"
    target: "~/.config/nvim"
    os: ["darwin", "linux"]
  - source: "configs/hypr"
    target: "~/.config/hypr"
    os: ["linux"]
packages:
  darwin:
    brew: [neovim, tmux]
    cask: [alacritty]
  linux:
    common: [vim, git]
    arch: [base-devel]
hooks:
  post_install:
    - echo "done"
`
	path := writeTempFile(t, "config.yaml", content)
	cfg, err := Load(path)
	if err != nil {
		t.Fatalf("Load() error = %v", err)
	}

	if len(cfg.Symlinks) != 2 {
		t.Errorf("expected 2 symlinks, got %d", len(cfg.Symlinks))
	}
	if cfg.Symlinks[0].Source != "configs/nvim" {
		t.Errorf("expected source 'configs/nvim', got %q", cfg.Symlinks[0].Source)
	}
	if len(cfg.Packages.Darwin.Brew) != 2 {
		t.Errorf("expected 2 brew packages, got %d", len(cfg.Packages.Darwin.Brew))
	}
	if len(cfg.Hooks.PostInstall) != 1 {
		t.Errorf("expected 1 hook, got %d", len(cfg.Hooks.PostInstall))
	}
}

func TestLoadNotFound(t *testing.T) {
	_, err := Load("/nonexistent/config.yaml")
	if err == nil {
		t.Error("expected error for nonexistent file")
	}
}

func TestLoadInvalidYAML(t *testing.T) {
	path := writeTempFile(t, "bad.yaml", "invalid: yaml: content: [")
	_, err := Load(path)
	if err == nil {
		t.Error("expected error for invalid YAML")
	}
}

func TestSymlinkMatchesOS(t *testing.T) {
	tests := []struct {
		name   string
		os     []string
		target string
		want   bool
	}{
		{"empty matches all", nil, "darwin", true},
		{"darwin matches darwin", []string{"darwin"}, "darwin", true},
		{"darwin no match linux", []string{"darwin"}, "linux", false},
		{"multi-os matches", []string{"darwin", "linux"}, "linux", true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			s := Symlink{OS: tt.os}
			if got := s.matchesOS(tt.target); got != tt.want {
				t.Errorf("matchesOS(%q) = %v, want %v", tt.target, got, tt.want)
			}
		})
	}
}

func writeTempFile(t *testing.T, name, content string) string {
	t.Helper()
	dir := t.TempDir()
	path := filepath.Join(dir, name)
	if err := os.WriteFile(path, []byte(content), 0644); err != nil {
		t.Fatal(err)
	}
	return path
}
