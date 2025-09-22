# CRQ: Userspace eBPF for Root Cause Analysis with Monadic Univalent Interface

## 1. Objective

To develop a system capable of performing deep root cause analysis by enabling the execution of kernel-like eBPF programs entirely within userspace. This system will provide a high-fidelity trace of system events, allowing for detailed inspection and anomaly detection without requiring kernel modifications or privileges typically associated with eBPF.

## 2. High-Level Architecture

The system will consist of three primary components, interconnected by a unified, monadic, and univalent interface:

1.  **Ideal Strace Generator:** Captures low-level system events from target userspace processes.
2.  **Unified Event Stream (Monadic Univalent Interface):** A canonical data format and processing pipeline for all system events.
3.  **Userspace eBPF Runtime (eBPF Consumer):** Executes eBPF programs against the unified event stream.

```mermaid
graph LR
    A[Target Userspace Process] -->|ptrace/syscalls| B(Ideal Strace Generator)
    B -->|Unified Event Stream (Monadic Univalent Interface)| C(Userspace eBPF Runtime)
    C -->|eBPF Program Execution| D[Root Cause Analysis / Output]
```

## 3. Unified Event Format (The Univalent Interface)

This will be a single, canonical Rust `struct` designed to represent any system event. Its "univalent" nature means it encapsulates all relevant attributes, with specific behaviors defined by Rust traits.

```rust
// Placeholder for the unified event struct
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SystemEvent {
    pub timestamp: u64,         // Nanoseconds since epoch
    pub pid: u32,               // Process ID
    pub tid: u32,               // Thread ID
    pub event_type: EventType,  // Enum: SyscallEntry, SyscallExit, FileOpen, NetPacket, etc.
    pub data: EventData,        // Enum holding event-specific data
    pub context: EventContext,  // Optional: Stack trace, CPU ID, etc.
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum EventType {
    SyscallEntry,
    SyscallExit,
    FileOpen,
    FileClose,
    NetRecv,
    NetSend,
    ProcessFork,
    ProcessExec,
    // ... other relevant event types
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum EventData {
    Syscall {
        number: i64,
        args: Vec<u64>, // Raw arguments
        ret: Option<i64>, // Return value for SyscallExit
    },
    File {
        path: String,
        flags: Option<i32>,
        mode: Option<u32>,
    },
    Network {
        src_ip: String,
        dst_ip: String,
        src_port: u16,
        dst_port: u16,
        payload_len: usize,
        // ... potentially payload snippet
    },
    // ... other event-specific data
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct EventContext {
    pub cpu_id: Option<u32>,
    pub stack_trace: Option<Vec<String>>, // Symbolic stack trace
    // ... other contextual information
}

// Traits for common behaviors (e.g., filtering, serialization) will be defined as needed.
// pub trait FilterableEvent { ... }
// pub trait CorrelatableEvent { ... }
```

## 4. Ideal Strace Generator (Event Capture & Transformation)

This component will:
*   Utilize `ptrace` (via vendorized Rust `strace` alternatives like `rstrace`, `lurk`, `intentrace`, `dutchcoders/trace`) to intercept system calls and other process events.
*   Parse the raw `ptrace` output and transform it into instances of the `SystemEvent` struct.
*   Stream these `SystemEvent` objects in a monadic fashion, ensuring robust error handling and flow control.

## 5. Userspace eBPF Runtime (eBPF Consumer)

This component will:
*   Integrate an eBPF bytecode interpreter/JIT (leveraging vendorized `rbpf` and `bpfjit`).
*   Load and execute eBPF programs that are designed to operate on the `SystemEvent` stream.
*   Provide a userspace environment where eBPF programs can perform filtering, aggregation, and custom analysis on the captured system events, mimicking kernel eBPF functionality.
*   The eBPF programs will be written to expect the `SystemEvent` structure as their input context.

## 6. Monadic Aspects

The event processing pipeline will be designed with monadic principles (Haskell-like) to ensure:
*   **Composability:** Event transformations and eBPF program execution can be chained together predictably.
*   **Error Handling:** Errors are propagated and handled gracefully, preventing system crashes.
*   **Context Management:** Implicit context (like process state or accumulated metrics) can be managed effectively.

## 7. Vendorized Tools Utilized

*   **Nix:** For environment management and potentially building/packaging the system.
*   **Rust Strace Equivalents (`rstrace`, `lurk`, `intentrace`, `dutchcoders/trace`):** For high-fidelity system call and event capture.
*   **eBPF Runtimes (`rbpf`, `bpfjit`):** For executing eBPF bytecode in userspace.
*   **eBPF Development Libraries (`aya`, `libbpf-rs`):** For writing and compiling eBPF programs that target our userspace runtime.

## 8. Next Steps

*   Refine the `SystemEvent` struct and associated enums/traits.
*   Begin implementing a basic `StraceGenerator` that outputs `SystemEvent` instances.
*   Develop a minimal `UserspaceEbpfRuntime` that can load and execute a simple eBPF program against a mock `SystemEvent` stream.
