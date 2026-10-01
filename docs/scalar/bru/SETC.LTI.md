<!-- GENERATED FROM: asl/scalar/bru/SETC.LTI.asl -->
# SETC.LTI

**Normative ASL source:** `asl/scalar/bru/SETC.LTI.asl`

SETC.LTI - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-LTI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-lti-purpose role=purpose -->
## What SETC.LTI does

`SETC.LTI` compares one scalar register against an encoded immediate as signed integers and publishes the answer as the commit decision of the Conditional bundle it sits in.

The bound lives in the instruction word, so no register is spent holding it.

<!-- PTO-READER-BLOCK: scalar-setc-lti-mechanism role=mechanism -->
## Sign extension before the immediate shift

Because the field is signed, the model sign-extends `simm12` to the full word width before the shift. The sign-extended word is then logically shifted left by `shamt`, read as the low `6` bits of that encoded field, and the relation `SInt(left) < SInt(right)` is tested against the shifted value.

`SrcL` is read as a complete word and is never shifted, so the left side of the relation is always the complete register value even when the immediate side is scaled. Encoded zero in `SrcL` names the architectural zero GPR, which cannot be written away by this instruction.

Design point: sign extension happens before the shift, so a negative immediate stays negative after scaling instead of turning into a large positive value.

<!-- PTO-READER-BLOCK: scalar-setc-lti-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` supplies the left absolute GPR source, read as a complete word.
- `shamt` supplies the shift amount applied to the immediate; encoded zero performs no shift.
- `simm12` supplies the signed encoded immediate; encoded zero supplies numeric zero.

`SrcL` is not consumed and no `GPR`, `T`, or `U` destination is written.

<!-- PTO-READER-BLOCK: scalar-setc-lti-effects role=effects -->
## Effects and ordering

On success the commit argument holds exactly `1` or `0`, `BARG.TAKEN` mirrors that truth value while a bundle is active, the block condition marker becomes set, and `TPC` advances by `4` bytes.

No memory, reservation, descriptor, or numeric-status state changes, and `BARG.BPC`, `BARG.BPCN`, `BARG.BlockType`, and `BARG.TYPE` are preserved.

<!-- PTO-READER-BLOCK: scalar-setc-lti-constraints role=constraints -->
## Legality, placement, and fault order

The operation is applicable only in the body of an active Conditional block, and at most one successful `SETC` condition setter may complete there.

Wrong placement or a repeated successful setter raises `Fault_BundleControl` (trap number `5`, `BUNDLE_TRAP`) before operand legality and before any read of `SrcL`. A fixed-bit mismatch or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before commit state, `BARG`, queue, or `TPC` effects. A rejected occurrence leaves the shared marker unconsumed.

<!-- PTO-READER-BLOCK: scalar-setc-lti-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

Place `-16` in GPR1 and execute the form whose encoded fields are `SrcL=1`, `shamt=2`, and `simm12=-4`. The sign-extended immediate `-4` scaled by `4` is `-16`, and the signed relation `-16 < -16` is false, so the form commits `0`. With GPR1 set to `-17` the same form commits `1`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.lti SrcL, simm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_lti_32_89d74d948b74 | L32 | 32 | 0x00004075 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_lti_32_89d74d948b74 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_lti_32_89d74d948b74 | shamt | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| setc_lti_32_89d74d948b74 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_lti_32_89d74d948b74 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_lti_32_89d74d948b74 | shamt | 5 | 0–31 | none | none | shift amount | Encoded zero performs no shift. |
| setc_lti_32_89d74d948b74 | simm12 | 12 | 0–4095 | none | none | 12-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 12-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| shamt | shift amount |
| simm12 | 12-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.LTI.asl -->
```asl
readonly func InstructionContractOperation_SETC_LTI() => ScalarOperation
begin
    return ScalarOperation_SETC_LTI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.LTI.asl -->
```asl
readonly func InstructionContractHandler_SETC_LTI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_SETC_LTI()
    => ScalarCondition
begin
    return ScalarCondition_LT;
end;

pure func InstructionContractCommitResult_SETC_LTI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_SETC_LTI(),
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

- Compute SETC.LTI's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.lti SrcL, simm
