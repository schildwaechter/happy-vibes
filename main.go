package main

import (
	"fmt"
	"os"
	"runtime"
	"strconv"
	"sync"
)

// isHappy determines if a number is a happy number
// A happy number is defined by the following process:
// Starting with any positive integer, replace the number by the sum of the squares of its digits.
// Repeat the process until the number equals 1 (happy) or loops endlessly in a cycle (not happy).
func isHappy(n int) bool {
	seen := make(map[int]bool)

	for n != 1 {
		if seen[n] {
			return false // We've seen this number before, it's a cycle
		}
		seen[n] = true
		n = sumOfSquares(n)
	}

	return true
}

// sumOfSquares calculates the sum of squares of all digits in a number
func sumOfSquares(n int) int {
	sum := 0
	for n > 0 {
		digit := n % 10
		sum += digit * digit
		n /= 10
	}
	return sum
}

// worker processes numbers from the jobs channel and sends results to the results channel
func worker(jobs <-chan int, results chan<- int, wg *sync.WaitGroup) {
	defer wg.Done()

	for num := range jobs {
		if isHappy(num) {
			results <- 1
		} else {
			results <- 0
		}
	}
}

func main() {
	// Parse command line arguments
	if len(os.Args) != 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s BOUND\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  BOUND: positive integer to check happy numbers from 1 to BOUND\n")
		os.Exit(1)
	}

	bound, err := strconv.Atoi(os.Args[1])
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: BOUND must be a valid integer\n")
		os.Exit(1)
	}

	if bound < 1 {
		fmt.Fprintf(os.Stderr, "Error: BOUND must be a positive integer (greater than 0)\n")
		os.Exit(1)
	}

	// Setup worker pool
	numWorkers := runtime.NumCPU()
	jobs := make(chan int, bound)
	results := make(chan int, bound)

	var wg sync.WaitGroup

	// Start workers
	for i := 0; i < numWorkers; i++ {
		wg.Add(1)
		go worker(jobs, results, &wg)
	}

	// Send jobs
	go func() {
		for i := 1; i <= bound; i++ {
			jobs <- i
		}
		close(jobs)
	}()

	// Close results channel when all workers are done
	go func() {
		wg.Wait()
		close(results)
	}()

	// Collect results
	happyCount := 0
	for result := range results {
		happyCount += result
	}

	// Calculate and print percentage
	percentage := (float64(happyCount) / float64(bound)) * 100.0
	fmt.Printf("Happy numbers from 1 to %d: %d (%.2f%%)\n", bound, happyCount, percentage)
}
