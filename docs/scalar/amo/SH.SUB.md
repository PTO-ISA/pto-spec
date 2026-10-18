<!-- GENERATED FROM: asl/scalar/amo/SH.SUB.asl -->
# SH.SUB

**Normative ASL source:** `asl/scalar/amo/SH.SUB.asl`

SH.SUB atomically applies width-sized modular sub and does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SH-SUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sh-sub-purpose role=purpose -->
## What SH.SUB is for
`SH.SUB` performs a store-only atomic subtraction on one aligned halfword. It gives programs an indivisible 16-bit decrement without creating a destination for the old memory value.

<!-- PTO-READER-BLOCK: scalar-sh-sub-mechanism role=mechanism -->
## How the update works
After snapshotting `SrcL` and `SrcR`, the instruction preflights read and write access, reads two little-endian bytes, subtracts the low 16 bits of the operand, and writes the low 16 bits of the difference. The calculation is modulo 2^16, so underflow wraps. The helper's old-value result is discarded.

<!-- PTO-READER-BLOCK: scalar-sh-sub-inputs-outputs role=inputs-outputs -->
## Inputs and output
`SrcL` provides the address and `SrcR` provides the subtrahend. Reg5 code `0` names the architectural zero register, `1`..`23` name the other GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Only the two-byte memory value is updated; no register or queue receives the replaced halfword.

<!-- PTO-READER-BLOCK: scalar-sh-sub-effects role=effects -->
## Effects and ordering
A successful `SH.SUB` records one atomic event, invalidates an overlapping local reservation, and advances `TPC` by four bytes. `rl=0` records relaxed ordering and `rl=1` records release ordering. No acquire bit is present.

<!-- PTO-READER-BLOCK: scalar-sh-sub-constraints role=constraints -->
## Constraints and faults
The address must be two-byte aligned. Misalignment precedes translation and permission faults, and the read and write probes must agree on the translated address. Failure before the atomic update preserves memory, events, reservations, GPRs, temporary queues, and the original `TPC` for full reissue.

<!-- PTO-READER-BLOCK: scalar-sh-sub-example role=example -->
## Example
```text
sh.sub [a0], a1
```
If the aligned halfword is `0x0000` and the low 16 bits of `a1` are `0x0001`, the stored modular difference is `0xffff`. The prior `0x0000` is not published.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sh.sub [SrcL], SrcR
sh.sub.rl [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sh_sub_32_op5_v0587 | L32 | 32 | 0xc000500b / 0xfc007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sh_sub_32_op5_v0587 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sh_sub_32_op5_v0587 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sh_sub_32_op5_v0587 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sh_sub_32_op5_v0587 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sh_sub_32_op5_v0587 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sh_sub_32_op5_v0587 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SH.SUB.asl -->
```asl
readonly func InstructionContractOperation_SH_SUB() => ScalarOperation
begin
    return ScalarOperation_SH_SUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SH.SUB.asl -->
```asl
readonly func InstructionContractHandler_SH_SUB()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SH_SUB()
    => AtomicOperation
begin
    return Atomic_SUB;
end;

pure func InstructionContractAtomicSizeBytes_SH_SUB()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractPublishesOldValue_SH_SUB()
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
- The effective address must be aligned to 2 bytes. SrcL, SrcR, and rl have no reserved encodings in this form.
- The instruction has no destination field and cannot publish the old memory value to a GPR or temporary queue.

## State effects

- Snapshot SrcL and SrcR before any memory or architectural effect.
- SH.SUB stores the 16-bit modular difference; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 2-byte little-endian value, compute the 16-bit modular difference, and write one 2-byte result to the same location.
- Complete both read and write access probes before the memory load or store, and require both probes to resolve to the same translated address.
- On success, record one atomic memory event, invalidate an overlapping local reservation, and preserve a nonoverlapping reservation.

### Ordering

- rl=0 records the atomic event with relaxed ordering; rl=1 records it with release ordering. This encoding has no acquire bit.

## Exceptions

- Misalignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- If either read or write preflight fails, the instruction performs no load, store, event, reservation update, result publication, or TPC advance.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- sh.sub [a0], a1
- sh.sub.rl [t#1], u#1
