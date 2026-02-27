BINARY := dots

.PHONY: install uninstall benchmark clean

install: $(BINARY)
	./$(BINARY) install $(ARGS)

uninstall: $(BINARY)
	./$(BINARY) uninstall $(ARGS)

benchmark: $(BINARY)
	./$(BINARY) benchmark

GO_SRC := $(shell find . -name '*.go')
$(BINARY): $(GO_SRC) go.mod go.sum
	go build -o $(BINARY) .

clean:
	rm -f $(BINARY)
