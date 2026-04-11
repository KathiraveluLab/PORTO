// The 'main' function validates off-chain resources using cryptographic hashing
program porto_circuit.aleo {
    transition verify_resource_allocation(public quota_hash: field, private usage: u32, private salt: field) -> bool {
        // Hash the private usage and a salt to verify it matches the public quota hash commitment
        // This ensures absolute zero-knowledge of the actual numbers while proving validity
        let computed_hash: field = Poseidon4::hash_to_field(usage as field + salt);
        let is_valid: bool = computed_hash == quota_hash;
        return is_valid;
    }
}
