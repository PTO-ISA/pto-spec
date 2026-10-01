<!-- GENERATED FROM: asl/scalar/bru/SETC.GEU.asl -->
# SETC.GEU

**Normative ASL source:** `asl/scalar/bru/SETC.GEU.asl`

SETC.GEU - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-GEU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-geu-purpose role=purpose -->
## What SETC.GEU does

`SETC.GEU` compares two scalar registers as unsigned integers and publishes the answer as the commit decision of the Conditional bundle it sits in.

The published value is not a general-purpose result: it lands in the commit argument that the block reads when it decides whether to take its conditional transfer, and it also drives `BARG.TAKEN`.

<!-- PTO-READER-BLOCK: scalar-setc-geu-mechanism role=mechanism -->
## How the GEU condition is decided

The instruction has no destination register. It snapshots `SrcL` and the prepared right operand, tests `ConditionHolds(ScalarCondition_GEU, left, right)`, and stores exactly `1` when the relation holds and exactly `0` when it does not.

`ConditionHolds` compares `UInt(left) >= UInt(right)`. Both operands are full `64`-bit words, so a pattern with the top bit set counts as a very large number, not as a negative one.

Design point: the committed value is canonicalized to `1` or `0` instead of being any nonzero value, so the block decision never has to re-inspect a raw comparison residue — one test of the commit argument is enough.

<!-- PTO-READER-BLOCK: scalar-setc-geu-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` supplies the left absolute GPR source.
- `SrcR` supplies the right absolute GPR source.
- `SrcRType` selects the transformation applied to the `SrcR` snapshot before the relation is tested: value `1` substitutes the sign-extended low `32` bits, value `2` the zero-extended low `32` bits, and values `0` and `3` both leave the complete value unchanged.

Encoded zero in `SrcL` or `SrcR` names the architectural zero GPR. Neither source is consumed, and the instruction writes no `GPR`, `T`, or `U` destination.

<!-- PTO-READER-BLOCK: scalar-setc-geu-effects role=effects -->
## Effects and ordering

On success the instruction writes the canonical condition to the commit argument, sets `BARG.TAKEN` to the same truth value when a bundle is active, marks the block condition as set, and only then advances `TPC` by `4` bytes, the encoded length of the `32`-bit form.

It has no memory effect, no reservation effect, and no numeric status flag. `BARG.BPC`, `BARG.BPCN`, `BARG.BlockType`, and `BARG.TYPE` keep their previous values.

Design point: the handler writes the commit argument first and derives `BARG.TAKEN` from that same word, and nothing inside the handler can fault between the two writes, so no observable bundle state shows them disagreeing.

<!-- PTO-READER-BLOCK: scalar-setc-geu-constraints role=constraints -->
## Block placement, ordering, and faults

The operation is applicable only in the body of an active block whose transfer type is Conditional, and only one successful member of the `SETC` condition-setting family may complete in that block.

Wrong placement or a second successful setter raises `Fault_BundleControl` (trap number `5`, `BUNDLE_TRAP`) before any source readiness check or source read. A fixed-bit mismatch or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before commit state, `BARG`, queue, or `TPC` effects. A rejected occurrence does not consume the shared one-setter marker, so a later well-formed setter can still succeed.

<!-- PTO-READER-BLOCK: scalar-setc-geu-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

Place `5` in GPR1 and `5` in GPR2, then execute `setc.geu R1, R2`. The unsigned relation `5 >= 5` holds, so the commit argument and `BARG.TAKEN` become `1`. Set GPR2 to `6` and the same form commits `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.geu SrcL, SrcR<{.sw, .uw}>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_geu_32_494f1f79099e | L32 | 32 | 0x00007065 / 0xf8007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_geu_32_494f1f79099e | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_geu_32_494f1f79099e | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| setc_geu_32_494f1f79099e | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_geu_32_494f1f79099e | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_geu_32_494f1f79099e | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_geu_32_494f1f79099e | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.GEU.asl -->
```asl
readonly func InstructionContractOperation_SETC_GEU() => ScalarOperation
begin
    return ScalarOperation_SETC_GEU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.GEU.asl -->
```asl
readonly func InstructionContractHandler_SETC_GEU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_SETC_GEU()
    => ScalarCondition
begin
    return ScalarCondition_GEU;
end;

pure func InstructionContractCommitResult_SETC_GEU(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_SETC_GEU(),
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

- Compute SETC.GEU's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.geu SrcL, SrcR<{.sw, .uw}>
