<!-- GENERATED FROM: asl/scalar/bru/SETC.LTUI.asl -->
# SETC.LTUI

**Normative ASL source:** `asl/scalar/bru/SETC.LTUI.asl`

SETC.LTUI - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-LTUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-ltui-purpose role=purpose -->
## What SETC.LTUI does

`SETC.LTUI` compares one scalar register against an encoded unsigned immediate and publishes the answer as the commit decision of the Conditional bundle it sits in.

Both sides are treated as unsigned, which is what a range or capacity check against a constant needs.

<!-- PTO-READER-BLOCK: scalar-setc-ltui-mechanism role=mechanism -->
## Why the compared bound is always scaled

`uimm12` is zero-extended to the full word width, then logically shifted left by `shamt`, read as the low `6` bits of that encoded field. The relation `UInt(left) < UInt(right)` is tested against the shifted value, so the comparison value is always a multiple of `2` raised to the `shamt` value.

The left operand is read as a complete word and is never shifted.

Design point: zero extension plus a logical shift keeps the immediate non-negative for every encoding, so a limit check written against this mnemonic cannot reject a bound because of a sign bit.

<!-- PTO-READER-BLOCK: scalar-setc-ltui-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` supplies the left absolute GPR source, read as a complete word.
- `shamt` supplies the shift amount applied to the immediate; encoded zero performs no shift.
- `uimm12` supplies the unsigned encoded immediate; encoded zero supplies numeric zero.

`SrcL` is not consumed and no `GPR`, `T`, or `U` destination is written.

<!-- PTO-READER-BLOCK: scalar-setc-ltui-effects role=effects -->
## Effects and ordering

On success the commit argument receives exactly `1` or `0`, `BARG.TAKEN` takes the same truth value while a bundle is active, the block condition marker becomes set, and `TPC` advances by `4` bytes.

No memory, reservation, descriptor, or numeric-status state changes, and `BARG.BPC`, `BARG.BPCN`, `BARG.BlockType`, and `BARG.TYPE` are preserved.

<!-- PTO-READER-BLOCK: scalar-setc-ltui-constraints role=constraints -->
## What the setter marker and placement check reject

The operation is applicable only in the body of an active Conditional block, and the shared marker allows at most one successful `SETC` condition setter in that block.

Wrong placement or a repeated successful setter raises `Fault_BundleControl` (trap number `5`, `BUNDLE_TRAP`) before operand legality and before any source read. A fixed-bit mismatch or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before commit state, `BARG`, queue, or `TPC` effects. A rejected occurrence leaves the shared marker unconsumed.

<!-- PTO-READER-BLOCK: scalar-setc-ltui-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

Place `255` in GPR1 and execute the form whose encoded fields are `SrcL=1`, `shamt=0`, and `uimm12=256`. The immediate is compared unscaled, and unsigned `255 < 256` holds, so the form commits `1`. With GPR1 set to `256` the same form commits `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.ltui SrcL, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_ltui_32_7908d25901c6 | L32 | 32 | 0x00006075 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_ltui_32_7908d25901c6 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_ltui_32_7908d25901c6 | shamt | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| setc_ltui_32_7908d25901c6 | uimm12 | 12 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_ltui_32_7908d25901c6 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_ltui_32_7908d25901c6 | shamt | 5 | 0–31 | none | none | shift amount | Encoded zero performs no shift. |
| setc_ltui_32_7908d25901c6 | uimm12 | 12 | 0–4095 | none | none | 12-bit unsigned immediate | Encoded zero supplies numeric zero for the 12-bit unsigned immediate. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| shamt | shift amount |
| uimm12 | 12-bit unsigned immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.LTUI.asl -->
```asl
readonly func InstructionContractOperation_SETC_LTUI() => ScalarOperation
begin
    return ScalarOperation_SETC_LTUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.LTUI.asl -->
```asl
readonly func InstructionContractHandler_SETC_LTUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_SETC_LTUI()
    => ScalarCondition
begin
    return ScalarCondition_LTU;
end;

pure func InstructionContractCommitResult_SETC_LTUI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_SETC_LTUI(),
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

- Compute SETC.LTUI's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.ltui SrcL, uimm
