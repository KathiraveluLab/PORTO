# PORTO
Private Off-chain Resource Tracking and Orchestration

PORTO is a radically new decentralized framework that implements an Actor-Model orchestration engine using Erlang/OTP natively integrated with the Aleo Zero-Knowledge (ZK) execution layer via the Leo CLI.

It fundamentally solves the throughput-privacy trilemma plaguing monolithic Layer-2 sequencers by completely isolating state logic across multi-node parallel environments. Mathematical confidentiality is generated strictly off-chain while verifiable cryptographic proofs are transmitted to the Aleo ecosystem.

## Build Requirements

1. **Erlang/OTP >= 25** (for the `core` orchestration framework)
2. **Rebar3** (Erlang build tool)
3. **Rust & Cargo** (Required to natively compile the Aleo dependencies)
4. **Leo CLI** (Aleo's zero-knowledge circuit compiler)

## Quick Start (Local Dry-run Execution)

### 1. Installing Aleo & Leo
```bash
# Clone the Leo repository to install the Leo CLI locally
git clone https://github.com/AleoHQ/leo
cd leo
cargo install --path .
```
Verify the installation by running `leo --version`.

### 2. Running PORTO Core
Once the zero-knowledge environment is accessible, you can compile and boot the Erlang distributed orchestration engine natively:

```bash
cd core
rebar3 compile
erl -pa _build/default/lib/core/ebin
```

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

The benchmark measures orchestration layer overhead independently of Leo compiler startup latency. See `results.tex` for the reported values and methodology.

### 5. HTTP API (when running as a release)

Once started, the node accepts tracking requests over HTTP:

```bash
curl -X POST http://localhost:8080/track \
  -H "Content-Type: application/json" \
  -d '{"resource_id": "node-42"}'
```

The port defaults to `8080` and can be overridden via the `$PORT` environment variable at release time.
