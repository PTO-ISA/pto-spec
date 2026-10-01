<!-- GENERATED FROM: asl/scalar/bru/SETC.AND.asl -->
# SETC.AND

**Normative ASL source:** `asl/scalar/bru/SETC.AND.asl`

SETC.AND - Combine scalar comparison results and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-AND}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-and-purpose role=purpose -->
## What SETC.AND does

`SETC.AND` combines two scalar registers with bitwise AND and commits `1` when the combination is nonzero. It is the register form of the masked bit test: the result is not stored anywhere, it becomes the commit decision of the enclosing Conditional block.

Design point: `.not` is available on the logical setters `setc.and` and `setc.or`, while `setc.eq`, `setc.ge`, and `setc.lt` admit only `.sw` and `.uw`. A block can therefore commit on a bit being clear without a separate complement instruction.

<!-- PTO-READER-BLOCK: scalar-setc-and-mechanism role=mechanism -->
## How the bitwise AND decision is formed

`SrcL` and `SrcR` are read, `SrcRType` is applied to the right value, and the two words are combined with bitwise AND. A nonzero combination commits `1`; a zero combination commits `0`.

Design point: the commit value is canonicalized to `1` or `0` before it is stored, so the bundle decision does not depend on which nonzero operand values produced it.

<!-- PTO-READER-BLOCK: scalar-setc-and-inputs-outputs role=inputs-outputs -->
## Operands and result location

- `SrcL` supplies the left operand through the `Reg5` source rules: codes `0` to `23` read absolute GPRs, codes `24` to `27` read the T queue, and codes `28` to `31` read the U queue. A queue code whose entry is not valid rejects the instruction before any read.

- `SrcR` supplies the right operand through the same `Reg5` source rules. A queue code whose entry is not valid rejects the instruction before any read.

- `SrcRType` selects the transformation of the right source: `00` leaves it unmodified, `01` is `.sw` and sign-extends the low `32` bits, `10` is `.uw` and zero-extends them, and `11` is `.not` and complements the full `64`-bit word.

Design point: there is no destination register field. The comparison decision goes to the block commit state, so a setter cannot be encoded with a discarded, GPR, or queue destination and cannot be confused with a value-producing compare.

Design point: `.sw` and `.uw` rebuild the right operand from its low `32` bits, and only `.not` changes those low bits themselves.

<!-- PTO-READER-BLOCK: scalar-setc-and-effects role=effects -->
## Commit state and ordering

The canonical `1` or `0` is written to the block commit argument, the block's taken flag receives the same truth value, and the shared condition-set marker is then set. All three writes happen in one handler step.

Design point: the commit argument is written before the taken flag is derived from it, and nothing can fault between the two, so no observable bundle state exists in which they disagree.

Because the handler does not write `TPC`, the dispatch boundary then advances `TPC` by `4` bytes, the encoded length of the `32`-bit form. No register, memory location, or numeric status is written.

<!-- PTO-READER-BLOCK: scalar-setc-and-constraints role=constraints -->
## Placement, single-setter rule, and fault order

`SETC.AND` is applicable only while an active Conditional block has not yet set its condition. The applicability test also names an active body, and the dispatch entry activates the body of an active block immediately before that test, so a body that is not yet active is not a rejection case by itself. A block that is not active, a block whose transfer type is not `Conditional`, or a bundle that has already accepted one condition setter raises `Fault_BundleControl` (trap number `5`, `BUNDLE_TRAP`) before a source is read and before any commit state is written.

Design point: the block keeps one shared condition-set marker, and only a successful occurrence sets it. A `SETC.AND` rejected by an encoding or operand check leaves the marker clear, so a later condition setter in the same block can still commit. The rejected occurrence consumes nothing.

The fixed bits of the form must match and every selected source code must be usable, otherwise `Fault_IllegalInstruction` is raised with `TPC` unchanged. No field value is reserved.

Design point: entering the bundle body happens before applicability is checked, so a rejected setter leaves the body active. The rejection does not roll that transition back.

<!-- PTO-READER-BLOCK: scalar-setc-and-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

With `a0` holding `0x000000000000000C` and `a1` holding `0x0000000000000008`, `setc.and a0, a1.uw` commits `1`, because the AND is `8`. The same operands with `setc.and a0, a1.not` also commit `1`, because the complement of `a1` still shares bit `2` with `a0`. With `a1` holding `0x0000000000000003`, `setc.and a0, a1.uw` commits `0`.

At the end of the block the taken flag selects the continuation: a taken Conditional block continues at the candidate next `PC`, and an untaken one continues sequentially.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.and SrcL, SrcR<.sw, .uw, .not>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_and_32_90b4e93ef9d4 | L32 | 32 | 0x00002065 / 0xf8007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_and_32_90b4e93ef9d4 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_and_32_90b4e93ef9d4 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| setc_and_32_90b4e93ef9d4 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_and_32_90b4e93ef9d4 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_and_32_90b4e93ef9d4 | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_and_32_90b4e93ef9d4 | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.AND.asl -->
```asl
readonly func InstructionContractOperation_SETC_AND() => ScalarOperation
begin
    return ScalarOperation_SETC_AND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.AND.asl -->
```asl
readonly func InstructionContractHandler_SETC_AND() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;

pure func InstructionContractCombinesWithOR_SETC_AND()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCommitLogicalValue_SETC_AND(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_SETC_AND() then
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

- Compute SETC.AND's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.and SrcL, SrcR<.sw, .uw, .not>
