// PORTO base circuits - general-purpose ZK transition.
// Domain-specific circuits (e.g., Equitable Allocation Circuit - PORTO Use Case)
program porto_circuits.aleo {

    fn main(public a: u32) -> u32 {
        let c: u32 = a + 10u32;
        return c;
    }
}

