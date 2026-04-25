.PHONY: install update rollback clean fmt check news diff trust doctor

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

install: trust
	@bash -c '$(HM) $(FILTER)'

# one-time per machine: add cache.nixos.org substituter
# (Determinate Nix doesn't include it by default).
trust:
	@if grep -q "cache.nixos.org" /etc/nix/nix.custom.conf 2>/dev/null; then \
		echo "already trusted"; \
	else \
		echo "adding cache.nixos.org substituter"; \
		printf 'extra-substituters = https://cache.nixos.org\nextra-trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=\n' \
			| sudo tee -a /etc/nix/nix.custom.conf >/dev/null; \
		if [ "$$(uname)" = "Darwin" ]; then \
			sudo launchctl kickstart -k system/systems.determinate.nix-daemon 2>/dev/null \
				|| sudo launchctl kickstart -k system/org.nixos.nix-daemon; \
		else \
			sudo systemctl restart nix-daemon; \
		fi; \
		echo "done"; \
	fi

diff:
	@bash -c '$(SOURCE) $(NIX) build ".$(HASH)homeConfigurations.$(CONFIG).activationPackage" --no-link --impure --print-out-paths $(FILTER)' | tail -1 | xargs -I{} bash -c '$(SOURCE) $(NIX) store diff-closures ~/.local/state/nix/profiles/home-manager {}/home-files'

update:
	@bash -c '$(SOURCE) $(NIX) flake update $(FILTER)'
	@bash -c '$(HM) $(FILTER)'

rollback:
	@$(SOURCE) $(NIX) run ".$(HASH)home-manager" -- generations | head -2 | tail -1 | awk '{print $$NF}' | xargs -I{} {}/activate

doctor:
	@bash -c '$(SOURCE) \
		echo "system:    $$(uname -srm)"; \
		echo "user:      $$USER"; \
		echo "dots:      $$(pwd)"; \
		echo "nix:       $$($(NIX) --version)"; \
		echo "profile:   $$(readlink ~/.local/state/nix/profiles/home-manager 2>/dev/null || echo none)"; \
		echo "trusted:   $$(grep -h cache.nixos.org /etc/nix/nix.conf /etc/nix/nix.custom.conf 2>/dev/null | head -1 || echo missing)"; \
		echo; \
		echo "generations:"; \
		$(NIX) run ".$(HASH)home-manager" -- generations 2>/dev/null | head -3'

clean:
	@$(SOURCE) $(NIX) profile wipe-history 2>/dev/null || true
	@$(SOURCE) nix-collect-garbage -d 2>/dev/null || true
ifneq ($(shell uname),Darwin)
	@sudo journalctl --vacuum-time=7d 2>/dev/null || true
	@rm -rf ~/.cache/thumbnails/*
endif
