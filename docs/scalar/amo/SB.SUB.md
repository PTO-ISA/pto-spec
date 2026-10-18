<!-- GENERATED FROM: asl/scalar/amo/SB.SUB.asl -->
# SB.SUB

**Normative ASL source:** `asl/scalar/amo/SB.SUB.asl`

SB.SUB atomically applies width-sized modular sub and does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SB-SUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sb-sub-purpose role=purpose -->
## What SB.SUB is for
`SB.SUB` performs a store-only atomic subtraction on one byte. It supports indivisible byte-sized decrements while deliberately omitting the old-value result used by load-returning atomic forms.

<!-- PTO-READER-BLOCK: scalar-sb-sub-mechanism role=mechanism -->
## How the update works
The instruction snapshots `SrcL` and `SrcR`, preflights the same address for read and write access, reads one byte, subtracts the low 8 bits of the operand from the old byte, and writes the low 8 bits of the difference back. Arithmetic is modulo 2^8, so underflow wraps. The old byte never becomes an architectural result.

<!-- PTO-READER-BLOCK: scalar-sb-sub-inputs-outputs role=inputs-outputs -->
## Inputs and output
`SrcL` names the atomic address and `SrcR` supplies the subtrahend. Every Reg5 code is assigned: `0` names the architectural zero register, `1`..`23` select the other GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`. The updated byte in memory is the only output; no GPR or temporary queue receives the replaced value.

<!-- PTO-READER-BLOCK: scalar-sb-sub-effects role=effects -->
## Effects and ordering
On success, `SB.SUB` records one atomic memory event and invalidates a local reservation that overlaps the written byte. `rl=0` selects relaxed ordering and `rl=1` selects release ordering; this encoding has no acquire bit. Successful execution advances `TPC` by four bytes.

<!-- PTO-READER-BLOCK: scalar-sb-sub-constraints role=constraints -->
## Constraints and faults
One-byte access needs no additional alignment constraint. Both access probes must succeed and resolve to the same translated address before any memory effect. A probe failure, translation mismatch, invalid temporary-queue source, or undecodable word leaves memory, events, reservations, result state, and `TPC` unchanged before precise trap handling.

<!-- PTO-READER-BLOCK: scalar-sb-sub-example role=example -->
## Example
```text
sb.sub [a0], a1
```
If `a0` names a byte containing `0x00` and the low byte of `a1` is `0x01`, the stored modular difference is `0xff`. The instruction publishes no copy of the original `0x00`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sb.sub [SrcL], SrcR
sb.sub.rl [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sb_sub_32_op5_v0587 | L32 | 32 | 0xc000300b / 0xfc007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sb_sub_32_op5_v0587 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sb_sub_32_op5_v0587 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sb_sub_32_op5_v0587 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sb_sub_32_op5_v0587 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sb_sub_32_op5_v0587 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sb_sub_32_op5_v0587 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SB.SUB.asl -->
```asl
readonly func InstructionContractOperation_SB_SUB() => ScalarOperation
begin
    return ScalarOperation_SB_SUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SB.SUB.asl -->
```asl
readonly func InstructionContractHandler_SB_SUB()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SB_SUB()
    => AtomicOperation
begin
    return Atomic_SUB;
end;

pure func InstructionContractAtomicSizeBytes_SB_SUB()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractPublishesOldValue_SB_SUB()
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
- The effective address must be aligned to 1 byte. SrcL, SrcR, and rl have no reserved encodings in this form.
- The instruction has no destination field and cannot publish the old memory value to a GPR or temporary queue.

## State effects

- Snapshot SrcL and SrcR before any memory or architectural effect.
- SB.SUB stores the 8-bit modular difference; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 1-byte little-endian value, compute the 8-bit modular difference, and write one 1-byte result to the same location.
- Complete both read and write access probes before the memory load or store, and require both probes to resolve to the same translated address.
- On success, record one atomic memory event, invalidate an overlapping local reservation, and preserve a nonoverlapping reservation.

### Ordering

- rl=0 records the atomic event with relaxed ordering; rl=1 records it with release ordering. This encoding has no acquire bit.

## Exceptions

- Misalignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- If either read or write preflight fails, the instruction performs no load, store, event, reservation update, result publication, or TPC advance.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- sb.sub [a0], a1
- sb.sub.rl [t#1], u#1
