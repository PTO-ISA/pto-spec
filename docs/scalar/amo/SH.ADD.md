<!-- GENERATED FROM: asl/scalar/amo/SH.ADD.asl -->
# SH.ADD

**Normative ASL source:** `asl/scalar/amo/SH.ADD.asl`

SH.ADD atomically applies width-sized modular add and does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SH-ADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sh-add-purpose role=purpose -->
## What SH.ADD is for
`SH.ADD` performs a store-only atomic addition on one aligned halfword. It provides an indivisible 16-bit update when the program needs the new memory value but does not need the replaced value returned.

<!-- PTO-READER-BLOCK: scalar-sh-add-mechanism role=mechanism -->
## How the update works
The instruction snapshots `SrcL` and `SrcR`, completes read and write preflight, reads two little-endian bytes, adds the low 16 bits of the operand, and writes the low 16 bits of the sum back. Arithmetic is modulo 2^16. The internally read old halfword is discarded because the form has no destination.

<!-- PTO-READER-BLOCK: scalar-sh-add-inputs-outputs role=inputs-outputs -->
## Inputs and output
`SrcL` supplies the address and `SrcR` supplies the addend. Reg5 code `0` names the architectural zero register, `1`..`23` name the other GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. The only output is the updated two-byte memory value; the old value reaches neither a GPR nor a temporary queue.

<!-- PTO-READER-BLOCK: scalar-sh-add-effects role=effects -->
## Effects and ordering
On success, `SH.ADD` records one atomic event, invalidates an overlapping local reservation, and advances `TPC` by four bytes. `rl=0` selects relaxed ordering and `rl=1` selects release ordering. The instruction has no acquire or acquire-release spelling.

<!-- PTO-READER-BLOCK: scalar-sh-add-constraints role=constraints -->
## Constraints and faults
The address must be aligned to two bytes. Alignment is checked before translation or permission, and both probes must resolve to the same translated address. Any failure occurs before the load or store and leaves memory, memory events, reservations, registers, queues, and `TPC` unchanged for precise restart.

<!-- PTO-READER-BLOCK: scalar-sh-add-example role=example -->
## Example
```text
sh.add.rl [a0], a1
```
If the aligned halfword is `0xffff` and the low 16 bits of `a1` are `0x0001`, the stored result wraps to `0x0000`. The `.rl` suffix records release ordering and does not return `0xffff`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sh.add [SrcL], SrcR
sh.add.rl [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sh_add_32_op5_v0587 | L32 | 32 | 0x8000500b / 0xfc007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sh_add_32_op5_v0587 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sh_add_32_op5_v0587 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sh_add_32_op5_v0587 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sh_add_32_op5_v0587 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sh_add_32_op5_v0587 | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sh_add_32_op5_v0587 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SH.ADD.asl -->
```asl
readonly func InstructionContractOperation_SH_ADD() => ScalarOperation
begin
    return ScalarOperation_SH_ADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SH.ADD.asl -->
```asl
readonly func InstructionContractHandler_SH_ADD()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SH_ADD()
    => AtomicOperation
begin
    return Atomic_ADD;
end;

pure func InstructionContractAtomicSizeBytes_SH_ADD()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractPublishesOldValue_SH_ADD()
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
- SH.ADD stores the 16-bit modular sum; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 2-byte little-endian value, compute the 16-bit modular sum, and write one 2-byte result to the same location.
- Complete both read and write access probes before the memory load or store, and require both probes to resolve to the same translated address.
- On success, record one atomic memory event, invalidate an overlapping local reservation, and preserve a nonoverlapping reservation.

### Ordering

- rl=0 records the atomic event with relaxed ordering; rl=1 records it with release ordering. This encoding has no acquire bit.

## Exceptions

- Misalignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- If either read or write preflight fails, the instruction performs no load, store, event, reservation update, result publication, or TPC advance.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- sh.add [a0], a1
- sh.add.rl [t#1], u#1
