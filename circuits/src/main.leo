// The execution boundaries mapped strictly corresponding to the Aleo ecosystem layer.
program porto_circuits.aleo {
    // A simplified proof boundary verifying that the resource states adhere to standard u32 mathematics
    transition main(public a: u32) -> u32 {
        let c: u32 = a + 10u32;
        return c;
    }
}
