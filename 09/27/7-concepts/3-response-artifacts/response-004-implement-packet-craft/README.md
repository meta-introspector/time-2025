This flake (`response-004-implement-packet-craft`) implements the `packet-craft` subcommand in `streamofrandom_cli`.

### Feature Description:

The `packet-craft` subcommand constructs TCP/IP packets in Rust, with each packet corresponding to a prime number from the `zos` set (`[2, 3, 5, 7, 11, 13, 17, 19, 23]`). The implementation focuses on bit-level precision, aiming for "beautify, meaningful, and true" packet construction.

For each prime number:
*   A basic Ethernet/IPv4/TCP packet is constructed.
*   The prime number is used as the **TCP destination port**.
*   The **payload** of the TCP packet contains a string indicating the prime number.
*   The crafted packet is output as a hexadecimal string to stdout.

### How it works:

1.  **Input `streamofrandomCli`:** It takes the `streamofrandom_cli` project (located in the parent directory) as an input.
2.  **Modify `Cargo.toml`:** The `Cargo.toml` for `streamofrandom_cli` is modified to include the `etherparse` crate as a dependency.
3.  **Modify `src/main.rs`:** The `src/main.rs` file is updated to:
    *   Add `PacketCraft` as a new subcommand.
    *   Implement the logic for `PacketCraft`, iterating through the `zos` primes.
    *   Use `etherparse` to build Ethernet, IPv4, and TCP headers, setting fields based on the prime number.
    *   Print the resulting packet as a hex string.
4.  **Build `streamofrandom_cli`:** The modified `streamofrandom_cli` is then built.

### Usage:

To build the modified `streamofrandom_cli` and make it available in your environment, navigate to this directory and run:

```bash
nix build
```

Then, to run the `packet-craft` subcommand, you can use:

```bash
./result/bin/streamofrandom_cli packet-craft
```

Alternatively, to enter a development shell where `streamofrandom_cli` is in your PATH, run:

```bash
nix develop
```

Inside the devShell, you can directly run:

```bash
streamofrandom_cli packet-craft
```
