<!-- GENERATED FROM: asl/scalar/bru/SETC.OR.asl -->
# SETC.OR

**Normative ASL source:** `asl/scalar/bru/SETC.OR.asl`

SETC.OR - Combine scalar comparison results and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-OR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-or-purpose role=purpose -->
## What SETC.OR does

`SETC.OR` combines two scalar registers with a bitwise OR and publishes whether the combination is nonzero as the commit decision of the Conditional bundle it sits in.

This makes the mnemonic a disjunction over two words: the block commits when either operand contributes at least one set bit.

<!-- PTO-READER-BLOCK: scalar-setc-or-mechanism role=mechanism -->
## Combining the two words with a bitwise OR

The instruction snapshots `SrcL` and the prepared right operand, computes the bitwise OR of the two complete words, and stores exactly `0` when the combination is zero and exactly `1` otherwise.

Unlike the relation members of the family, no numeric condition is involved: the tested property is whether the OR produced any set bit at all.

Design point: the committed value is the reduced truth value, not the OR result. The word produced by the combination is not written anywhere, so a program that needs the combined bits must compute them separately.

<!-- PTO-READER-BLOCK: scalar-setc-or-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` is a Reg5 source: codes `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`.
- `SrcR` uses the same Reg5 mapping.
- `SrcRType` transforms the `SrcR` snapshot before the combination: value `0` leaves the complete word unchanged, value `1` substitutes the sign-extended low `32` bits, value `2` the zero-extended low `32` bits, and value `3` substitutes the one's complement of the full word, which is the `.not` annotation on the canonical assembly.

Encoded zero in `SrcL` or `SrcR` names the architectural zero GPR. Sources are not consumed, and no `GPR`, `T`, or `U` destination is written.

<!-- PTO-READER-BLOCK: scalar-setc-or-effects role=effects -->
## Effects and ordering

On success the commit argument receives exactly `1` or `0`, `BARG.TAKEN` takes the same truth value while a bundle is active, the block condition marker becomes set, and `TPC` advances by `4` bytes.

No memory, reservation, descriptor, or numeric-status effect occurs, and `BARG.BPC`, `BARG.BPCN`, `BARG.BlockType`, and `BARG.TYPE` are preserved.

<!-- PTO-READER-BLOCK: scalar-setc-or-constraints role=constraints -->
## What the setter marker and placement check reject

Applicability is confined to the body of an active Conditional block, and the shared marker allows at most one successful `SETC` condition setter in that block.

Wrong placement or a second successful setter raises `Fault_BundleControl` (trap number `5`, `BUNDLE_TRAP`) before operand legality and before any source read. A fixed-bit mismatch or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before commit state, `BARG`, queue, or `TPC` effects. A rejected occurrence does not consume the shared marker.

<!-- PTO-READER-BLOCK: scalar-setc-or-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

Place `0` in GPR1 and `0` in GPR2, then execute `setc.or R1, R2`. The OR of two zero words is zero, so the form commits `0`. Set GPR1 to `4` and the same form commits `1`, even though only one bit is set.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.or SrcL, SrcR<.sw, .uw, .not>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_or_32_740134c709d2 | L32 | 32 | 0x00003065 / 0xf8007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_or_32_740134c709d2 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_or_32_740134c709d2 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| setc_or_32_740134c709d2 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_or_32_740134c709d2 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_or_32_740134c709d2 | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_or_32_740134c709d2 | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.OR.asl -->
```asl
readonly func InstructionContractOperation_SETC_OR() => ScalarOperation
begin
    return ScalarOperation_SETC_OR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.OR.asl -->
```asl
readonly func InstructionContractHandler_SETC_OR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;

pure func InstructionContractCombinesWithOR_SETC_OR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCommitLogicalValue_SETC_OR(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_SETC_OR() then
        return left OR right;
    end;
    return left AND right;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- All SETC condition setters share one block-private successful-occurrence marker; a failed first occurrence does not consume it.

## State effects

- Compute SETC.OR's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.or SrcL, SrcR<.sw, .uw, .not>
