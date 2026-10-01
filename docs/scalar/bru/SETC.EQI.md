<!-- GENERATED FROM: asl/scalar/bru/SETC.EQI.asl -->
# SETC.EQI

**Normative ASL source:** `asl/scalar/bru/SETC.EQI.asl`

SETC.EQI - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-EQI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-eqi-purpose role=purpose -->
## What SETC.EQI does

`SETC.EQI` compares a scalar register with a shifted `12`-bit immediate for equality and commits the outcome to the enclosing Conditional block. It is the immediate form of the equality setter and writes no register.

Design point: the immediate is `12` bits wide, so this form is for small constants. A block that must compare against a wider constant uses `HL.SETC.EQI`, which carries `24` immediate bits.

<!-- PTO-READER-BLOCK: scalar-setc-eqi-mechanism role=mechanism -->
## How the equality decision is formed

`SrcL` is read and `simm12` is sign-extended to `PTO_XLEN` and shifted left by `shamt`. The handler tests the two `64`-bit words for equality, committing `1` for equal operands and `0` for different ones.

Design point: the shift applies to the immediate only, never to `SrcL`, and it happens before the comparison, so `shamt` can place a small constant at any bit position up to bit `31` of the expanded value.

Design point: the commit value is canonicalized to `1` or `0` before it is stored, so the bundle decision does not depend on which nonzero operand values produced it.

<!-- PTO-READER-BLOCK: scalar-setc-eqi-inputs-outputs role=inputs-outputs -->
## Operands and result location

- `SrcL` supplies the left operand through the `Reg5` source rules: codes `0` to `23` read absolute GPRs, codes `24` to `27` read the T queue, and codes `28` to `31` read the U queue. A queue code whose entry is not valid rejects the instruction before any read.

- `shamt` is the decoded `5`-bit shift amount applied to the immediate, ranging from `0` to `31`. The canonical assembly `setc.eqi SrcL, simm` has no shift operand, so the amount comes only from the encoding.

- `simm12` supplies the `12`-bit signed immediate.

Design point: there is no destination register field. The comparison decision goes to the block commit state, so a setter cannot be encoded with a discarded, GPR, or queue destination and cannot be confused with a value-producing compare.

Design point: the source is read before any commit state is written, so the setter can compare the register that the block later updates and still use the value from before the update.

<!-- PTO-READER-BLOCK: scalar-setc-eqi-effects role=effects -->
## Commit state and ordering

The canonical `1` or `0` is written to the block commit argument, the block's taken flag receives the same truth value, and the shared condition-set marker is then set. All three writes happen in one handler step.

Design point: the commit argument is written before the taken flag is derived from it, and nothing can fault between the two, so no observable bundle state exists in which they disagree.

Because the handler does not write `TPC`, the dispatch boundary then advances `TPC` by `4` bytes, the encoded length of the `32`-bit form. No register, memory location, or numeric status is written.

<!-- PTO-READER-BLOCK: scalar-setc-eqi-constraints role=constraints -->
## Placement, single-setter rule, and fault order

`SETC.EQI` is applicable only while an active Conditional block has not yet set its condition. The applicability test also names an active body, and the dispatch entry activates the body of an active block immediately before that test, so a body that is not yet active is not a rejection case by itself. A block that is not active, a block whose transfer type is not `Conditional`, or a bundle that has already accepted one condition setter raises `Fault_BundleControl` (trap number `5`, `BUNDLE_TRAP`) before a source is read and before any commit state is written.

Design point: the block keeps one shared condition-set marker, and only a successful occurrence sets it. A `SETC.EQI` rejected by an encoding or operand check leaves the marker clear, so a later condition setter in the same block can still commit. The rejected occurrence consumes nothing.

The fixed bits of the form must match and every selected source code must be usable, otherwise `Fault_IllegalInstruction` is raised with `TPC` unchanged. No field value is reserved.

Design point: entering the bundle body happens before applicability is checked, so a rejected setter leaves the body active. The rejection does not roll that transition back.

<!-- PTO-READER-BLOCK: scalar-setc-eqi-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

With `a0` holding `0x0000000000000005` and `shamt` zero, `setc.eqi a0, 5` commits `1`, and `setc.eqi a0, 6` commits `0`. With `shamt` `4`, the same immediate spelling `1` compares against `16`.

At the end of the block the taken flag selects the continuation: a taken Conditional block continues at the candidate next `PC`, and an untaken one continues sequentially.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.eqi SrcL, simm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_eqi_32_5b2366a4e55d | L32 | 32 | 0x00000075 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_eqi_32_5b2366a4e55d | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_eqi_32_5b2366a4e55d | shamt | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| setc_eqi_32_5b2366a4e55d | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_eqi_32_5b2366a4e55d | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_eqi_32_5b2366a4e55d | shamt | 5 | 0–31 | none | none | shift amount | Encoded zero performs no shift. |
| setc_eqi_32_5b2366a4e55d | simm12 | 12 | 0–4095 | none | none | 12-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 12-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| shamt | shift amount |
| simm12 | 12-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.EQI.asl -->
```asl
readonly func InstructionContractOperation_SETC_EQI() => ScalarOperation
begin
    return ScalarOperation_SETC_EQI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.EQI.asl -->
```asl
readonly func InstructionContractHandler_SETC_EQI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_SETC_EQI()
    => ScalarCondition
begin
    return ScalarCondition_EQ;
end;

pure func InstructionContractCommitResult_SETC_EQI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_SETC_EQI(),
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

- Compute SETC.EQI's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.eqi SrcL, simm
