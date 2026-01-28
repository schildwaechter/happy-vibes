#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>

// Structure to pass data to worker threads
typedef struct {
    int start;
    int end;
    int happy_count;
} ThreadData;

// Global mutex for thread-safe operations
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

// Calculate sum of squares of digits
int sum_of_squares(int n) {
    int sum = 0;
    while (n > 0) {
        int digit = n % 10;
        sum += digit * digit;
        n /= 10;
    }
    return sum;
}

// Check if a number is happy
bool is_happy(int n) {
    // Use an array to track seen numbers (cycle detection)
    // Maximum value after sum of squares of a reasonable number is bounded
    // For safety, we'll use a hash set approach with a fixed-size array
    int seen[1000];
    int seen_count = 0;
    
    while (n != 1) {
        // Check if we've seen this number before (cycle detection)
        for (int i = 0; i < seen_count; i++) {
            if (seen[i] == n) {
                return false; // Cycle detected
            }
        }
        
        // Add current number to seen list
        if (seen_count < 1000) {
            seen[seen_count++] = n;
        } else {
            // If we've checked too many iterations, assume it's not happy
            return false;
        }
        
        n = sum_of_squares(n);
    }
    
    return true;
}

// Worker thread function
void* worker(void* arg) {
    ThreadData* data = (ThreadData*)arg;
    int local_count = 0;
    
    // Process assigned range
    for (int i = data->start; i <= data->end; i++) {
        if (is_happy(i)) {
            local_count++;
        }
    }
    
    // Update shared counter with mutex
    pthread_mutex_lock(&mutex);
    data->happy_count = local_count;
    pthread_mutex_unlock(&mutex);
    
    return NULL;
}

int main(int argc, char* argv[]) {
    // Check command line arguments
    if (argc != 2) {
        fprintf(stderr, "Usage: %s BOUND\n", argv[0]);
        fprintf(stderr, "  BOUND: positive integer to check happy numbers from 1 to BOUND\n");
        return 1;
    }
    
    // Parse BOUND argument
    char* endptr;
    long bound = strtol(argv[1], &endptr, 10);
    
    if (*endptr != '\0' || endptr == argv[1]) {
        fprintf(stderr, "Error: BOUND must be a valid integer\n");
        return 1;
    }
    
    if (bound < 1) {
        fprintf(stderr, "Error: BOUND must be a positive integer (greater than 0)\n");
        return 1;
    }
    
    // Determine number of threads (use number of CPU cores)
    int num_threads = (int)sysconf(_SC_NPROCESSORS_ONLN);
    if (num_threads < 1) {
        num_threads = 4; // Default fallback
    }
    
    // Don't create more threads than numbers to process
    if (num_threads > bound) {
        num_threads = bound;
    }
    
    // Allocate thread data and thread handles
    pthread_t* threads = malloc(num_threads * sizeof(pthread_t));
    ThreadData* thread_data = malloc(num_threads * sizeof(ThreadData));
    
    if (threads == NULL || thread_data == NULL) {
        fprintf(stderr, "Error: Failed to allocate memory\n");
        return 1;
    }
    
    // Calculate work distribution
    int numbers_per_thread = bound / num_threads;
    int remainder = bound % num_threads;
    
    // Create and launch threads
    int current_start = 1;
    for (int i = 0; i < num_threads; i++) {
        thread_data[i].start = current_start;
        thread_data[i].end = current_start + numbers_per_thread - 1;
        
        // Distribute remainder among first threads
        if (i < remainder) {
            thread_data[i].end++;
        }
        
        thread_data[i].happy_count = 0;
        current_start = thread_data[i].end + 1;
        
        if (pthread_create(&threads[i], NULL, worker, &thread_data[i]) != 0) {
            fprintf(stderr, "Error: Failed to create thread %d\n", i);
            return 1;
        }
    }
    
    // Wait for all threads to complete
    for (int i = 0; i < num_threads; i++) {
        pthread_join(threads[i], NULL);
    }
    
    // Collect results
    int total_happy = 0;
    for (int i = 0; i < num_threads; i++) {
        total_happy += thread_data[i].happy_count;
    }
    
    // Calculate and print percentage
    double percentage = ((double)total_happy / (double)bound) * 100.0;
    printf("Happy numbers from 1 to %ld: %d (%.2f%%)\n", bound, total_happy, percentage);
    
    // Cleanup
    free(threads);
    free(thread_data);
    pthread_mutex_destroy(&mutex);
    
    return 0;
}
