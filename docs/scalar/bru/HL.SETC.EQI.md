<!-- GENERATED FROM: asl/scalar/bru/HL.SETC.EQI.asl -->
# HL.SETC.EQI

**Normative ASL source:** `asl/scalar/bru/HL.SETC.EQI.asl`

HL.SETC.EQI - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-HL-SETC-EQI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-setc-eqi-purpose role=purpose -->
## What HL.SETC.EQI does

`HL.SETC.EQI` compares a scalar register with a shifted `24`-bit immediate for equality and commits the outcome to the enclosing Conditional block. It is the wide-immediate equality setter: `24` immediate bits where `SETC.EQI` has `12`.

Design point: the setter commits on the extended `64`-bit word, so `hl.setc.eqi a0, -1` commits `1` only when every bit of `a0` is set. The same immediate compared under a zero-extended reading would test a different pattern.

<!-- PTO-READER-BLOCK: scalar-hl-setc-eqi-mechanism role=mechanism -->
## How the equality decision is formed

`SrcL` is read and `simm24` is sign-extended to `PTO_XLEN` and shifted left by `shamt`. The two `64`-bit words are tested for equality, and equal operands commit `1` while different operands commit `0`.

Design point: the source is read before any commit state is written, so a setter may name the register that the block itself is about to update and still compare against the value from before the update.

Design point: the commit value is canonicalized to `1` or `0` before it is stored, so the bundle decision is the same whichever non-zero operand values produced it.

<!-- PTO-READER-BLOCK: scalar-hl-setc-eqi-inputs-outputs role=inputs-outputs -->
## Operands and the shift field

- `SrcL` supplies the left operand through the `Reg5` source rules: codes `0` to `23` read absolute GPRs, codes `24` to `27` read the T queue, and codes `28` to `31` read the U queue. A queue code whose entry is not valid rejects the instruction before any read.

- `shamt` is the decoded `5`-bit shift amount applied to the immediate. It occupies the bits that the compare forms use for a destination, because a condition setter writes no register. The value ranges from `0` to `31`.

- `simm24` supplies the `24`-bit signed immediate, encoded in two pieces of `12` bits and `12` bits.

Design point: there is no destination register field. The result of the comparison goes to the block commit state, so a setter cannot be encoded with a discarded, GPR, or queue destination and cannot be mistaken for a value-producing compare.

<!-- PTO-READER-BLOCK: scalar-hl-setc-eqi-effects role=effects -->
## Commit state and ordering

The canonical `1` or `0` is written to the block commit argument, the block's taken flag receives the same truth value, and the shared condition-set marker is then set. All three writes happen in one handler step.

Design point: the commit argument is written before the taken flag is derived from it, and nothing can fault between the two, so no observable bundle state exists in which they disagree.

Because the handler does not write `TPC`, the dispatch boundary then advances `TPC` by `6` bytes, the encoded length of the `48`-bit form. No register, memory location, or numeric status is written.

<!-- PTO-READER-BLOCK: scalar-hl-setc-eqi-constraints role=constraints -->
## Placement, single-setter rule, and fault order

`HL.SETC.EQI` is applicable only while an active Conditional block has not yet set its condition. The applicability test also names an active body, and the dispatch entry activates the body of an active block immediately before that test, so a body that is not yet active is not a rejection case by itself. A block that is not active, a block whose transfer type is not `Conditional`, or a bundle that has already accepted one condition setter raises `Fault_BundleControl` (trap number `5`, `BUNDLE_TRAP`) before a source is read and before any commit state is written.

Design point: the block keeps one shared condition-set marker, and only a successful occurrence sets it. A `HL.SETC.EQI` rejected by an encoding or operand check leaves the marker clear, so a later condition setter in the same block can still commit. The rejected occurrence consumes nothing.

The fixed bits of the form must match and the selected `SrcL` code must be usable, otherwise `Fault_IllegalInstruction` is raised with `TPC` unchanged. No field value is reserved: all `32` `SrcL` codes, all `32` `shamt` values, and all values of the `24`-bit immediate field are assigned.

Design point: entering the bundle body happens before applicability is checked, so a rejected setter leaves the body active. The rejection does not roll that transition back.

<!-- PTO-READER-BLOCK: scalar-hl-setc-eqi-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

With `a0` holding `0x0000000000000005` and `shamt` zero, `hl.setc.eqi a0, 5` writes `1` to the commit argument and marks the block taken; `hl.setc.eqi a0, 6` writes `0` and marks it not taken.

At the end of the block the taken flag selects the continuation: a taken Conditional block continues at the candidate next `PC`, and an untaken one continues sequentially.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.setc.eqi SrcL, simm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_setc_eqi_48_0fe891fb0890 | HL48 | 48 | 0x00000075000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_setc_eqi_48_0fe891fb0890 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_setc_eqi_48_0fe891fb0890 | shamt | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_setc_eqi_48_0fe891fb0890 | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_setc_eqi_48_0fe891fb0890 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| hl_setc_eqi_48_0fe891fb0890 | shamt | 5 | 0–31 | none | none | shift amount | Encoded zero performs no shift. |
| hl_setc_eqi_48_0fe891fb0890 | simm24 | 24 | 0–16777215 | none | none | 24-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 24-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| shamt | shift amount |
| simm24 | 24-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.SETC.EQI.asl -->
```asl
readonly func InstructionContractOperation_HL_SETC_EQI() => ScalarOperation
begin
    return ScalarOperation_HL_SETC_EQI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.SETC.EQI.asl -->
```asl
readonly func InstructionContractHandler_HL_SETC_EQI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_HL_SETC_EQI()
    => ScalarCondition
begin
    return ScalarCondition_EQ;
end;

pure func InstructionContractCommitResult_HL_SETC_EQI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_HL_SETC_EQI(),
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

- Compute HL.SETC.EQI's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- hl.setc.eqi SrcL, simm
