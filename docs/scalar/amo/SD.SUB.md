<!-- GENERATED FROM: asl/scalar/amo/SD.SUB.asl -->
# SD.SUB

**Normative ASL source:** `asl/scalar/amo/SD.SUB.asl`

SD.SUB atomically applies width-sized modular sub and does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SD-SUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sd-sub-purpose role=purpose -->
## What SD.SUB is for
`SD.SUB` atomically subtracts from one aligned 64-bit memory doubleword and stores the result. It avoids an unnecessary destination when a program needs only an indivisible update, not the old memory value.

<!-- PTO-READER-BLOCK: scalar-sd-sub-mechanism role=mechanism -->
## How the update works
The instruction snapshots `SrcL` and `SrcR`, preflights read and write access, reads eight little-endian bytes, computes `old_value - operand`, and writes the 64-bit difference back. Arithmetic is modulo 2^64. The atomic helper returns the old doubleword internally, but store-only dispatch discards it.

<!-- PTO-READER-BLOCK: scalar-sd-sub-inputs-outputs role=inputs-outputs -->
## Inputs and output
`SrcL` names the atomic address and `SrcR` supplies the 64-bit subtrahend. Reg5 code `0` names the architectural zero register, `1`..`23` select the other GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`. The updated eight-byte memory value is the only output; no GPR or temporary queue receives the old value.

<!-- PTO-READER-BLOCK: scalar-sd-sub-effects role=effects -->
## Effects and ordering
Successful execution records one atomic event, invalidates an overlapping local reservation, and advances `TPC` by four bytes. `rl=0` records relaxed ordering and `rl=1` records release ordering. There is no acquire form.

<!-- PTO-READER-BLOCK: scalar-sd-sub-constraints role=constraints -->
## Constraints and faults
The address must be eight-byte aligned. Alignment precedes translation and permission checks, and both probes must identify the same translated address before memory is read. A failure leaves memory, events, reservations, registers, queues, and `TPC` unchanged and reports the original architectural address through the precise fault path.

<!-- PTO-READER-BLOCK: scalar-sd-sub-example role=example -->
## Example
```text
sd.sub [a0], a1
```
If the aligned doubleword contains `0x0000000000000003` and `a1` contains `0x0000000000000005`, the stored modular difference is `0xfffffffffffffffe`. The old value `3` is not returned.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sd.sub [SrcL], SrcR
sd.sub.rl [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sd_sub_32_op5_v0587 | L32 | 32 | 0x4000500b / 0xfc007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sd_sub_32_op5_v0587 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sd_sub_32_op5_v0587 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sd_sub_32_op5_v0587 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sd_sub_32_op5_v0587 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sd_sub_32_op5_v0587 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sd_sub_32_op5_v0587 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SD.SUB.asl -->
```asl
readonly func InstructionContractOperation_SD_SUB() => ScalarOperation
begin
    return ScalarOperation_SD_SUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SD.SUB.asl -->
```asl
readonly func InstructionContractHandler_SD_SUB()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SD_SUB()
    => AtomicOperation
begin
    return Atomic_SUB;
end;

pure func InstructionContractAtomicSizeBytes_SD_SUB()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_SD_SUB()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL and SrcR are required Reg5 sources. Encoded zero reads the architectural zero register.
- rl=0 selects relaxed ordering; rl=1 selects release ordering.

## Legality

- All 32 Reg5 source encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- The effective address must be aligned to 8 bytes. SrcL, SrcR, and rl have no reserved encodings in this form.
- The instruction has no destination field and cannot publish the old memory value to a GPR or temporary queue.

## State effects

- Snapshot SrcL and SrcR before any memory or architectural effect.
- SD.SUB stores the 64-bit modular difference; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 8-byte little-endian value, compute the 64-bit modular difference, and write one 8-byte result to the same location.
- Complete both read and write access probes before the memory load or store, and require both probes to resolve to the same translated address.
- On success, record one atomic memory event, invalidate an overlapping local reservation, and preserve a nonoverlapping reservation.

### Ordering

- rl=0 records the atomic event with relaxed ordering; rl=1 records it with release ordering. This encoding has no acquire bit.

## Exceptions

- Misalignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- If either read or write preflight fails, the instruction performs no load, store, event, reservation update, result publication, or TPC advance.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- sd.sub [a0], a1
- sd.sub.rl [t#1], u#1
