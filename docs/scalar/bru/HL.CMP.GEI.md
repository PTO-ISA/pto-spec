<!-- GENERATED FROM: asl/scalar/bru/HL.CMP.GEI.asl -->
# HL.CMP.GEI

**Normative ASL source:** `asl/scalar/bru/HL.CMP.GEI.asl`

HL.CMP.GEI - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-HL-CMP-GEI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-cmp-gei-purpose role=purpose -->
## What HL.CMP.GEI does

`HL.CMP.GEI` compares a scalar register with a `24`-bit immediate using signed greater-than-or-equal and writes `1` or `0` as the result. The unsigned counterpart is `HL.CMP.GEUI`.

Design point: the relation includes equality, so `hl.cmp.gei a0, imm` and `hl.cmp.lti a0, imm` are exact complements for the same operands. No separate equality test is needed to cover both outcomes.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-gei-mechanism role=mechanism -->
## How the signed greater-or-equal test is evaluated

`SrcL` is read and `simm24` is sign-extended to `PTO_XLEN`. The handler evaluates signed greater-than-or-equal on the two `64`-bit words, so the comparison uses two's-complement values. True produces `1`, false produces `0`.

Design point: an all-ones word is the signed value `-1`, so `hl.cmp.gei a0, 0` is false for it, even though the same word is the largest unsigned value.

Design point: the written word is always `1` or `0`, never an all-ones mask, so a consumer can add it to a counter, shift it, or test it without masking.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-gei-inputs-outputs role=inputs-outputs -->
## Operands and destination codes

- `SrcL` supplies the left operand through the `Reg5` source rules: codes `0` to `23` read absolute GPRs, codes `24` to `27` read the T queue, and codes `28` to `31` read the U queue. A queue code whose entry is not valid rejects the instruction before any read.

- `simm24` supplies the `24`-bit signed bound, encoded in two pieces of `12` bits and `12` bits.

- `RegDst` selects the destination with the ordinary `Reg5` rules: codes `0` to `23` name absolute GPRs, codes `24` to `29` write nothing, code `30` pushes the U queue, and code `31` pushes the T queue.

Design point: this form has no right-source modifier field, so it has no `.sw`, `.uw`, or `.not` spelling. The left operand is used exactly as read, and the only transformation is the extension of the immediate.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-gei-effects role=effects -->
## Effects and ordering

The canonical `1` or `0` is written through the selected destination, and nothing else is written. Because the handler does not write `TPC`, the dispatch boundary then advances `TPC` by `6` bytes, the encoded length of the `48`-bit form.

`HL.CMP.GEI` is not a condition setter, so it never touches `_CommitArgument`, `BARG.TAKEN`, or the bundle condition marker, and no Conditional-block placement is required for it. The relational commit twin with the same condition is `HL.SETC.GEI`.

The handler reads no memory, takes no reservation, and records no numeric status, so the only architectural difference an accepted execution makes is the destination word and the advanced `TPC`.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-gei-constraints role=constraints -->
## Legality and fault order

The fixed bits of the form must match, otherwise the pattern does not decode as this instruction and raises `Fault_IllegalInstruction`. No field value is reserved: all `32` `RegDst` codes and all values of the `24`-bit immediate field are assigned. The selected `SrcL` code must also be usable, so a T or U queue code whose entry is not valid raises the same fault.

Design point: the decode, source, and destination checks all run before an operand is read and before the destination is written, so a rejected encoding changes neither the destination nor `TPC`.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-gei-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

With `a0` holding `0xFFFFFFFFFFFFFFFF`, `hl.cmp.gei a0, 0, ->a1` writes `0`, and `hl.cmp.gei a0, -1, ->a1` writes `1`, because equality satisfies the relation.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.cmp.gei SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_cmp_gei_48_b3703d4c4619 | HL48 | 48 | 0x00005055000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_cmp_gei_48_b3703d4c4619 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_cmp_gei_48_b3703d4c4619 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_cmp_gei_48_b3703d4c4619 | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_cmp_gei_48_b3703d4c4619 | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| hl_cmp_gei_48_b3703d4c4619 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| hl_cmp_gei_48_b3703d4c4619 | simm24 | 24 | 0–16777215 | none | none | 24-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 24-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| simm24 | 24-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.CMP.GEI.asl -->
```asl
readonly func InstructionContractOperation_HL_CMP_GEI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_GEI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.CMP.GEI.asl -->
```asl
readonly func InstructionContractHandler_HL_CMP_GEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;

pure func InstructionContractCondition_HL_CMP_GEI()
    => ScalarCondition
begin
    return ScalarCondition_GE;
end;

pure func InstructionContractCompareResult_HL_CMP_GEI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_HL_CMP_GEI(),
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- HL.CMP.GEI - Compare scalar operands and write the encoded boolean result.
- After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- hl.cmp.gei SrcL, simm, ->{t, u, Rd}
