<!-- GENERATED FROM: asl/scalar/bru/SETC.EQ.asl -->
# SETC.EQ

**Normative ASL source:** `asl/scalar/bru/SETC.EQ.asl`

SETC.EQ - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-EQ}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-eq-purpose role=purpose -->
## What SETC.EQ does

`SETC.EQ` evaluates equality and publishes the result as the current Conditional bundle commit decision.

<!-- PTO-READER-BLOCK: scalar-setc-eq-mechanism role=mechanism -->
## Mechanism

Placement and the single-setter rule are checked before source readiness or reads.

The snapshotted operands are evaluated for equality and canonicalized to XLEN one or zero.

<!-- PTO-READER-BLOCK: scalar-setc-eq-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` supplies the left scalar source.

- `SrcR` supplies the right scalar source.

- `SrcRType` selects the right-source transformation.

<!-- PTO-READER-BLOCK: scalar-setc-eq-effects role=effects -->
## Effects and ordering

The canonical condition is written atomically to `_CommitArgument` and `BARG.TAKEN`, and the condition-set marker becomes true.

On success, `SETC.EQ` advances `TPC` by `4` bytes. It has no scalar destination and no memory or reservation effect.

<!-- PTO-READER-BLOCK: scalar-setc-eq-constraints role=constraints -->
## Legality and fault order

The instruction is valid only in the applicable Conditional bundle context, and only one successful condition setter may occur.

Wrong placement or a repeated setter raises an Illegal Block Exception before source reads; encoding or unavailable-source failures raise `Fault_IllegalInstruction` before commit or `TPC` effects.

<!-- PTO-READER-BLOCK: scalar-setc-eq-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

`setc.eq SrcL, SrcR<{.sw, .uw}>` evaluates the described condition, writes the canonical decision to commit state, and advances `TPC` only after that update.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.eq SrcL, SrcR<{.sw, .uw}>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_eq_32_fb06e1dddc5c | L32 | 32 | 0x00000065 / 0xf8007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_eq_32_fb06e1dddc5c | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_eq_32_fb06e1dddc5c | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| setc_eq_32_fb06e1dddc5c | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_eq_32_fb06e1dddc5c | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_eq_32_fb06e1dddc5c | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_eq_32_fb06e1dddc5c | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.EQ.asl -->
```asl
readonly func InstructionContractOperation_SETC_EQ() => ScalarOperation
begin
    return ScalarOperation_SETC_EQ;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.EQ.asl -->
```asl
readonly func InstructionContractHandler_SETC_EQ() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_SETC_EQ()
    => ScalarCondition
begin
    return ScalarCondition_EQ;
end;

pure func InstructionContractCommitResult_SETC_EQ(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_SETC_EQ(),
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

- Compute SETC.EQ's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.eq SrcL, SrcR<{.sw, .uw}>
