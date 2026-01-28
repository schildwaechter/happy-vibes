use rayon::prelude::*;
use std::collections::HashSet;
use std::env;
use std::process;

/// Calculate the sum of squares of digits in a number
fn sum_of_squares(mut n: u32) -> u32 {
    let mut sum = 0;
    while n > 0 {
        let digit = n % 10;
        sum += digit * digit;
        n /= 10;
    }
    sum
}

/// Determine if a number is a happy number
/// A happy number is defined by the following process:
/// Starting with any positive integer, replace the number by the sum of the squares of its digits.
/// Repeat the process until the number equals 1 (happy) or loops endlessly in a cycle (not happy).
fn is_happy(mut n: u32) -> bool {
    let mut seen = HashSet::new();

    while n != 1 {
        if !seen.insert(n) {
            // We've seen this number before, it's a cycle
            return false;
        }
        n = sum_of_squares(n);
    }

    true
}

fn main() {
    // Parse command line arguments
    let args: Vec<String> = env::args().collect();

    if args.len() != 2 {
        eprintln!("Usage: {} BOUND", args[0]);
        eprintln!("  BOUND: positive integer to check happy numbers from 1 to BOUND");
        process::exit(1);
    }

    // Parse BOUND argument
    let bound: u32 = match args[1].parse() {
        Ok(num) if num > 0 => num,
        Ok(_) => {
            eprintln!("Error: BOUND must be a positive integer (greater than 0)");
            process::exit(1);
        }
        Err(_) => {
            eprintln!("Error: BOUND must be a valid integer");
            process::exit(1);
        }
    };

    // Use rayon to parallelize the calculation
    let happy_count: u32 = (1..=bound).into_par_iter().filter(|&n| is_happy(n)).count() as u32;

    // Calculate and print percentage
    let percentage = (happy_count as f64 / bound as f64) * 100.0;
    println!(
        "Happy numbers from 1 to {}: {} ({:.2}%)",
        bound, happy_count, percentage
    );
}
