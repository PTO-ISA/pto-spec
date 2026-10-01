<!-- GENERATED FROM: asl/scalar/bru/SETC.NE.asl -->
# SETC.NE

**Normative ASL source:** `asl/scalar/bru/SETC.NE.asl`

SETC.NE - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-NE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-ne-purpose role=purpose -->
## What SETC.NE does

`SETC.NE` compares two scalar registers for inequality and publishes the answer as the commit decision of the Conditional bundle it sits in.

The published value is the block's commit argument, which the block reads for its conditional transfer, and it also drives `BARG.TAKEN`.

<!-- PTO-READER-BLOCK: scalar-setc-ne-mechanism role=mechanism -->
## Inequality of two prepared snapshots

The instruction writes no destination register. It snapshots `SrcL` and the prepared right operand, tests `ConditionHolds(ScalarCondition_NE, left, right)`, and stores exactly `1` when the relation holds and exactly `0` when it does not.

`ConditionHolds` compares the complete words for inequality, so the result depends only on whether the two snapshots differ, not on the numeric size of either one.

Design point: the setter forms pass the `11` modifier through unchanged, so `SETC.NE` cannot complement the right source; an inequality test against the complement of a stored mask needs a separate instruction to build that complement.

<!-- PTO-READER-BLOCK: scalar-setc-ne-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` supplies the left absolute GPR source.
- `SrcR` supplies the right absolute GPR source.
- `SrcRType` transforms the `SrcR` snapshot before the test: value `1` substitutes the sign-extended low `32` bits, value `2` the zero-extended low `32` bits, and values `0` and `3` leave the complete word unchanged.

Encoded zero in `SrcL` or `SrcR` names the architectural zero GPR. Sources are not consumed, and the instruction writes no `GPR`, `T`, or `U` destination.

<!-- PTO-READER-BLOCK: scalar-setc-ne-effects role=effects -->
## Effects and ordering

On success the commit argument receives the canonical condition, `BARG.TAKEN` mirrors that truth value while a bundle is active, the block condition marker becomes set, and `TPC` advances by `4` bytes.

No memory, reservation, descriptor, or numeric-status effect occurs, and `BARG.BPC`, `BARG.BPCN`, `BARG.BlockType`, and `BARG.TYPE` keep their values.

<!-- PTO-READER-BLOCK: scalar-setc-ne-constraints role=constraints -->
## Fault classes and their order

Applicability is confined to the body of an active Conditional block, and the shared marker allows at most one successful `SETC` condition setter in that block.

Wrong placement or a second successful setter raises `Fault_BundleControl` (trap number `5`, `BUNDLE_TRAP`) before operand legality and before any source read. A fixed-bit mismatch or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before commit state, `BARG`, queue, or `TPC` effects. A failed first occurrence does not consume the shared marker.

<!-- PTO-READER-BLOCK: scalar-setc-ne-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

Place `7` in both GPR1 and GPR2, then execute `setc.ne R1, R2`. The words are equal, so the form commits `0`. Set GPR2 to `8` and the same form commits `1`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.ne SrcL, SrcR<{.sw, .uw}>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_ne_32_77576a5c690c | L32 | 32 | 0x00001065 / 0xf8007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_ne_32_77576a5c690c | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_ne_32_77576a5c690c | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| setc_ne_32_77576a5c690c | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_ne_32_77576a5c690c | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_ne_32_77576a5c690c | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_ne_32_77576a5c690c | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.NE.asl -->
```asl
readonly func InstructionContractOperation_SETC_NE() => ScalarOperation
begin
    return ScalarOperation_SETC_NE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.NE.asl -->
```asl
readonly func InstructionContractHandler_SETC_NE() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_SETC_NE()
    => ScalarCondition
begin
    return ScalarCondition_NE;
end;

pure func InstructionContractCommitResult_SETC_NE(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_SETC_NE(),
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

- Compute SETC.NE's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.ne SrcL, SrcR<{.sw, .uw}>
