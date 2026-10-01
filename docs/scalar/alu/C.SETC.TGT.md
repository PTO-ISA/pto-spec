<!-- GENERATED FROM: asl/scalar/alu/C.SETC.TGT.asl -->
# C.SETC.TGT

**Normative ASL source:** `asl/scalar/alu/C.SETC.TGT.asl`

Snapshot one scalar source value into the active block BARG.BPCN.

## Normative identity {#PTO-INST-SCALAR-C-SETC-TGT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-purpose role=purpose -->
## What C.SETC.TGT does

`C.SETC.TGT` snapshots one Reg5 source value into `BARG.BPCN`, the pending target address of the active block that a later indirect transfer reads before the block retires.

Design point: the target travels through a block-private state slot rather than a register. That lets a condition-setting instruction decide whether the branch is taken and this instruction decide where it goes, without either one having to encode the other's operand.

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-mechanism role=mechanism -->
## How the result is formed

The instruction first checks that a target can be written at all, then reads the source, then stores it.

- The bundle must be active and its type must be `Standard` or `Floating`, and no earlier `C.SETC.TGT` may already have succeeded in this block.
- The complete selected `64`-bit source value is read and written unchanged into `BARG.BPCN`; the selector itself is not retained.
- Only after that store succeeds is the block-private marker that blocks a second occurrence set.

Design point: the target is snapshotted, not referenced. A later write to the source register or a later push onto its queue cannot change the pending target.

Design point: the value is stored exactly as read, with no alignment check and no shift. An odd value is accepted here; it raises `Fault_InstructionPC` only if the block later selects it as an instruction address, where an odd address is rejected.

Design point: this instruction does not touch the generic commit-condition argument that `SETC.*` produces. The taken/not-taken decision and the destination address are separate pieces of block state.

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is the only encoded operand: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`, without consuming a queue entry.
- The destination is implicit: the active block's `BARG.BPCN`. No register is written.

Design point: encoded zero reads the architectural zero GPR, so `c.setc.tgt zero` installs the target `0`. There is no omitted operand and no discard form; whether the instruction is allowed at all is decided by the block, not by a field.

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-effects role=effects -->
## Effects and ordering

Applicability and the duplicate check run before the source is read, and the source read runs before the target update. A fault at any of those points leaves `BARG.BPCN` and the uniqueness marker unchanged.

On success, `BARG.BPCN` and the uniqueness marker change, and then `TPC` advances by `2` bytes. No GPR, queue entry, memory, reservation, descriptor, numeric-status, privilege, predicate or control-flow state changes.

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-constraints role=constraints -->
## Legality and fault boundary

Applicability is tested first. `Fault_BundleControl` is raised at `TPC`, before the source is read and before any state is written, when no `Standard` or `Floating` block is active, when one `C.SETC.TGT` has already succeeded in this block, or while a system-block close request is pending.

An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before `BARG.BPCN`, the uniqueness marker, `TPC` or queue state change. If nothing faults, `TPC` advances by `2` bytes.

Design point: the same two applicability conditions are tested twice, once before the source is read and once inside the target update. The outer test is what makes a duplicate occurrence fault without reading a source; the inner test keeps the update itself conditional on the same rule.

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

Inside an active `Standard` block, `c.setc.tgt a0` with `a0=4096` installs the pending target `4096` and advances `TPC` by `2` bytes. A second `c.setc.tgt` in the same block raises `Fault_BundleControl` even if its source is readable. With `a0=4097` the instruction succeeds and stores the odd value; the fault, if any, comes later, when that value is selected as an instruction address.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.setc.tgt srcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_setc_tgt_16_736be9cada01 | C16 | 16 | 0x001c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_setc_tgt_16_736be9cada01 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_setc_tgt_16_736be9cada01 | SrcL | 5 | 0–31 | none | none | common scalar source: absolute GPR, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | common scalar source: absolute GPR, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SETC.TGT.asl -->
```asl
readonly func InstructionContractOperation_C_SETC_TGT() => ScalarOperation
begin
    return ScalarOperation_C_SETC_TGT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable inside one active Standard or Floating block. The first successful occurrence owns the block target; a second occurrence is illegal.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SETC.TGT.asl -->
```asl
readonly func InstructionContractHandler_C_SETC_TGT() => ScalarSemanticHandler
begin
    return ScalarHandler_SetCommitTarget;
end;

readonly func InstructionContractTarget_C_SETC_TGT(
    source_value: Word)
    => Word
begin
    return source_value;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- C.SETC.TGT has no omitted operand. SrcL code zero names the architectural zero GPR and snapshots numeric zero.

## Legality

- All SrcL codes 0..31 are assigned common scalar sources; relative sources are non-consuming and must be available when the instruction executes.
- C.SETC.TGT is legal only while a Standard or Floating block is active. At most one C.SETC.TGT may complete successfully in that block.
- Target alignment is not checked by C.SETC.TGT; the block commit boundary validates the final selected BARG.BPCN.

## State effects

- Read and snapshot the complete selected 64-bit source, then atomically replace active BARG.BPCN with that value.
- Set the block-private successful-C.SETC.TGT marker only after the target snapshot succeeds. Do not retain the selector and do not modify the generic commit-condition argument.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Applicability and duplicate checks precede source readiness and source read. Source readiness precedes the BARG.BPCN update.
- Later changes to the source register or queue cannot alter the pending target.

## Exceptions

- No active Standard or Floating block, or a second successful C.SETC.TGT in the active block, raises Fault_BundleControl before source readiness or any state effect.
- An unavailable relative source raises Fault_IllegalInstruction before changing BARG.BPCN, the uniqueness marker, TPC, or queue state.
- An odd snapshotted target is accepted by C.SETC.TGT and raises Fault_InstructionPC only if the later block commit selects it.

## Examples

- c.setc.tgt a0
- c.setc.tgt T#1
