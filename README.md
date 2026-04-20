# PORTO
Private Off-chain Resource Tracking and Orchestration

PORTO is a radically new decentralized framework that implements an Actor-Model orchestration engine using Erlang/OTP natively integrated with the Aleo Zero-Knowledge (ZK) execution layer via the Leo CLI.

It fundamentally solves the throughput-privacy trilemma plaguing monolithic Layer-2 sequencers by completely isolating state logic across multi-node parallel environments. Mathematical confidentiality is generated strictly off-chain while verifiable cryptographic proofs are transmitted to the Aleo ecosystem.

## Build & Installation

The easiest way to set up PORTO and its dependencies (Erlang, Rust, Leo CLI) is using the provided setup script. The script is **idempotent** and will automatically:
*   Install missing system headers (OpenSSL, pkg-config).
*   **Resolve OTP Version Mismatches**: It bootstraps `rebar3` from source to guarantee compatibility with your local Erlang version (fixes the common "badfile" error).
*   Correctly build the Leo CLI from its sub-crate boundaries.

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

### 3. Compiling the Benchmark Kernel

The performance benchmarks require a native Rust binary that simulates ZK computation cost. Compile it once before running benchmarks:

```bash
cd circuits
rustc heavy_workload.rs -O -o heavy_workload
```

### 4. Running Benchmarks

From the `core/` directory, launch the Erlang shell and run:

```erlang
% Synchronous baseline (monolithic sequencer model), N=10 proofs
porto_benchmark:run_sync(10).

% PORTO parallel actor dispatch, N=10 proofs
porto_benchmark:run_porto_async(10).
```

The benchmark measures orchestration layer overhead independently of Leo compiler startup latency. 

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
