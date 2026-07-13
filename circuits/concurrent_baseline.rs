use std::time::Instant;
use std::sync::mpsc;
use std::thread;
use std::env;

fn run_workload() -> u64 {
    let mut x: u64 = 0xcafe_babe_dead_beef;
    for _ in 0..1_000_000u64 {
        // Bit-mixing loop approximating snarkVM constraint solving cost
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
    }
    std::hint::black_box(x)
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 3 {
        eprintln!("Usage: concurrent_baseline <N> <num_workers>");
        std::process::exit(1);
    }
    
    let n: usize = args[1].parse().unwrap();
    let num_workers: usize = args[2].parse().unwrap();
    
    let start = Instant::now();
    
    let (tx, rx) = mpsc::channel();
    let rx = std::sync::Arc::new(std::sync::Mutex::new(rx));
    
    let (done_tx, done_rx) = mpsc::channel();
    
    let mut workers = Vec::new();
    for _ in 0..num_workers {
        let rx = rx.clone();
        let done_tx = done_tx.clone();
        let handle = thread::spawn(move || {
            loop {
                // Get a task from the receiver
                let task = {
                    let lock = rx.lock().unwrap();
                    lock.recv().ok()
                };
                match task {
                    Some(_) => {
                        run_workload();
                        done_tx.send(()).unwrap();
                    }
                    None => break, // Channel closed
                }
            }
        });
        workers.push(handle);
    }
    
    // Drop our clone of done_tx so that done_rx only has worker references
    drop(done_tx);
    
    // Send N tasks
    for _ in 0..n {
        tx.send(()).unwrap();
    }
    // Drop tx to signal no more tasks
    drop(tx);
    
    // Wait for N tasks to complete
    for _ in 0..n {
        done_rx.recv().unwrap();
    }
    
    let elapsed = start.elapsed();
    let time_ms = elapsed.as_secs_f64() * 1000.0;
    let tps = if time_ms > 0.0 { (n as f64) / (time_ms / 1000.0) } else { 0.0 };
    
    println!("=== RUST CONCURRENT BASELINE (N={}, Workers={}) ===", n, num_workers);
    println!("Total Time: {:.2} ms", time_ms);
    println!("Throughput: {:.2} TPS", tps);
}
