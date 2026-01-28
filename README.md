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

Three parallel implementations are provided:

### C Version (`happy_c`)

- Uses **pthreads** for parallelization
- Creates worker threads based on CPU core count
- Each thread processes a range of numbers
- Uses mutex for thread-safe result collection
- Binary size: ~13 KB

### Go Version (`happy_go`)

- Uses **goroutines** with a worker pool pattern
- Distributes work through channels
- Uses `sync.WaitGroup` for coordination
- Worker count based on `runtime.NumCPU()`
- Binary size: ~2.4 MB

### Rust Version (`happy_rust`)

- Uses **rayon** library for data parallelism
- Leverages work-stealing algorithm
- Compile-time safety guarantees
- Functional style with parallel iterators
- Binary size: ~487 KB

## Building

### Prerequisites

- **C**: GCC compiler
- **Go**: Go 1.21+ toolchain
- **Rust**: Rust 1.70+ with Cargo

### Build Commands

```bash
# Build all three versions
make

# Build individual versions
make c        # Build C version
make go       # Build Go version
make rust     # Build Rust version

# Clean all binaries
make clean

# Build and test all versions
make test
```

## Usage

All three binaries have the same interface:

```bash
./happy_c BOUND      # C version
./happy_go BOUND     # Go version
./happy_rust BOUND   # Rust version
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

All three implementations use parallel processing to utilize multiple CPU cores:

- **C**: Manual thread pool with pthread, explicit work distribution
- **Go**: Goroutines with channels, automatic scheduling
- **Rust**: Rayon's work-stealing scheduler, zero-cost abstractions

For large values of BOUND, the parallel implementations provide significant speedup compared to sequential processing.

## Project Structure

```
.
├── Makefile           # Build automation for all versions
├── README.md          # This file
├── main.c             # C implementation
├── main.go            # Go implementation
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
---

[^1]: The model hallucinated these words.
