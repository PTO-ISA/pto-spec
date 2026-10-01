<!-- GENERATED FROM: asl/scalar/bru/SETC.GEUI.asl -->
# SETC.GEUI

**Normative ASL source:** `asl/scalar/bru/SETC.GEUI.asl`

SETC.GEUI - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-GEUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-geui-purpose role=purpose -->
## What SETC.GEUI does

`SETC.GEUI` compares one scalar register against an encoded immediate as unsigned integers and publishes the answer as the commit decision of the Conditional bundle it sits in.

The right operand is built from the instruction word rather than from a register, so a bound known at assembly time needs no register to hold it.

<!-- PTO-READER-BLOCK: scalar-setc-geui-mechanism role=mechanism -->
## Building the right operand from `uimm12` and `shamt`

`uimm12` is zero-extended to the full word width, then logically shifted left by the `shamt` field, which the model reads as the low `6` bits of that encoded field. The shifted word is the value the unsigned relation `UInt(left) >= UInt(right)` tests.

The left operand `SrcL` is read as a complete word and is never shifted.

Design point: the shift makes the immediate field cover values that a plain `12`-bit field cannot reach, while `shamt` fixes the low bits of the comparison value to zero — an immediate is always compared as a multiple of `2` raised to the `shamt` value, so no encoded pair produces an odd value at a nonzero shift.

<!-- PTO-READER-BLOCK: scalar-setc-geui-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` supplies the left absolute GPR source, read as a complete word.
- `shamt` supplies the shift amount applied to the immediate; encoded zero performs no shift.
- `uimm12` supplies the unsigned encoded immediate; encoded zero supplies numeric zero.

`SrcL` is not consumed, and the instruction writes no `GPR`, `T`, or `U` destination.

<!-- PTO-READER-BLOCK: scalar-setc-geui-effects role=effects -->
## Effects and ordering

On success the commit argument receives exactly `1` or `0`, `BARG.TAKEN` follows the same truth value when a bundle is active, and the block condition is marked as set. `TPC` then advances by `4` bytes.

No memory, reservation, descriptor, or numeric-status state changes, and `BARG.BPC`, `BARG.BPCN`, `BARG.BlockType`, and `BARG.TYPE` are preserved.

<!-- PTO-READER-BLOCK: scalar-setc-geui-constraints role=constraints -->
## Block placement, ordering, and faults

Applicability is confined to the body of an active Conditional block, and the shared one-setter marker allows at most one successful `SETC` condition setter per block.

Wrong placement or a repeated successful setter raises `Fault_BundleControl` (trap number `5`, `BUNDLE_TRAP`) before operand legality and before any source read. A fixed-bit mismatch or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before commit state, `BARG`, queue, or `TPC` effects. A rejected occurrence leaves the shared marker unconsumed.

<!-- PTO-READER-BLOCK: scalar-setc-geui-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

Place `128` in GPR1 and execute the form whose encoded fields are `SrcL=1`, `shamt=4`, and `uimm12=8`. The immediate becomes `8` shifted left by `4`, that is `128`, and the unsigned relation `128 >= 128` commits `1`. With GPR1 set to `127` the same form commits `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.geui SrcL, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_geui_32_6c34bc4ad314 | L32 | 32 | 0x00007075 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_geui_32_6c34bc4ad314 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_geui_32_6c34bc4ad314 | shamt | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| setc_geui_32_6c34bc4ad314 | uimm12 | 12 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_geui_32_6c34bc4ad314 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_geui_32_6c34bc4ad314 | shamt | 5 | 0–31 | none | none | shift amount | Encoded zero performs no shift. |
| setc_geui_32_6c34bc4ad314 | uimm12 | 12 | 0–4095 | none | none | 12-bit unsigned immediate | Encoded zero supplies numeric zero for the 12-bit unsigned immediate. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| shamt | shift amount |
| uimm12 | 12-bit unsigned immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.GEUI.asl -->
```asl
readonly func InstructionContractOperation_SETC_GEUI() => ScalarOperation
begin
    return ScalarOperation_SETC_GEUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.GEUI.asl -->
```asl
readonly func InstructionContractHandler_SETC_GEUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_SETC_GEUI()
    => ScalarCondition
begin
    return ScalarCondition_GEU;
end;

pure func InstructionContractCommitResult_SETC_GEUI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_SETC_GEUI(),
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

- Compute SETC.GEUI's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.geui SrcL, uimm
