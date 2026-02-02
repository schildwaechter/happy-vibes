# Happy Numbers Calculator

A parallel implementation of the happy numbers algorithm in three languages: C, Go, and Rust.

> [!NOTE]
> This repo was vibed with Claude Sonnet 4.5 except for this note and the footnote.


## What are Happy Numbers?

A **happy number** is defined by the following process:

1. Starting with any positive integer, replace the number by the sum of the squares of its digits
2. Repeat the process until the number equals 1 (happy) or loops endlessly in a cycle (not happy)
3. Numbers that reach 1 are called happy numbers

### Example

Let's check if 7 is a happy number:

```
7 → 7² = 49
49 → 4² + 9² = 16 + 81 = 97
97 → 9² + 7² = 81 + 49 = 130
130 → 1² + 3² + 0² = 1 + 9 + 0 = 10
10 → 1² + 0² = 1 + 0 = 1 ✓ (Happy!)
```

Let's check if 2 is a happy number:

```
2 → 2² = 4
4 → 4² = 16
16 → 1² + 6² = 1 + 36 = 37
37 → 3² + 7² = 9 + 49 = 58
58 → 5² + 8² = 25 + 64 = 89
89 → 8² + 9² = 64 + 81 = 145
145 → 1² + 4² + 5² = 1 + 16 + 25 = 42
42 → 4² + 2² = 16 + 4 = 20
20 → 2² + 0² = 4 + 0 = 4 ← (Cycle detected, not happy)
```

## What This Project Does

This project provides command-line tools that:

- Take a positive integer `BOUND` as input
- Calculate which numbers from 1 to BOUND are happy numbers
- Use parallel processing to speed up the calculation
- Display the count and percentage of happy numbers found

## Implementations

Seven implementations are provided (six parallel, one sequential):

### C Version (`happy_c`)

- Uses **pthreads** for parallelization
- Creates worker threads based on CPU core count
- Each thread processes a range of numbers
- Uses mutex for thread-safe result collection
- Compiled with `-O2` optimization flag
- Binary size: ~13 KB

### Go Version (`happy_go`)

- Uses **goroutines** with a worker pool pattern
- Distributes work through channels
- Uses `sync.WaitGroup` for coordination
- Worker count based on `runtime.NumCPU()`
- Compiled with `-ldflags="-s -w"` to strip debug symbols
- Binary size: ~1.6 MB

### Rust Version (`happy_rust`)

- Uses **rayon** library for data parallelism
- Leverages work-stealing algorithm
- Compile-time safety guarantees
- Functional style with parallel iterators
- Compiled in release mode with LTO and aggressive optimizations
- Binary size: ~387 KB

### Fortran Version (`happy_fortran`)

- Uses **OpenMP** for parallelization
- Parallel do loops with reduction clause
- Dynamic scheduling for load balancing
- Traditional scientific computing approach
- Compiled with `-O2 -fopenmp` optimization flags
- Binary size: ~14 KB

### Pascal Version (`happy_pascal`)

- Uses **native threading** (TThread class)
- Manual thread pool with work distribution
- Object-oriented approach with worker threads
- Classic structured programming style
- Compiled with Free Pascal `-O2 -Xs` flags
- Binary size: ~1.8 MB

### COBOL Version (`happy_cobol`)

- **Sequential implementation** (no parallelization)
- Traditional business-oriented procedural style
- PERFORM loops for iteration
- Array-based cycle detection
- Compiled with GnuCOBOL `-x -O2` flags
- Binary size: ~18 KB

### Haskell Version (`happy_haskell`)

- Uses **parallel strategies** for data parallelism
- Pure functional programming with lazy evaluation
- Set-based cycle detection (immutable data structures)
- Parallel list evaluation with chunking strategy
- Compiled with GHC `-O2 -threaded -rtsopts` flags
- Binary size: ~2.2 MB
- Run with `+RTS -N` to use all CPU cores

## Building

### Prerequisites

- **C**: GCC compiler
- **Go**: Go 1.21+ toolchain
- **Rust**: Rust 1.70+ with Cargo
- **Fortran**: GFortran compiler (part of GCC)
- **Pascal**: Free Pascal Compiler (FPC) 3.2+
- **COBOL**: GnuCOBOL compiler 3.0+
- **Haskell**: GHC 9.0+ with parallel package

### Build Commands

```bash
# Build all seven versions
make

# Build individual versions
make c           # Build C version
make go          # Build Go version
make rust        # Build Rust version
make fortran     # Build Fortran version
make pascal      # Build Pascal version
make cobol       # Build COBOL version
make haskell     # Build Haskell version

# Clean all binaries
make clean

# Build and test all versions
make test
```

### Optimization Flags

All binaries are built with optimizations enabled:

- **C**: Compiled with `-O2` for optimization and `-pthread` for threading support
- **Go**: Compiled with `-ldflags="-s -w"` to strip debug symbols and reduce binary size
- **Rust**: Built in release mode with:
  - `opt-level = 3` - Maximum optimization
  - `lto = true` - Link-time optimization
  - `strip = true` - Strip symbols
  - `codegen-units = 1` - Better optimization at the cost of longer compile time
- **Fortran**: Compiled with `-O2` for optimization and `-fopenmp` for OpenMP support
- **Pascal**: Compiled with `-O2` for optimization and `-Xs` to strip symbols
- **COBOL**: Compiled with `-x -O2` for executable with optimization
- **Haskell**: Compiled with `-O2 -threaded -rtsopts` for optimization and parallel runtime

## Usage

All seven binaries have the same interface:

```bash
./happy_c BOUND          # C version
./happy_go BOUND         # Go version
./happy_rust BOUND       # Rust version
./happy_fortran BOUND    # Fortran version
./happy_pascal BOUND     # Pascal version
./happy_cobol BOUND      # COBOL version
./happy_haskell BOUND +RTS -N  # Haskell version (with parallel runtime)
```

### Examples

```bash
$ ./happy_rust 100
Happy numbers from 1 to 100: 20 (20.00%)

$ ./happy_go 1000
Happy numbers from 1 to 1000: 143 (14.30%)

$ ./happy_c 10000
Happy numbers from 1 to 10000: 1442 (14.42%)
```

### Error Handling

```bash
$ ./happy_rust
Usage: ./happy_rust BOUND
  BOUND: positive integer to check happy numbers from 1 to BOUND

$ ./happy_rust -5
Error: BOUND must be a positive integer (greater than 0)

$ ./happy_rust abc
Error: BOUND must be a valid integer
```

## Performance

Six implementations use parallel processing to utilize multiple CPU cores:

- **C**: Manual thread pool with pthread, explicit work distribution
- **Go**: Goroutines with channels, automatic scheduling
- **Rust**: Rayon's work-stealing scheduler, zero-cost abstractions
- **Fortran**: OpenMP parallel loops with dynamic scheduling
- **Pascal**: TThread-based worker pool, manual work distribution
- **Haskell**: Parallel strategies with chunked list evaluation, lazy functional approach

**COBOL**: Traditional sequential implementation (no parallelization). While slower for large values, it demonstrates classic business computing patterns.

For large values of BOUND, the parallel implementations provide significant speedup compared to sequential processing.

## Project Structure

```
.
├── Makefile           # Build automation for all versions
├── README.md          # This file
├── main.c             # C implementation
├── main.go            # Go implementation
├── main.f90           # Fortran implementation
├── main.pas           # Pascal implementation
├── main.cob           # COBOL implementation
├── Main.hs            # Haskell implementation
├── go.mod             # Go module definition
├── Cargo.toml         # Rust project configuration
├── src/
│   └── main.rs        # Rust implementation
└── target/            # Rust build artifacts (gitignored)
```

## Interesting Facts

- The first few happy numbers are: 1, 7, 10, 13, 19, 23, 28, 31, 32, 44, 49, 68, 70, 79, 82, 86, 91, 94, 97, 100
- Approximately 14-20% of numbers in any range are happy numbers
- All numbers eventually either reach 1 or enter a cycle that includes 4
- The ~~most common~~[^1] cycle for unhappy numbers is: 4 → 16 → 37 → 58 → 89 → 145 → 42 → 20 → 4

## Algorithm Complexity

- **Time Complexity**: O(n × log m) where n is BOUND and m is the average number of iterations to detect happiness
- **Space Complexity**: O(k) where k is the size of the cycle detection set (typically small)
- **Parallelization**: Near-linear speedup with number of CPU cores for large BOUND values

## Language Comparison Summary

### Binary Size Comparison (sorted)

```
Language    | Threading           | Binary Size | Paradigm
------------|---------------------|-------------|----------------------
C           | pthreads            | 13 KB       | Imperative/procedural
Fortran     | OpenMP              | 14 KB       | Scientific/procedural
COBOL       | None (sequential)   | 18 KB       | Business/procedural
Rust        | rayon               | 387 KB      | Systems/functional
Go          | goroutines          | 1.6 MB      | Concurrent/imperative
Pascal      | TThread             | 1.8 MB      | OOP/structured
Haskell     | Parallel strategies | 2.2 MB      | Pure functional
```

### Parallelization Approaches

**Manual Thread Management:**
- **C**: Low-level pthreads with explicit work distribution
- **Pascal**: OOP-based TThread with manual worker pool

**Compiler Directives:**
- **Fortran**: OpenMP directives (`!$omp parallel do`)

**Library-Based:**
- **Rust**: Rayon work-stealing with functional iterators
- **Haskell**: Parallel strategies with chunked evaluation

**Language Built-In:**
- **Go**: Goroutines and channels (CSP model)

**Sequential:**
- **COBOL**: Traditional procedural (no parallelization)

### All Implementations Verified

All seven implementations produce identical results and demonstrate different programming paradigms from 1959 (COBOL) to modern functional programming (Haskell).

---

[^1]: There is only one.
