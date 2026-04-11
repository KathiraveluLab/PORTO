// Benchmark kernel: simulates a CPU-bound cryptographic workload
// equivalent to ZK proof generation in terms of computational cost.
// Used exclusively by porto_benchmark to measure BEAM orchestration
// overhead in isolation from Leo compiler startup latency.
// This is NOT part of the production leo bridge path.
use std::time::Instant;

fn main() {
    // Simulate ZK-equivalent CPU-bound hashing work (SHA-256 iterations)
    let start = Instant::now();
    let mut x: u64 = 0xcafe_babe_dead_beef;
    for _ in 0..1_000_000u64 {
        // Bit-mixing loop approximating snarkVM constraint solving cost
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
    }
    let elapsed = start.elapsed();
    // Emit result to stdout so Erlang OS Port can capture it
    println!("ok elapsed_us={}", elapsed.as_micros());
    // Prevent the optimizer from eliminating the loop
    std::hint::black_box(x);
}
