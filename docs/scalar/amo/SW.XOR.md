<!-- GENERATED FROM: asl/scalar/amo/SW.XOR.asl -->
# SW.XOR

**Normative ASL source:** `asl/scalar/amo/SW.XOR.asl`

SW.XOR atomically replaces the aligned 32-bit memory value with its bitwise XOR with SrcR; it does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SW-XOR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sw-xor-purpose role=purpose -->
## What SW.XOR does

`SW.XOR` atomically replaces the aligned `4`-byte memory word at the address in `SrcL` with the bitwise XOR of that word and the value in `SrcR`.

It is one of the store-only atomic forms: the old memory value is discarded. There is no destination field in the encoding at all.

<!-- PTO-READER-BLOCK: scalar-sw-xor-mechanism role=mechanism -->
## Atomic mechanism

The instruction contract returns `ScalarHandler_AtomicReadModifyWrite` with `Atomic_XOR` and an access width of `4` bytes. The model then executes `AtomicReadModifyWrite`, which is a fixed sequence:

1. Probe read access for `4` bytes at the effective address and raise a fault if it fails.
2. Probe write access for `4` bytes at the same address and raise a fault if it fails.
3. Require both probes to translate to the same address; otherwise raise a data page fault.
4. Load the old word, XOR it with the operand, and store the result to the same location.
5. Record one atomic memory event carrying the old value, the new value, and the selected ordering.

`SrcL` and `SrcR` are snapshotted before any memory effect, so the operand value cannot change between the read and the write.

Design point: both probes complete before the load, so a form whose writes are not permitted faults without having read the location at all.

<!-- PTO-READER-BLOCK: scalar-sw-xor-inputs-outputs role=inputs-outputs -->
## Inputs and effect

`SrcL` carries the Reg5 atomic address source; `SrcR` carries the Reg5 atomic operand source; `far` carries the flat-address routing hint; `rl` carries the release ordering bit.

All `32` `SrcL` and `SrcR` encodings are assigned: `SrcL` and `SrcR` codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`. Encoded zero in either source reads the architectural zero register.

`rl=0` records the atomic event with relaxed ordering and `rl=1` with release ordering. This encoding has no acquire bit. `far=1` is a routing hint only: the reference profile computes the same architectural address and the same atomic result either way.

Design point: the field that would carry a destination selector is instead spent on the ordering bit and the routing hint, so the encoding cannot name an old-value destination even if software wanted one. `LW.XOR` is the form that returns the old value.

<!-- PTO-READER-BLOCK: scalar-sw-xor-effects role=effects -->
## Effects and ordering

On success the instruction performs exactly one atomic memory event, updates memory, and leaves `SrcL` and `SrcR` unchanged, because scalar sources are non-consuming.

The write publishes no destination value and no numeric status flag. `TPC` advances by `4` bytes, the length of the `32`-bit form.

A completed write invalidates a local reservation when it overlaps the `64`-byte reservation granule, and preserves a reservation on a different granule.

On a fault nothing is recorded: no memory event, no reservation change, and no `TPC` advance. Trap entry saves `TPC` so the instruction can be reissued.

<!-- PTO-READER-BLOCK: scalar-sw-xor-constraints role=constraints -->
## Legality and fault order

The effective address must be aligned to `4` bytes.

Dispatch runs its checks in a fixed order: decode, then operand legality, then scalar source availability, then the read and write probes. Alignment, translation, and permission failures are raised in that order and report the original address.

A preflight failure publishes no memory event, no reservation update, and no retirement effect. A selected `T` or `U` source that is not available is rejected with `Fault_IllegalInstruction` before the address is probed.

Design point: because every failure path leaves memory and `TPC` untouched, a recovering handler can reissue the same instruction and get the same access checks rather than a partially applied update.

<!-- PTO-READER-BLOCK: scalar-sw-xor-example role=example -->
## Non-normative example

Take `a0 = 1024` and `a1 = 9`, and let the `4`-byte word at address `1024` hold `5`.

`sw.xor [a0], a1` leaves the word at address `1024` holding `12`, and leaves `a0` holding `1024` and `a1` holding `9`.

The old value `5` is not written anywhere.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sw.xor [SrcL], SrcR
sw.xor.rl [SrcL], SrcR
sw.xor.f [SrcL], SrcR
sw.xor.rlf [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sw_xor_32_874c32572226 | L32 | 32 | 0x3000300b / 0xf4007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sw_xor_32_874c32572226 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sw_xor_32_874c32572226 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sw_xor_32_874c32572226 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| sw_xor_32_874c32572226 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sw_xor_32_874c32572226 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sw_xor_32_874c32572226 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sw_xor_32_874c32572226 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| sw_xor_32_874c32572226 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| far | flat-address routing hint |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SW.XOR.asl -->
```asl
readonly func InstructionContractOperation_SW_XOR() => ScalarOperation
begin
    return ScalarOperation_SW_XOR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SW.XOR.asl -->
```asl
readonly func InstructionContractHandler_SW_XOR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SW_XOR()
    => AtomicOperation
begin
    return Atomic_XOR;
end;

pure func InstructionContractAtomicSizeBytes_SW_XOR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractPublishesOldValue_SW_XOR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL and SrcR are required Reg5 sources. Encoded zero reads the architectural zero register.
- rl=0 selects relaxed ordering; rl=1 selects release ordering.
- far=0 selects the default flat-address route. far=1 is a routing hint and does not change the architectural address or atomic operation in the reference profile.

## Legality

- All 32 Reg5 source encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- The effective address must be aligned to 4 bytes. SrcL, SrcR, far, and rl have no reserved encodings in this form.
- The instruction has no destination field and cannot publish the old memory value to a GPR or temporary queue.

## State effects

- Snapshot SrcL and SrcR before any memory or architectural effect.
- SW.XOR computes the bitwise XOR of the old value and operand at 32-bit width and stores that value; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 4-byte little-endian value, compute the bitwise XOR, and write one 4-byte result to the same location.
- Complete both read and write access probes before the memory load or store, and require both probes to resolve to the same translated address.
- On success, record one atomic memory event, invalidate an overlapping local reservation, and preserve a nonoverlapping reservation.

### Ordering

- rl=0 records the atomic event with relaxed ordering; rl=1 records it with release ordering. This encoding has no acquire bit.
- far changes only the route hint in the reference profile and does not change ordering, address arithmetic, or the read-modify-write result.

## Exceptions

- Misalignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- If either read or write preflight fails, the instruction performs no load, store, event, reservation update, result publication, or TPC advance.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- sw.xor [a0], a1
- sw.xor.rl [t#1], u#1
- sw.xor.f [sp], a0
