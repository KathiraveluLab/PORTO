# Sustainability Quota Compliance — PORTO Use Case

This use case demonstrates PORTO applied to verifiable sustainable resource usage,
motivated by the EQUISYS goal of equitable and sustainable digital societies.

## Scenario

An organisation (e.g., a shared compute provider, energy cooperative, or
community broadband network) is allocated a resource quota (energy, bandwidth,
compute hours). At the end of a period, it must prove to a regulator or auditor
that its actual consumption did not exceed the quota — without revealing its
exact usage figure.

## Why this matters

Revealing precise consumption figures is commercially sensitive and may expose
competitive or operational intelligence. \projectname enables compliance proofs
that satisfy regulators without sacrificing data sovereignty.

## Structure

```
sustainability_quota/
├── circuits/              # Leo/Aleo ZK circuit
│   ├── program.json
│   └── src/main.leo       # verify_quota transition
└── core/                  # Erlang orchestration layer (extends PORTO)
    └── src/
        ├── porto_quota_actor.erl   # gen_server actor per participant
        └── porto_quota_sup.erl     # simple_one_for_one supervisor
```

## How it extends PORTO

Reuses `porto_leo_bridge:verify_quota/3` (shared bridge API) and `porto_cluster`
process group. The quota actors plug into PORTO without modifying core.

## Running the circuit

```bash
cd circuits
leo run verify_quota 45u32 1234567890123456789012345678901234567890u128 100u32
# ^ proves: usage=45 <= quota=100
```

A constraint violation (usage > quota) causes Leo to abort with a non-zero exit.
