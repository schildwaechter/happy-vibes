CC = gcc
CFLAGS = -Wall -Wextra -O2 -pthread
GOFLAGS = -ldflags="-s -w"
FC = gfortran-15
FFLAGS = -O2 -fopenmp
PC = fpc
PFLAGS = -O2 -Xs
COBC = cobc
COBFLAGS = -x -O2 -std=default
GHC = ghc
GHCFLAGS = -O2 -threaded -rtsopts
C_TARGET = happy_c
GO_TARGET = happy_go
RUST_TARGET = happy_rust
FORTRAN_TARGET = happy_fortran
PASCAL_TARGET = happy_pascal
COBOL_TARGET = happy_cobol
HASKELL_TARGET = happy_haskell
C_SRC = main.c
GO_SRC = main.go
RUST_SRC = src/main.rs
FORTRAN_SRC = main.f90
PASCAL_SRC = main.pas
COBOL_SRC = main.cob
HASKELL_SRC = Main.hs

all: c go rust fortran pascal cobol haskell

c: $(C_TARGET)

go: $(GO_TARGET)

rust: $(RUST_TARGET)

fortran: $(FORTRAN_TARGET)

pascal: $(PASCAL_TARGET)

cobol: $(COBOL_TARGET)

haskell: $(HASKELL_TARGET)

go: $(GO_TARGET)

rust: $(RUST_TARGET)

fortran: $(FORTRAN_TARGET)

pascal: $(PASCAL_TARGET)

cobol: $(COBOL_TARGET)

$(C_TARGET): $(C_SRC)
	$(CC) $(CFLAGS) -o $(C_TARGET) $(C_SRC)

$(GO_TARGET): $(GO_SRC)
	go build $(GOFLAGS) -o $(GO_TARGET) $(GO_SRC)

$(RUST_TARGET): $(RUST_SRC) Cargo.toml
	cargo build --release
	cp target/release/happy_rust $(RUST_TARGET)

$(FORTRAN_TARGET): $(FORTRAN_SRC)
	$(FC) $(FFLAGS) -o $(FORTRAN_TARGET) $(FORTRAN_SRC)

$(PASCAL_TARGET): $(PASCAL_SRC)
	$(PC) $(PFLAGS) -o$(PASCAL_TARGET) $(PASCAL_SRC)

$(COBOL_TARGET): $(COBOL_SRC)
	$(COBC) $(COBFLAGS) -o $(COBOL_TARGET) $(COBOL_SRC)

$(HASKELL_TARGET): $(HASKELL_SRC)
	$(GHC) $(GHCFLAGS) -o $(HASKELL_TARGET) $(HASKELL_SRC)

clean:
	rm -f $(C_TARGET) $(GO_TARGET) $(RUST_TARGET) $(FORTRAN_TARGET) $(PASCAL_TARGET) $(COBOL_TARGET) $(HASKELL_TARGET)
	rm -f *.o *.ppu *.hi
	cargo clean 2>/dev/null || true

test: c go rust fortran pascal cobol haskell
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
	@echo ""
	@echo "Testing Fortran version:"
	./$(FORTRAN_TARGET) 100
	./$(FORTRAN_TARGET) 1000
	./$(FORTRAN_TARGET) 10000
	@echo ""
	@echo "Testing Pascal version:"
	./$(PASCAL_TARGET) 100
	./$(PASCAL_TARGET) 1000
	./$(PASCAL_TARGET) 10000
	@echo ""
	@echo "Testing COBOL version:"
	./$(COBOL_TARGET) 100
	./$(COBOL_TARGET) 1000
	./$(COBOL_TARGET) 10000
	@echo ""
	@echo "Testing Haskell version:"
	./$(HASKELL_TARGET) 100 +RTS -N
	./$(HASKELL_TARGET) 1000 +RTS -N
	./$(HASKELL_TARGET) 10000 +RTS -N

.PHONY: all c go rust fortran pascal cobol haskell clean test
