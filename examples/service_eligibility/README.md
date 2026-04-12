# Service Eligibility — PORTO Use Case

This use case demonstrates PORTO applied to privacy-preserving eligibility
verification for public digital services, motivated by the EQUISYS goal of
human-centered design for equitable and sustainable digital societies.

## Scenario

A citizen or household applies for a public digital service (e.g., subsidised
broadband access, a digital skills program, or community compute credits). To
qualify, their eligibility score — derived from an income decile, geographic
remoteness index, or social vulnerability index — must not exceed a publicly
known threshold. Requiring applicants to disclose their full score or underlying
attributes to the service provider is a privacy violation and a barrier to uptake.

PORTO enables the applicant to prove eligibility without revealing their score.

## Structure

```
service_eligibility/
├── circuits/              # Leo/Aleo ZK circuit
│   ├── program.json
│   └── src/main.leo       # verify_eligibility transition
└── core/                  # Erlang orchestration layer (extends PORTO)
    └── src/
        ├── porto_eligibility_actor.erl
        └── porto_eligibility_sup.erl
```

## How it extends PORTO

Reuses `porto_leo_bridge:verify_eligibility/3` (shared bridge API) and the
`porto_cluster` process group. The eligibility actors plug into PORTO without
modifying core. The Mnesia audit record stores only the eligibility fact and
threshold applied — never the applicant's score.

## Running the circuit

```bash
cd circuits
leo run verify_eligibility 30u32 1234567890123456789012345678901234567890u128 50u32
# ^ proves: score=30 <= threshold=50 (applicant qualifies)
```

A score above the threshold causes Leo to abort with a non-zero exit.
