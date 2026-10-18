<!-- GENERATED FROM: asl/scalar/amo/SB.ADD.asl -->
# SB.ADD

**Normative ASL source:** `asl/scalar/amo/SB.ADD.asl`

SB.ADD atomically applies width-sized modular add and does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SB-ADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sb-add-purpose role=purpose -->
## What SB.ADD is for
`SB.ADD` performs a store-only atomic addition on one byte. It is useful when several agents update a byte-sized counter or flag field and the program needs the update to be indivisible without receiving the replaced value.

<!-- PTO-READER-BLOCK: scalar-sb-add-mechanism role=mechanism -->
## How the update works
The instruction snapshots `SrcL` and `SrcR`, preflights the same address for both read and write access, reads one byte, adds the low 8 bits of the operand, and writes the low 8 bits of the sum back. Arithmetic is modulo 2^8, so overflow wraps. The old byte is used internally but is discarded because this form has no destination.

<!-- PTO-READER-BLOCK: scalar-sb-add-inputs-outputs role=inputs-outputs -->
## Inputs and output
`SrcL` names the atomic address and `SrcR` supplies the operand. Every Reg5 code is assigned: `0` names the architectural zero register, `1`..`23` select the other GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`. The only architectural output is the updated byte in memory; no GPR or temporary queue receives the old value.

<!-- PTO-READER-BLOCK: scalar-sb-add-effects role=effects -->
## Effects and ordering
On success, `SB.ADD` records one atomic memory event and invalidates a local reservation that overlaps the written byte. `rl=0` records relaxed ordering, while `rl=1` records release ordering; there is no acquire form. Successful execution advances `TPC` by four bytes.

<!-- PTO-READER-BLOCK: scalar-sb-add-constraints role=constraints -->
## Constraints and faults
One-byte access needs no stronger alignment than the byte address itself. Read and write probes must both succeed and resolve to the same translated address before the load or store occurs. A probe failure, translation mismatch, invalid temporary-queue source, or undecodable word changes no memory, event, reservation, result, or `TPC`; the instruction then follows the precise fault and restart path.

<!-- PTO-READER-BLOCK: scalar-sb-add-example role=example -->
## Example
```text
sb.add.rl [a0], a1
```
If `a0` names a byte containing `0xff` and the low byte of `a1` is `0x01`, the stored result is `0x00`. The `.rl` suffix changes ordering, not the modular arithmetic, and the prior `0xff` is not returned.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sb.add [SrcL], SrcR
sb.add.rl [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sb_add_32_op5_v0587 | L32 | 32 | 0x8000300b / 0xfc007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sb_add_32_op5_v0587 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sb_add_32_op5_v0587 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sb_add_32_op5_v0587 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sb_add_32_op5_v0587 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sb_add_32_op5_v0587 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sb_add_32_op5_v0587 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SB.ADD.asl -->
```asl
readonly func InstructionContractOperation_SB_ADD() => ScalarOperation
begin
    return ScalarOperation_SB_ADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SB.ADD.asl -->
```asl
readonly func InstructionContractHandler_SB_ADD()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SB_ADD()
    => AtomicOperation
begin
    return Atomic_ADD;
end;

pure func InstructionContractAtomicSizeBytes_SB_ADD()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractPublishesOldValue_SB_ADD()
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
- SB.ADD stores the 8-bit modular sum; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 1-byte little-endian value, compute the 8-bit modular sum, and write one 1-byte result to the same location.
- Complete both read and write access probes before the memory load or store, and require both probes to resolve to the same translated address.
- On success, record one atomic memory event, invalidate an overlapping local reservation, and preserve a nonoverlapping reservation.

### Ordering

- rl=0 records the atomic event with relaxed ordering; rl=1 records it with release ordering. This encoding has no acquire bit.

## Exceptions

- Misalignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- If either read or write preflight fails, the instruction performs no load, store, event, reservation update, result publication, or TPC advance.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- sb.add [a0], a1
- sb.add.rl [t#1], u#1
