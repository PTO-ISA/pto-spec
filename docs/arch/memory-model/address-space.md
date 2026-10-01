<!-- GENERATED FROM: asl/arch/memory-model/address-space.asl -->
# Address Space

**Normative ASL source:** `asl/arch/memory-model/address-space.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-address-space-purpose role=purpose-scope -->
## Purpose and scope

This unit is the byte-storage floor of the memory model. It declares that PTO memory operations reach physical bytes through `ReadPhysicalMemoryByte` and `WritePhysicalMemoryByte`, and it supplies the two convenience wrappers `ReadMemoryByte` and `WriteMemoryByte`. The executable body below contains no translation table, no permission check and no fault path: it is five small helpers over one byte array.

The required clause is `PTO-REQ-PHYSICAL-MEMORY-BINDING-001`. The unit metadata on line 1 declares `PTO-ARCH-STATE-DEFINEDNESS` as its dependency, but the executable body never names definedness; treat the dependency as the unit-graph edge it is and not as a description of the code.

<!-- PTO-READER-BLOCK: arch-address-space-concepts role=concepts-state -->
## Bytes, addresses and the one state object

- `IsModelAddress` returns `UInt(address) < PTO_MODEL_MEMORY_BYTES`, so validity is a single unsigned comparison against a configuration value.
- `ReadPhysicalMemoryByte` asserts `IsModelAddress(address)`, converts with `let index = UInt(address) as ModelAddress` and returns `_Memory[[index]]`.
- `WritePhysicalMemoryByte` performs the same assert and conversion, then stores the `Byte` argument into `_Memory[[index]]`.
- `ReadMemoryByte` and `WriteMemoryByte` are unconditional one-line forwarders to the physical pair.
- The only state touched is `_Memory`, an `array [[PTO_MODEL_MEMORY_BYTES]] of Byte` owned by `PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT`.
- `PTO_MODEL_MEMORY_BYTES` is a `config` declared in `asl/arch/features/tile-allocation.asl` with range `256..65536` and default `4096`.

<!-- PTO-READER-BLOCK: arch-address-space-rules role=rules-interactions -->
## The access sequence and what a caller must establish

Both physical accessors assert `IsModelAddress(address)` and then convert to the `ModelAddress` range `0..PTO_MODEL_MEMORY_BYTES-1`. The two logical accessors do not check anything themselves; they inherit the assert from the callee.

Design point: the range check is an `assert`, which in ASL is a model-integrity condition, not an architectural fault. A caller that reaches these helpers with `UInt(address) >= PTO_MODEL_MEMORY_BYTES` fails the model run instead of producing a defined fault. The observable consequence is that this unit can never be the owner of a fault code; callers such as the scalar data path run their own probe first and convert a refusal into `Fault_DataPage` before calling here.

Design point: the conversion `UInt(address) as ModelAddress` happens after the assert, so the index is known to be in range and the array access is total. Because the physical helpers take a plain `Word` byte address and read exactly one `Byte`, unaligned and one-byte-granular access needs no special case: `0x7c0` and `0x7c1` are simply different indices.

<!-- PTO-READER-BLOCK: arch-address-space-boundaries role=boundaries -->
## Boundaries

The clause states that fixed reference-array bounds MUST NOT constrain every implementation, and that is exactly the status of `PTO_MODEL_MEMORY_BYTES` here: it bounds one executable model instance. This page does not claim that any implementation exposes `4096` architectural bytes.

Several capabilities the clause groups together are not present in this body. Translation is not here (the scalar path has `TranslateDataAddress`, instruction fetch has `TranslateInstructionAddress`). Permission is not here (`DataAccessPermitted` and `InstructionAccessPermitted` live elsewhere). Ordering, preflight and commit are not here either. This unit supplies only the byte floor those owners call.

Two callers do reach the physical pair directly rather than through the wrappers: the scalar data path uses `ReadMemoryByte` and `WriteMemoryByte` for example in `asl/scalar/model/agu/memory.asl`, and `FetchPTOInstruction` in `asl/arch/memory-model/instruction-fetch.asl` uses `ReadPhysicalMemoryByte`. No ASL unit outside this file calls `WritePhysicalMemoryByte`; `WriteMemoryByte` is the path that is actually taken. All of them run after a probe has already refused out-of-range addresses, so the assert here is a backstop rather than the primary check.

<!-- PTO-READER-BLOCK: arch-address-space-example role=example-usage -->
## Non-normative reading example

With the default `PTO_MODEL_MEMORY_BYTES` of `4096`, `IsModelAddress(0x7c0)` is true and `IsModelAddress(0x1000)` is false. `0x7c0` is `1984` and `0x1000` is `4096`, so the last address this helper accepts is `0xfff`.

A six-byte value starting at `0x7c0` is therefore written one byte at a time with `WriteMemoryByte(0x7c0, ...)` through `WriteMemoryByte(0x7c5, ...)`, and read back with the six matching `ReadMemoryByte` calls. Each call is independent: there is no multi-byte intrinsic and no implicit zeroing of the bytes between calls, and `IsModelAddress` validates only the single byte address it is given, never a multi-byte range.

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-address-space-related role=related-owners-navigation -->
## Related owners

- `PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT` declares the `_Memory` array and the `PTO-STATE-ARCH-MEMORY` state record that lists it.
- [Instruction fetch](instruction-fetch.md) calls `ReadPhysicalMemoryByte` directly and adds the probe that this unit does not have.
- [Global memory access](global-memory-access.md) and [Atomicity](atomicity.md) describe the request-level behavior built above these bytes.
- `PTO-ARCH-FEATURES-TILE-ALLOCATION` declares the `PTO_MODEL_MEMORY_BYTES` bound used by `IsModelAddress`.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/address-space.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE","surface":"arch","classification":["memory-model","address-space"],"depends_on":["PTO-ARCH-STATE-DEFINEDNESS"]}

// NDF-BEGIN: PTO-REQ-PHYSICAL-MEMORY-BINDING-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// PTO memory operations MUST reach physical byte storage through
// ReadPhysicalMemoryByte and WritePhysicalMemoryByte. An implementation MAY
// bind those primitives to external storage, but MUST preserve ASL-owned
// translation, permission, ordering, preflight, precise-fault, and commit
// behavior. Fixed reference-array bounds MUST NOT constrain every
// implementation.
// NDF-END: PTO-REQ-PHYSICAL-MEMORY-BINDING-001

readonly func ReadPhysicalMemoryByte(address: Word) => Byte
begin
    assert IsModelAddress(address);
    let index = UInt(address) as ModelAddress;
    return _Memory[[index]];
end;

func WritePhysicalMemoryByte(address: Word, value: Byte)
begin
    assert IsModelAddress(address);
    let index = UInt(address) as ModelAddress;
    _Memory[[index]] = value;
end;

readonly func IsModelAddress(address: Word) => boolean
begin
    return UInt(address) < PTO_MODEL_MEMORY_BYTES;
end;

readonly func ReadMemoryByte(address: Word) => Byte
begin
    return ReadPhysicalMemoryByte(address);
end;

func WriteMemoryByte(address: Word, value: Byte)
begin
    WritePhysicalMemoryByte(address, value);
end;
```
<!-- GENERATED-ASL-END: unit -->
