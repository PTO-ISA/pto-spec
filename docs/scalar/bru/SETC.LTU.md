<!-- GENERATED FROM: asl/scalar/bru/SETC.LTU.asl -->
# SETC.LTU

**Normative ASL source:** `asl/scalar/bru/SETC.LTU.asl`

SETC.LTU - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-LTU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-ltu-purpose role=purpose -->
## What SETC.LTU does

`SETC.LTU` compares two scalar registers as unsigned integers and publishes the answer as the commit decision of the Conditional bundle it sits in.

The unsigned reading is what makes the instruction useful for address-like and length-like values, where the top bit is a magnitude bit rather than a sign.

<!-- PTO-READER-BLOCK: scalar-setc-ltu-mechanism role=mechanism -->
## Unsigned less-than under the same setter path

The instruction holds no destination register. It snapshots `SrcL` and the prepared right operand, tests `ConditionHolds(ScalarCondition_LTU, left, right)`, and stores exactly `1` when the relation holds and exactly `0` when it does not.

`ConditionHolds` compares `UInt(left) < UInt(right)`, so no word is ever negative and the all-ones pattern is the largest value rather than `-1`.

Design point: `SrcRType` values `0` and `3` both leave the complete `64`-bit word untouched, while the `.sw` and `.uw` encodings replace the right operand with an extension of its low `32` bits. The modifier changes the operand, not the relation: `SETC.LTU` stays unsigned under every encoding.

<!-- PTO-READER-BLOCK: scalar-setc-ltu-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` is a Reg5 source: codes `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`.
- `SrcR` uses the same Reg5 mapping.
- `SrcRType` transforms the `SrcR` snapshot before the relation is tested: value `1` substitutes the sign-extended low `32` bits, value `2` the zero-extended low `32` bits, and values `0` and `3` leave the complete word unchanged.

Encoded zero in `SrcL` or `SrcR` names the architectural zero GPR. Neither source is consumed and no `GPR`, `T`, or `U` destination is written.

<!-- PTO-READER-BLOCK: scalar-setc-ltu-effects role=effects -->
## Effects and ordering

On success the canonical condition is written to the commit argument, `BARG.TAKEN` follows the same truth value while a bundle is active, the block condition marker becomes set, and `TPC` advances by `4` bytes.

There is no memory, reservation, descriptor, or numeric-status effect, and `BARG.BPC`, `BARG.BPCN`, `BARG.BlockType`, and `BARG.TYPE` are preserved.

<!-- PTO-READER-BLOCK: scalar-setc-ltu-constraints role=constraints -->
## What the setter marker and placement check reject

Applicability is confined to the body of an active Conditional block, where at most one successful `SETC` condition setter may complete.

Wrong placement or a second successful setter raises `Fault_BundleControl` (trap number `5`, `BUNDLE_TRAP`) before operand legality and before any source read. A fixed-bit mismatch or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before commit state, `BARG`, queue, or `TPC` effects. A rejected occurrence does not consume the shared marker.

<!-- PTO-READER-BLOCK: scalar-setc-ltu-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

Place `0` in GPR1 and `0` in GPR2, then execute `setc.ltu R1, R2`. The unsigned relation `0 < 0` is false, so the form commits `0`. Set GPR2 to `1` and the same form commits `1`, because unsigned `0 < 1` holds.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.ltu SrcL, SrcR<{.sw, .uw}>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_ltu_32_4a1ff65ecafb | L32 | 32 | 0x00006065 / 0xf8007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_ltu_32_4a1ff65ecafb | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_ltu_32_4a1ff65ecafb | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| setc_ltu_32_4a1ff65ecafb | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_ltu_32_4a1ff65ecafb | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_ltu_32_4a1ff65ecafb | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_ltu_32_4a1ff65ecafb | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.LTU.asl -->
```asl
readonly func InstructionContractOperation_SETC_LTU() => ScalarOperation
begin
    return ScalarOperation_SETC_LTU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.LTU.asl -->
```asl
readonly func InstructionContractHandler_SETC_LTU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_SETC_LTU()
    => ScalarCondition
begin
    return ScalarCondition_LTU;
end;

pure func InstructionContractCommitResult_SETC_LTU(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_SETC_LTU(),
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

- Compute SETC.LTU's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.ltu SrcL, SrcR<{.sw, .uw}>
