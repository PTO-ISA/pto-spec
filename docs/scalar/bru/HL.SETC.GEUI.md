<!-- GENERATED FROM: asl/scalar/bru/HL.SETC.GEUI.asl -->
# HL.SETC.GEUI

**Normative ASL source:** `asl/scalar/bru/HL.SETC.GEUI.asl`

HL.SETC.GEUI - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-HL-SETC-GEUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-setc-geui-purpose role=purpose -->
## What HL.SETC.GEUI does

`HL.SETC.GEUI` compares a scalar register with a shifted `24`-bit unsigned immediate using unsigned greater-than-or-equal and commits the outcome to the enclosing Conditional block. The signed counterpart is `HL.SETC.GEI`.

Design point: the relation includes equality and both sides are unsigned, so `hl.setc.geui a0, bound` and `hl.setc.ltui a0, bound` commit opposite values for every operand pair without any signed interpretation.

<!-- PTO-READER-BLOCK: scalar-hl-setc-geui-mechanism role=mechanism -->
## How the unsigned greater-or-equal decision is formed

`SrcL` is read and `uimm24` is zero-extended to `PTO_XLEN` and shifted left by `shamt`. The handler evaluates unsigned greater-than-or-equal, committing `1` when the relation holds and `0` otherwise.

Design point: every unsigned value is at least `0`, so `hl.setc.geui a0, 0` commits `1` for every `a0`, including `0` itself.

Design point: the commit value is canonicalized to `1` or `0` before it is stored, so the bundle decision is the same whichever non-zero operand values produced it.

<!-- PTO-READER-BLOCK: scalar-hl-setc-geui-inputs-outputs role=inputs-outputs -->
## Operands and the shift field

- `SrcL` supplies the left operand through the `Reg5` source rules: codes `0` to `23` read absolute GPRs, codes `24` to `27` read the T queue, and codes `28` to `31` read the U queue. A queue code whose entry is not valid rejects the instruction before any read.

- `shamt` is the decoded `5`-bit shift amount applied to the immediate. It occupies the bits that the compare forms use for a destination, because a condition setter writes no register. The value ranges from `0` to `31`.

- `uimm24` supplies the `24`-bit unsigned bound, encoded in two pieces of `12` bits and `12` bits.

Design point: there is no destination register field. The result of the comparison goes to the block commit state, so a setter cannot be encoded with a discarded, GPR, or queue destination and cannot be mistaken for a value-producing compare.

<!-- PTO-READER-BLOCK: scalar-hl-setc-geui-effects role=effects -->
## Commit state and ordering

The canonical `1` or `0` is written to the block commit argument, the block's taken flag receives the same truth value, and the shared condition-set marker is then set. All three writes happen in one handler step.

Design point: the commit argument is written before the taken flag is derived from it, and nothing can fault between the two, so no observable bundle state exists in which they disagree.

Because the handler does not write `TPC`, the dispatch boundary then advances `TPC` by `6` bytes, the encoded length of the `48`-bit form. No register, memory location, or numeric status is written.

<!-- PTO-READER-BLOCK: scalar-hl-setc-geui-constraints role=constraints -->
## Placement, single-setter rule, and fault order

`HL.SETC.GEUI` is applicable only while an active Conditional block has not yet set its condition. The applicability test also names an active body, and the dispatch entry activates the body of an active block immediately before that test, so a body that is not yet active is not a rejection case by itself. A block that is not active, a block whose transfer type is not `Conditional`, or a bundle that has already accepted one condition setter raises `Fault_BundleControl` (trap number `5`, `BUNDLE_TRAP`) before a source is read and before any commit state is written.

Design point: the block keeps one shared condition-set marker, and only a successful occurrence sets it. A `HL.SETC.GEUI` rejected by an encoding or operand check leaves the marker clear, so a later condition setter in the same block can still commit. The rejected occurrence consumes nothing.

The fixed bits of the form must match and the selected `SrcL` code must be usable, otherwise `Fault_IllegalInstruction` is raised with `TPC` unchanged. No field value is reserved: all `32` `SrcL` codes, all `32` `shamt` values, and all values of the `24`-bit immediate field are assigned.

Design point: entering the bundle body happens before applicability is checked, so a rejected setter leaves the body active. The rejection does not roll that transition back.

<!-- PTO-READER-BLOCK: scalar-hl-setc-geui-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

With `a0` holding `0xFFFFFFFFFFFFFFFF` and `shamt` zero, `hl.setc.geui a0, 0` commits `1`. With `a0` holding `0`, `hl.setc.geui a0, 1` commits `0`.

At the end of the block the taken flag selects the continuation: a taken Conditional block continues at the candidate next `PC`, and an untaken one continues sequentially.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.setc.geui SrcL, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_setc_geui_48_2390319baf54 | HL48 | 48 | 0x00007075000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_setc_geui_48_2390319baf54 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_setc_geui_48_2390319baf54 | shamt | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_setc_geui_48_2390319baf54 | uimm24 | 24 | unsigned | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_setc_geui_48_2390319baf54 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| hl_setc_geui_48_2390319baf54 | shamt | 5 | 0–31 | none | none | shift amount | Encoded zero performs no shift. |
| hl_setc_geui_48_2390319baf54 | uimm24 | 24 | 0–16777215 | none | none | 24-bit unsigned immediate | Encoded zero supplies numeric zero for the 24-bit unsigned immediate. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| shamt | shift amount |
| uimm24 | 24-bit unsigned immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.SETC.GEUI.asl -->
```asl
readonly func InstructionContractOperation_HL_SETC_GEUI() => ScalarOperation
begin
    return ScalarOperation_HL_SETC_GEUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.SETC.GEUI.asl -->
```asl
readonly func InstructionContractHandler_HL_SETC_GEUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_HL_SETC_GEUI()
    => ScalarCondition
begin
    return ScalarCondition_GEU;
end;

pure func InstructionContractCommitResult_HL_SETC_GEUI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_HL_SETC_GEUI(),
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

- Compute HL.SETC.GEUI's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- hl.setc.geui SrcL, uimm
