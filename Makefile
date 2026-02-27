BINARY := dots

.PHONY: install uninstall benchmark clean

install: $(BINARY)
	./$(BINARY) install $(ARGS)

uninstall: $(BINARY)
	./$(BINARY) uninstall $(ARGS)

benchmark: $(BINARY)
	./$(BINARY) benchmark

$(BINARY): $(wildcard **/*.go) go.mod go.sum
	go build -o $(BINARY) .

clean:
	rm -f $(BINARY)
