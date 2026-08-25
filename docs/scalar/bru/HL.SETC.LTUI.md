<!-- GENERATED FROM: asl/scalar/bru/HL.SETC.LTUI.asl -->
# HL.SETC.LTUI

**Normative ASL source:** `asl/scalar/bru/HL.SETC.LTUI.asl`

HL.SETC.LTUI - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-HL-SETC-LTUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-setc-ltui-purpose role=purpose -->
## What HL.SETC.LTUI does

`HL.SETC.LTUI` evaluates unsigned less-than and publishes the result as the current Conditional bundle commit decision.

<!-- PTO-READER-BLOCK: scalar-hl-setc-ltui-mechanism role=mechanism -->
## Mechanism

Placement and the single-setter rule are checked before source readiness or reads.

`uimm24` is zero-extended to XLEN before any shift or comparison.

The decoded immediate is logically shifted left by `shamt` before the condition is evaluated.

The snapshotted operands are evaluated for unsigned less-than and canonicalized to XLEN one or zero.

<!-- PTO-READER-BLOCK: scalar-hl-setc-ltui-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` supplies the left scalar source.

- `shamt` supplies the encoded shift amount.

- `uimm24` supplies an unsigned encoded immediate.

<!-- PTO-READER-BLOCK: scalar-hl-setc-ltui-effects role=effects -->
## Effects and ordering

The canonical condition is written atomically to `_CommitArgument` and `BARG.TAKEN`, and the condition-set marker becomes true.

On success, `HL.SETC.LTUI` advances `TPC` by `6` bytes. It has no scalar destination and no memory or reservation effect.

<!-- PTO-READER-BLOCK: scalar-hl-setc-ltui-constraints role=constraints -->
## Legality and fault order

The instruction is valid only in the applicable Conditional bundle context, and only one successful condition setter may occur.

Wrong placement or a repeated setter raises an Illegal Block Exception before source reads; encoding or unavailable-source failures raise `Fault_IllegalInstruction` before commit or `TPC` effects.

<!-- PTO-READER-BLOCK: scalar-hl-setc-ltui-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

`hl.setc.ltui SrcL, uimm` evaluates the described condition, writes the canonical decision to commit state, and advances `TPC` only after that update.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.setc.ltui SrcL, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_setc_ltui_48_cb7a12ba6ead | HL48 | 48 | 0x00006075000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_setc_ltui_48_cb7a12ba6ead | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_setc_ltui_48_cb7a12ba6ead | shamt | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_setc_ltui_48_cb7a12ba6ead | uimm24 | 24 | unsigned | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_setc_ltui_48_cb7a12ba6ead | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| hl_setc_ltui_48_cb7a12ba6ead | shamt | 5 | 0–31 | none | none | shift amount | Encoded zero performs no shift. |
| hl_setc_ltui_48_cb7a12ba6ead | uimm24 | 24 | 0–16777215 | none | none | 24-bit unsigned immediate | Encoded zero supplies numeric zero for the 24-bit unsigned immediate. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| shamt | shift amount |
| uimm24 | 24-bit unsigned immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.SETC.LTUI.asl -->
```asl
readonly func InstructionContractOperation_HL_SETC_LTUI() => ScalarOperation
begin
    return ScalarOperation_HL_SETC_LTUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.SETC.LTUI.asl -->
```asl
readonly func InstructionContractHandler_HL_SETC_LTUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_HL_SETC_LTUI()
    => ScalarCondition
begin
    return ScalarCondition_LTU;
end;

pure func InstructionContractCommitResult_HL_SETC_LTUI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_HL_SETC_LTUI(),
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- All SETC condition setters share one block-private successful-occurrence marker; a failed first occurrence does not consume it.

## State effects

- Compute HL.SETC.LTUI's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
- Atomically write that value to the commit argument and BARG.TAKEN, then mark the block condition as set. Preserve BARG.BPC, BARG.BPCN, BARG.BlockType, and BARG.TYPE.
- No memory, reservation, descriptor, numeric-status, or destination-register effect occurs. Successful execution advances TPC by the encoded instruction length.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check Conditional-block applicability and the shared occurrence marker before scalar source readiness or reads.
- Snapshot all sources, compute the canonical zero-or-one condition, then atomically update the commit argument, BARG.TAKEN, and the occurrence marker.

## Exceptions

- Wrong block placement or a second successful SETC condition setter raises Illegal Block Exception before scalar source readiness or any architectural or pending-block effect.
- A fixed-bit mismatch or unavailable selected relative source raises Fault_IllegalInstruction before commit state, BARG, queues, or TPC effects.

## Examples

- hl.setc.ltui SrcL, uimm
