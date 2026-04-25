.PHONY: install update rollback clean fmt check news diff

CONFIG := $(shell uname -s | tr '[:upper:]' '[:lower:]')
HASH   := \#
NIX_SH := /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
SOURCE := export USER=$${USER:-$$(id -un)}; . $(NIX_SH);
NIX    := nix --option warn-dirty false
FILTER := 2>&1 | grep -vE "unknown setting|deprecated alias|evaluation warning: .system. has been renamed|Using .builtins.derivation. to create a derivation named .options.json."; exit $${PIPESTATUS[0]}
HM     := $(SOURCE) $(NIX) run ".$(HASH)home-manager" -- switch --flake ".$(HASH)$(CONFIG)" -b backup --impure

fmt:
	@bash -c '$(SOURCE) $(NIX) fmt'

check:
	@bash -c '$(SOURCE) $(NIX) build ".$(HASH)homeConfigurations.linux.activationPackage" --no-link --impure $(FILTER)'

news:
	@bash -c '$(SOURCE) $(NIX) run ".$(HASH)home-manager" -- news --flake ".$(HASH)linux" --impure $(FILTER)'

install:
	@bash -c '$(HM) $(FILTER)'

diff:
	@bash -c '$(SOURCE) $(NIX) build ".$(HASH)homeConfigurations.$(CONFIG).activationPackage" --no-link --impure --print-out-paths $(FILTER)' | tail -1 | xargs -I{} bash -c '$(SOURCE) $(NIX) store diff-closures ~/.local/state/nix/profiles/home-manager {}/home-files'

update:
	@bash -c '$(SOURCE) $(NIX) flake update $(FILTER)'
	@bash -c '$(HM) $(FILTER)'

rollback:
	@$(SOURCE) $(NIX) run ".$(HASH)home-manager" -- generations | head -2 | tail -1 | awk '{print $$NF}' | xargs -I{} {}/activate

clean:
	@$(SOURCE) $(NIX) profile wipe-history 2>/dev/null || true
	@$(SOURCE) nix-collect-garbage -d 2>/dev/null || true
ifneq ($(shell uname),Darwin)
	@sudo journalctl --vacuum-time=7d 2>/dev/null || true
	@rm -rf ~/.cache/thumbnails/*
endif
