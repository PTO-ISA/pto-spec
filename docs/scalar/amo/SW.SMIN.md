<!-- GENERATED FROM: asl/scalar/amo/SW.SMIN.asl -->
# SW.SMIN

**Normative ASL source:** `asl/scalar/amo/SW.SMIN.asl`

SW.SMIN atomically replaces the aligned 32-bit memory value with its signed minimum with SrcR; it does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SW-SMIN}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sw-smin-purpose role=purpose -->
## What SW.SMIN does
`SW.SMIN` atomically updates one aligned 4-byte memory value and stores the result. It publishes no old value and writes no register or temporary queue.
Its recorded summary is: SW.SMIN atomically replaces the aligned 32-bit memory value with its signed minimum with SrcR; it does not publish the old value. The `SW` prefix marks the width, 4 bytes of memory per operation, and the store needs the value it replaces, read inside the same atomic access.

<!-- PTO-READER-BLOCK: scalar-sw-smin-mechanism role=mechanism -->
## Atomic mechanism
The instruction contract selects `ScalarHandler_AtomicReadModifyWrite` at width `4` and maps this operation to `Atomic_SMIN`. Scalar dispatch calls `AtomicReadModifyWrite`, which preflights the same address twice, reads, combines, and writes back; its return value is discarded.
`Atomic_SMIN` compares `SInt(old_value)` with `SInt(operand)` and returns the smaller.
The helper returns the old memory value, but the dispatch passes `write_result` as `FALSE` and the form has no destination field, so nothing is published.
Design point: an `SW` operation is defined at 32 bits, so exactly the low 32 bits of the operand register are used. Bits `32` and above never reach memory, and the stored 4-byte value is the low 32 bits of the result.

<!-- PTO-READER-BLOCK: scalar-sw-smin-inputs-outputs role=inputs-outputs -->
## Inputs and result
`SrcL` supplies the atomic address. `SrcR` supplies the atomic operand, and the stored value comes from the value already at the address, compared as two's-complement signed integers with the smaller value kept.
`rl` is the release bit: `rl=0` records the atomic event as relaxed and `rl=1` as release. This form has no acquire bit, so it cannot record acquire or acquire-release ordering. `far` is a route hint only: `AtomicAddress` returns its `address` argument unchanged, so it changes neither the address nor the ordering nor the result.
All 32 Reg5 source codes are assigned: `0`..`23` name a GPR, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. There is no destination field, so the old value reaches no GPR and no queue.

<!-- PTO-READER-BLOCK: scalar-sw-smin-effects role=effects -->
## Effects and ordering
A successful operation reads the old value, selects the smaller signed value, stores that result back to the same translated address, and records one atomic memory event with the selected ordering. `SW` records no numeric status.
The completed write invalidates a local reservation that overlaps the written range, and leaves a nonoverlapping one untouched; the check happens inside `StoreTranslated` against the 64-byte reservation granule. Success then advances `TPC` by `4` bytes.
Design point: with the width fixed at 32 bits, only the low 32 bits of the addressed location take part, so a caller keeping a wider value there must treat this operation as updating only its low half.

<!-- PTO-READER-BLOCK: scalar-sw-smin-constraints role=constraints -->
## Legality and precise faults
The effective address must be aligned to `4` bytes. `ProbeDataAccess` compares the address against the access width before it consults translation, so misalignment is reported ahead of a translation or permission fault, and a failing probe reports the original architectural address.
If either probe fails, nothing happens at all: no load, no store, no memory event, no reservation update, no publication, no `TPC` advance. One further outcome exists when both probes pass but resolve to different translated addresses: the helper sets `Fault_DataPage` on the original address and changes no memory.
`Fault_IllegalInstruction` is raised before any effect when no form decodes the 32-bit pattern (this one matches `0x5000300b` under mask `0xf4007fff`), and also when a named source selects a temporary queue entry that is not currently valid. Encoded zero in `SrcL` reads the architectural zero register as the address, and encoded zero in `SrcR` supplies numeric zero as the operand.
Design point: an unaligned address and an untranslatable one are different traps, and alignment is tested first, so a debugger can separate them without reconstructing the access size.
Design point: both sources are read before the result is stored, and `SrcL` and `SrcR` may name the same register; the operand is then still the pre-instruction value.

<!-- PTO-READER-BLOCK: scalar-sw-smin-example role=example -->
## Non-normative example
This example illustrates the current ASL owner and does not replace the normative operation.
The four accepted spellings of this operation are the ones below; `.rl`, `.f`, and `.rlf` only select ordering or routing.
```text
sw.smin [SrcL], SrcR
sw.smin.rl [SrcL], SrcR
sw.smin.f [SrcL], SrcR
sw.smin.rlf [SrcL], SrcR
```
The 4-byte value at the aligned address is `0xffffffff`, which is -1 read as a 32-bit signed integer, and the register named by `SrcR` holds `1`.
The signed minimum is `0xffffffff`, and that is the value stored back.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sw.smin [SrcL], SrcR
sw.smin.rl [SrcL], SrcR
sw.smin.f [SrcL], SrcR
sw.smin.rlf [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sw_smin_32_773e7d83b011 | L32 | 32 | 0x5000300b / 0xf4007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sw_smin_32_773e7d83b011 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sw_smin_32_773e7d83b011 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sw_smin_32_773e7d83b011 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| sw_smin_32_773e7d83b011 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sw_smin_32_773e7d83b011 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sw_smin_32_773e7d83b011 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sw_smin_32_773e7d83b011 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| sw_smin_32_773e7d83b011 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| far | flat-address routing hint |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SW.SMIN.asl -->
```asl
readonly func InstructionContractOperation_SW_SMIN() => ScalarOperation
begin
    return ScalarOperation_SW_SMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SW.SMIN.asl -->
```asl
readonly func InstructionContractHandler_SW_SMIN()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SW_SMIN()
    => AtomicOperation
begin
    return Atomic_SMIN;
end;

pure func InstructionContractAtomicSizeBytes_SW_SMIN()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractPublishesOldValue_SW_SMIN()
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
- SW.SMIN compares both values as two's-complement signed integers and selects the smaller value at 32-bit width and stores that value; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 4-byte little-endian value, compute the signed minimum, and write one 4-byte result to the same location.
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

- sw.smin [a0], a1
- sw.smin.rl [t#1], u#1
- sw.smin.f [sp], a0
