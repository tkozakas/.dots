package linker

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/tkozakas/dots/internal/config"
)

func TestExpandPath(t *testing.T) {
	home, _ := os.UserHomeDir()

	tests := []struct {
		name    string
		path    string
		want    string
		wantErr bool
	}{
		{"tilde expands", "~/.config", filepath.Join(home, ".config"), false},
		{"no tilde unchanged", "/etc/config", "/etc/config", false},
		{"tilde only", "~", home, false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := expandPath(tt.path)
			if (err != nil) != tt.wantErr {
				t.Errorf("expandPath() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if got != tt.want {
				t.Errorf("expandPath() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestExpandPathXDG(t *testing.T) {
	home, _ := os.UserHomeDir()

	t.Run("XDG not set uses default", func(t *testing.T) {
		os.Unsetenv("XDG_CONFIG_HOME")
		got, err := expandPath("$XDG_CONFIG_HOME/nvim")
		if err != nil {
			t.Fatalf("expandPath() error = %v", err)
		}
		want := filepath.Join(home, ".config", "nvim")
		if got != want {
			t.Errorf("expandPath() = %v, want %v", got, want)
		}
	})

	t.Run("XDG set uses value", func(t *testing.T) {
		t.Setenv("XDG_CONFIG_HOME", "/custom/config")
		got, err := expandPath("$XDG_CONFIG_HOME/nvim")
		if err != nil {
			t.Fatalf("expandPath() error = %v", err)
		}
		want := "/custom/config/nvim"
		if got != want {
			t.Errorf("expandPath() = %v, want %v", got, want)
		}
	})
}

func TestResolveBaseDir(t *testing.T) {
	tests := []struct {
		name       string
		configPath string
		want       string
	}{
		{"absolute path", "/home/user/.dots/config.yaml", "/home/user/.dots"},
		{"relative path", "config.yaml", mustAbs(".")},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := resolveBaseDir(tt.configPath); got != tt.want {
				t.Errorf("resolveBaseDir() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestPrepareTarget(t *testing.T) {
	t.Run("nonexistent target returns create", func(t *testing.T) {
		dir := t.TempDir()
		target := filepath.Join(dir, "nonexistent")
		source := filepath.Join(dir, "source")

		action, old := prepareTarget(source, target)
		if action != actionCreate {
			t.Errorf("expected actionCreate, got %v", action)
		}
		if old != "" {
			t.Errorf("expected empty old, got %q", old)
		}
	})

	t.Run("correct symlink returns skip", func(t *testing.T) {
		dir := t.TempDir()
		source := filepath.Join(dir, "source")
		target := filepath.Join(dir, "target")

		os.WriteFile(source, []byte("test"), 0644)
		os.Symlink(source, target)

		action, _ := prepareTarget(source, target)
		if action != actionSkip {
			t.Errorf("expected actionSkip, got %v", action)
		}
	})

	t.Run("wrong symlink returns update", func(t *testing.T) {
		dir := t.TempDir()
		source := filepath.Join(dir, "source")
		oldSource := filepath.Join(dir, "old-source")
		target := filepath.Join(dir, "target")

		os.WriteFile(source, []byte("test"), 0644)
		os.WriteFile(oldSource, []byte("old"), 0644)
		os.Symlink(oldSource, target)

		action, old := prepareTarget(source, target)
		if action != actionUpdate {
			t.Errorf("expected actionUpdate, got %v", action)
		}
		if old != oldSource {
			t.Errorf("expected old=%q, got %q", oldSource, old)
		}
	})

	t.Run("regular file removed returns create", func(t *testing.T) {
		dir := t.TempDir()
		source := filepath.Join(dir, "source")
		target := filepath.Join(dir, "target")

		os.WriteFile(source, []byte("test"), 0644)
		os.WriteFile(target, []byte("existing"), 0644)

		action, _ := prepareTarget(source, target)
		if action != actionCreate {
			t.Errorf("expected actionCreate, got %v", action)
		}
		if _, err := os.Stat(target); !os.IsNotExist(err) {
			t.Error("expected target to be removed")
		}
	})
}

func TestLink(t *testing.T) {
	dir := t.TempDir()
	configDir := filepath.Join(dir, "dots")
	sourceDir := filepath.Join(configDir, "configs", "nvim")
	os.MkdirAll(sourceDir, 0755)
	os.WriteFile(filepath.Join(sourceDir, "init.lua"), []byte("-- nvim"), 0644)

	targetDir := filepath.Join(dir, "home", ".config", "nvim")

	symlinks := []config.Symlink{{
		Source: "configs/nvim",
		Target: targetDir,
	}}

	configPath := filepath.Join(configDir, "dotfiles.yaml")
	if err := Link(symlinks, configPath, false); err != nil {
		t.Fatalf("Link() error = %v", err)
	}

	info, err := os.Lstat(targetDir)
	if err != nil {
		t.Fatalf("target not created: %v", err)
	}
	if info.Mode()&os.ModeSymlink == 0 {
		t.Error("target is not a symlink")
	}
}

func TestUnlink(t *testing.T) {
	dir := t.TempDir()
	configDir := filepath.Join(dir, "dots")
	sourceDir := filepath.Join(configDir, "configs", "nvim")
	os.MkdirAll(sourceDir, 0755)

	targetDir := filepath.Join(dir, "home", ".config", "nvim")
	os.MkdirAll(filepath.Dir(targetDir), 0755)
	os.Symlink(sourceDir, targetDir)

	symlinks := []config.Symlink{{
		Source: "configs/nvim",
		Target: targetDir,
	}}

	configPath := filepath.Join(configDir, "dotfiles.yaml")
	if err := Unlink(symlinks, configPath, false); err != nil {
		t.Fatalf("Unlink() error = %v", err)
	}

	if _, err := os.Lstat(targetDir); !os.IsNotExist(err) {
		t.Error("symlink not removed")
	}
}

func TestHealth(t *testing.T) {
	dir := t.TempDir()
	configDir := filepath.Join(dir, "dots")
	sourceDir := filepath.Join(configDir, "configs", "nvim")
	os.MkdirAll(sourceDir, 0755)

	goodTarget := filepath.Join(dir, "good")
	badTarget := filepath.Join(dir, "bad")
	missingTarget := filepath.Join(dir, "missing")

	os.Symlink(sourceDir, goodTarget)
	os.Symlink("/nonexistent", badTarget)

	symlinks := []config.Symlink{
		{Source: "configs/nvim", Target: goodTarget},
		{Source: "configs/nvim", Target: badTarget},
		{Source: "configs/nvim", Target: missingTarget},
	}

	configPath := filepath.Join(configDir, "dotfiles.yaml")
	ok, missing, broken := Health(symlinks, configPath)

	if ok != 1 {
		t.Errorf("expected ok=1, got %d", ok)
	}
	if missing != 1 {
		t.Errorf("expected missing=1, got %d", missing)
	}
	if broken != 1 {
		t.Errorf("expected broken=1, got %d", broken)
	}
}

func mustAbs(path string) string {
	abs, _ := filepath.Abs(path)
	return abs
}
