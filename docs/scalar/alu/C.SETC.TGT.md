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

`C.SETC.TGT` is a 16-bit scalar ALU instruction. It captures the selected scalar value as the active block commit target; its current instruction contract defines the result publication path and any additional state effect.

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-mechanism role=mechanism -->
## How the result is formed

Execution snapshots the encoded inputs, then captures the selected scalar value as the active block commit target, and only afterward performs the destination effects.

- The operation-specific width, signedness, and immediate rules are fixed by the mnemonic and the encoded fields shown below.
- Result publication uses the width and extension rule fixed by this mnemonic's current contract.

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-inputs role=inputs-outputs -->
## Inputs and destinations

- The 5-bit `SrcL` field selects an absolute GPR, T#1..T#4, or U#1..U#4 scalar value.

These roles come from the current instruction contract. T/U sources are read and snapshotted without being removed from their queues; exact encoded-zero meanings appear in the generated defaults below.

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-effects role=effects -->
## Effects and ordering

The selected source is captured before `BARG.BPCN` changes, so source aliasing cannot observe the new commit target.

This ALU operation has no memory effect. After its successful architectural effects, `TPC` advances by 2 bytes.

The operation does not introduce a hidden scalar publication target or an implicit memory access. Architectural changes remain limited to the state effects enumerated by the current contract.

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-constraints role=constraints -->
## Legality and fault boundary

The instruction is legal only in an active Standard or Floating block and may complete successfully at most once in that block. Target alignment is deferred to the block-commit boundary.

The generated legality table is authoritative for assigned field values, reserved encodings, and destination discard codes. Decode and source availability are checked before architectural effects.

<!-- PTO-READER-BLOCK: scalar-c-setc-tgt-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `C.SETC.TGT` example, a snapshotted source value `0x100` becomes the active `BARG.BPCN`; target alignment is still checked later at block commit.
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
