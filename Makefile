.PHONY: install update rollback clean

CONFIG  := $(shell uname -s | tr '[:upper:]' '[:lower:]')
FLAKE   := .#$(CONFIG)
HM      := home-manager switch --flake "$(FLAKE)" -b backup --impure

install:
	$(HM)

update:
	nix flake update
	$(HM)

rollback:
	home-manager generations | head -2 | tail -1 | awk '{print $$NF}' | xargs -I{} {}/activate

clean:
	nix profile wipe-history 2>/dev/null || true
	nix-collect-garbage -d 2>/dev/null || true
ifneq ($(shell uname),Darwin)
	sudo journalctl --vacuum-time=7d 2>/dev/null || true
	rm -rf ~/.cache/thumbnails/*
endif
