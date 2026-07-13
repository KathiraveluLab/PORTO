# PORTO
**Private Off-chain Resource Tracking and Orchestration**

PORTO is a novel decentralized framework that implements an Actor-Model orchestration engine using Erlang/OTP natively integrated with the Aleo Zero-Knowledge (ZK) execution layer via the Leo CLI.

It fundamentally solves the throughput-privacy trilemma plaguing monolithic Layer-2 sequencers by completely isolating state logic across multi-node parallel environments. Mathematical confidentiality is generated strictly off-chain while verifiable cryptographic proofs are transmitted to the Aleo ecosystem.

See [Tutorial.md](Tutorial.md) for a deep dive into the philosophy and practical usage of PORTO.

## Build & Installation

The easiest way to set up PORTO and its dependencies (Erlang, Rust, Leo CLI) is using the provided setup script. The script is **idempotent** and will automatically:
*   Install missing system headers (OpenSSL, pkg-config).
*   **Resolve OTP Version Mismatches**: It bootstraps `rebar3` from source to guarantee compatibility with your local Erlang version (fixes the common "badfile" error).
*   Correctly build the Leo CLI from its sub-crate boundaries.
*   **Compile the Benchmark Kernel**: Automatically builds the native Rust workload kernel needed for performance testing.

### Linux (Requires sudo for system headers)
```bash
git clone https://github.com/KathiraveluLab/PORTO
cd PORTO
chmod +x setup_porto.sh
./setup_porto.sh
```

### Windows (Run as Administrator for Chocolatey/Path setup)
```bash
git clone https://github.com/KathiraveluLab/PORTO
cd PORTO
setup_porto.bat
```

## Quick Start (Local Dry-run Execution)

### 1. Running PORTO Core

After running the setup script, the PORTO `core` is already compiled. You can boot the Erlang distributed orchestration engine natively using `rebar3 shell`. This automatically handles dependency paths and starts the application supervision tree:

```bash
cd core
rebar3 shell
```

### 2. Spawning Actors

Inside the Erlang shell, you can dynamically spin up your off-chain tracking actors using the provided API. This will seamlessly spawn concurrent OS processes mapping to your Aleo execution circuits:

```erlang
% Spawns a new actor to track "ResourceA" and validate bounds via zero-knowledge
porto_core_app:track_resource("ResourceA").
```

### 3. Compiling the Benchmark Kernels (Optional/Manual)

The setup script already compiles the native Rust binaries that simulate ZK computation cost and run the concurrent baseline. If you need to recompile them manually:

```bash
cd circuits

# Compile the workload proxy kernel
rustc heavy_workload.rs -O -o heavy_workload

# Compile the native Rust concurrent baseline
rustc concurrent_baseline.rs -O -o concurrent_baseline
```

### 4. Running Benchmarks

PORTO provides two suites of benchmarks: (1) **Orchestration Layer Overhead (Workload Proxy)**, and (2) **End-to-End Execution (Live Leo ZK Compiler)**.

#### Option A: Running from the Erlang Shell

Start the Erlang VM in the `core/` directory:
```bash
cd core
rebar3 shell
```

Then, execute the benchmark functions in the Erlang shell:
```erlang
% --- 1. Orchestration Layer Overhead (Workload Proxy) ---
% Synchronous baseline (monolithic sequencer model), N=10 tasks
porto_benchmark:run_sync(10).

% PORTO parallel actor dispatch, N=10 tasks
porto_benchmark:run_porto_async(10).

% --- 2. End-to-End Execution (Live Leo ZK Compiler) ---
% Synchronous baseline running live Leo compiler, N=10 tasks
porto_benchmark:run_leo_sync(10).

% PORTO parallel actor dispatch running live Leo compiler, N=10 tasks
porto_benchmark:run_leo_porto_async(10).
```

#### Option B: Running directly from the Command Line

You can run the entire suite in non-interactive mode directly from your shell:
```bash
erl -pa _build/default/lib/*/ebin -noshell -eval \
"porto_benchmark:run_sync(10), \
 porto_benchmark:run_porto_async(10), \
 porto_benchmark:run_leo_sync(10), \
 porto_benchmark:run_leo_porto_async(10), \
 init:stop()."
```

To run the native Rust concurrent baseline (with $N=10$ tasks and $8$ worker threads):
```bash
./circuits/concurrent_baseline 10 8
``` 

### 5. HTTP API (when running as a release)

Once started, the node accepts tracking requests over HTTP:

```bash
curl -X POST http://localhost:8080/track \
  -H "Content-Type: application/json" \
  -d '{"resource_id": "node-42"}'
```

The port defaults to `8080` and can be overridden via the `$PORT` environment variable.

## Troubleshooting & Reset

If you encounter "badfile" errors, BEAM mismatches after an Erlang/OTP upgrade, or wish to reset the local database, use the provided cleanup utility.

### Running the Cleanup Utility
This utility will prompt for confirmation before deleting any data. It clears build artifacts, resets the Mnesia database, and performs an **ASCII-Safety Scan** to ensure no toolchain-breaking characters have been introduced.

```bash
# Linux
chmod +x cleanup.sh
./cleanup.sh

# Windows
cleanup.bat
```

### Manual Cleanup (Advanced)
If you prefer to perform individual steps manually:
*   **Reset Mnesia State**: `rm -rf core/data/`
*   **Clear Build Cache**: `rm -rf core/_build/`
*   **ASCII Check**: Ensure no non-ASCII characters (like em-dashes `—`) exist in `core/` or `circuits/`.

## Citation

If you use this work in your research, please cite the following publication:

* Kathiravelu, P. and Galinac Grbac, T. **Private Off-chain Resource Tracking and Orchestration: An Actor-Model Approach to Zero-Knowledge Computation.** In _the IEEE International Symposium on Systems Engineering (ISSE)._ Accepted. 8 pages. September 2026.

