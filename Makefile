CC = gcc
CFLAGS = -Wall -Wextra -O2 -pthread
C_TARGET = happy_c
GO_TARGET = happy_go
RUST_TARGET = happy_rust
C_SRC = main.c
GO_SRC = main.go
RUST_SRC = src/main.rs

all: c go rust

c: $(C_TARGET)

go: $(GO_TARGET)

rust: $(RUST_TARGET)

$(C_TARGET): $(C_SRC)
	$(CC) $(CFLAGS) -o $(C_TARGET) $(C_SRC)

$(GO_TARGET): $(GO_SRC)
	go build -o $(GO_TARGET) $(GO_SRC)

$(RUST_TARGET): $(RUST_SRC) Cargo.toml
	cargo build --release
	cp target/release/happy_rust $(RUST_TARGET)

clean:
	rm -f $(C_TARGET) $(GO_TARGET) $(RUST_TARGET)
	cargo clean 2>/dev/null || true

test: c go rust
	@echo "Testing C version:"
	./$(C_TARGET) 100
	./$(C_TARGET) 1000
	./$(C_TARGET) 10000
	@echo ""
	@echo "Testing Go version:"
	./$(GO_TARGET) 100
	./$(GO_TARGET) 1000
	./$(GO_TARGET) 10000
	@echo ""
	@echo "Testing Rust version:"
	./$(RUST_TARGET) 100
	./$(RUST_TARGET) 1000
	./$(RUST_TARGET) 10000

.PHONY: all c go rust clean test
