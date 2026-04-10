BINARY := dots

.PHONY: install uninstall benchmark clean

install: $(BINARY)
	./$(BINARY) install $(ARGS)

uninstall: $(BINARY)
	./$(BINARY) uninstall $(ARGS)

benchmark: $(BINARY)
	./$(BINARY) benchmark

clean:
ifeq ($(shell uname),Darwin)
	mo clean
	mo optimize
	brew cleanup --prune=all
	brew autoremove
else
	sudo journalctl --vacuum-time=7d 2>/dev/null || true
	sudo apt autoremove -y 2>/dev/null || sudo pacman -Sc --noconfirm 2>/dev/null || sudo dnf autoremove -y 2>/dev/null || true
	sudo apt clean 2>/dev/null || sudo pacman -Scc --noconfirm 2>/dev/null || sudo dnf clean all 2>/dev/null || true
	rm -rf ~/.cache/thumbnails/*
endif

GO_SRC := $(shell find . -name '*.go')
$(BINARY): $(GO_SRC) go.mod go.sum
	go build -o $(BINARY) .

