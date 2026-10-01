<!-- GENERATED FROM: asl/scalar/amo/SD.SMAX.asl -->
# SD.SMAX

**Normative ASL source:** `asl/scalar/amo/SD.SMAX.asl`

SD.SMAX atomically replaces the aligned 64-bit memory value with its signed maximum with SrcR; it does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SD-SMAX}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sd-smax-purpose role=purpose -->
## What SD.SMAX does
`SD.SMAX` atomically updates one aligned 8-byte memory value and stores the result. It publishes no old value and writes no register or temporary queue.
Its recorded summary is: SD.SMAX atomically replaces the aligned 64-bit memory value with its signed maximum with SrcR; it does not publish the old value. The `SD` prefix marks the width, 8 bytes of memory per operation. Replacing a value requires reading it first, and that read happens inside the same atomic access.

<!-- PTO-READER-BLOCK: scalar-sd-smax-mechanism role=mechanism -->
## Atomic mechanism
The instruction contract selects `ScalarHandler_AtomicReadModifyWrite` at width `8` and maps this operation to `Atomic_SMAX`. Scalar dispatch calls `AtomicReadModifyWrite`, which preflights the same address twice, reads, combines, and writes back; its return value is discarded.
`Atomic_SMAX` compares `SInt(old_value)` with `SInt(operand)` and returns the larger.
The helper returns the old memory value, but scalar dispatch passes `write_result` as `FALSE`, and the metadata helper `InstructionContractPublishesOldValue_SD_SMAX` also returns `FALSE`, so nothing is published.
Design point: the read probe is built and checked before the write probe is built, so a permitted read with a refused write faults with memory untouched, before any load takes place.

<!-- PTO-READER-BLOCK: scalar-sd-smax-inputs-outputs role=inputs-outputs -->
## Inputs and result
`SrcL` supplies the atomic address. `SrcR` supplies the atomic operand, and the stored value comes from the value already at the address, compared as two's-complement signed integers with the larger value kept.
`rl` is the release bit: `rl=0` records the atomic event as relaxed and `rl=1` as release. This form has no acquire bit, so it cannot record acquire or acquire-release ordering. `far` is a route hint only: `AtomicAddress` returns its `address` argument unchanged, so it changes neither the address nor the ordering nor the result.
All 32 Reg5 source codes are assigned: `0`..`23` name a GPR, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. There is no destination field, so the old value reaches no GPR and no queue.

<!-- PTO-READER-BLOCK: scalar-sd-smax-effects role=effects -->
## Effects and ordering
A successful operation reads the old value, selects the larger signed value, stores that result back to the same translated address, and records one atomic memory event with the selected ordering. `SD` records no numeric status.
The completed write invalidates a local reservation that overlaps the written range, and leaves a nonoverlapping one untouched; the check happens inside `StoreTranslated` against the 64-byte reservation granule. Success then advances `TPC` by `4` bytes.
Design point: the old value is read as part of the atomic operation and then discarded, so a program that needs it must use `SWAPD`, `CASD`, or an `LD` form, all of which carry a destination field. A sequence of `SD` forms cannot observe prior memory contents through a register.

<!-- PTO-READER-BLOCK: scalar-sd-smax-constraints role=constraints -->
## Legality and precise faults
The effective address must be aligned to `8` bytes. `ProbeDataAccess` compares the address against the access width before it consults translation, so misalignment is reported ahead of a translation or permission fault, and a failing probe reports the original architectural address.
If either probe fails, nothing happens at all: no load, no store, no memory event, no reservation update, no publication, no `TPC` advance. One further outcome exists when both probes pass but resolve to different translated addresses: the helper sets `Fault_DataPage` on the original address and changes no memory.
`Fault_IllegalInstruction` is raised before any effect when no form decodes the 32-bit pattern (this one matches `0x4000500b` under mask `0xf4007fff`), and also when a named source selects a temporary queue entry that is not currently valid. Encoded zero in `SrcL` reads the architectural zero register as the address, and encoded zero in `SrcR` supplies numeric zero as the operand.
Design point: a refused address has to leave memory and the reservation state as they were, because the trap saves the original `TPC` and recovery restores it, so the instruction is reissued in full instead of resumed mid-operation.
Design point: both sources are read before the result is stored, and `SrcL` and `SrcR` may name the same register; the operand is then still the pre-instruction value.

<!-- PTO-READER-BLOCK: scalar-sd-smax-example role=example -->
## Non-normative example
This example illustrates the current ASL owner and does not replace the normative operation.
The four accepted spellings of this operation are the ones below; `.rl`, `.f`, and `.rlf` only select ordering or routing.
```text
sd.smax [SrcL], SrcR
sd.smax.rl [SrcL], SrcR
sd.smax.f [SrcL], SrcR
sd.smax.rlf [SrcL], SrcR
```
Memory holds `0xffffffffffffffff`, which is -1 read as a signed integer, and the register named by `SrcR` holds `1`.
The signed maximum is `1`, and that is the value stored back.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sd.smax [SrcL], SrcR
sd.smax.rl [SrcL], SrcR
sd.smax.f [SrcL], SrcR
sd.smax.rlf [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sd_smax_32_e59bf90b50c3 | L32 | 32 | 0x4000500b / 0xf4007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sd_smax_32_e59bf90b50c3 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sd_smax_32_e59bf90b50c3 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sd_smax_32_e59bf90b50c3 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| sd_smax_32_e59bf90b50c3 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sd_smax_32_e59bf90b50c3 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sd_smax_32_e59bf90b50c3 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sd_smax_32_e59bf90b50c3 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| sd_smax_32_e59bf90b50c3 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| far | flat-address routing hint |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SD.SMAX.asl -->
```asl
readonly func InstructionContractOperation_SD_SMAX() => ScalarOperation
begin
    return ScalarOperation_SD_SMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SD.SMAX.asl -->
```asl
readonly func InstructionContractHandler_SD_SMAX()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SD_SMAX()
    => AtomicOperation
begin
    return Atomic_SMAX;
end;

pure func InstructionContractAtomicSizeBytes_SD_SMAX()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_SD_SMAX()
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
- The effective address must be aligned to 8 bytes. SrcL, SrcR, far, and rl have no reserved encodings in this form.
- The instruction has no destination field and cannot publish the old memory value to a GPR or temporary queue.

## State effects

- Snapshot SrcL and SrcR before any memory or architectural effect.
- SD.SMAX compares both values as two's-complement signed integers and selects the larger value at 64-bit width and stores that value; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the signed maximum, and write one 8-byte result to the same location.
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

- sd.smax [a0], a1
- sd.smax.rl [t#1], u#1
- sd.smax.f [sp], a0
