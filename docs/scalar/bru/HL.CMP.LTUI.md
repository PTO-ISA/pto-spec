<!-- GENERATED FROM: asl/scalar/bru/HL.CMP.LTUI.asl -->
# HL.CMP.LTUI

**Normative ASL source:** `asl/scalar/bru/HL.CMP.LTUI.asl`

HL.CMP.LTUI - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-HL-CMP-LTUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-purpose role=purpose -->
## What HL.CMP.LTUI does

`HL.CMP.LTUI` compares a scalar register with a `24`-bit unsigned immediate using unsigned less-than and writes `1` or `0` as the result. The signed counterpart is `HL.CMP.LTI`.

Design point: both sides are read as unsigned values, so no operand is ever treated as negative, and the largest unsigned word is simply the largest value.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-mechanism role=mechanism -->
## How the unsigned less-than test is evaluated

`SrcL` is read and `uimm24` is zero-extended to `PTO_XLEN`, so the field always supplies a non-negative value from `0` to `16777215`. The handler evaluates unsigned less-than, producing `1` when true and `0` when false.

Design point: an unsigned value is never less than `0`, so `hl.cmp.ltui a0, 0` writes `0` for every `a0`. The same encoding under `HL.CMP.LTI` would test for a negative value.

Design point: the written word is always `1` or `0`, never an all-ones mask, so a consumer can add it to a counter, shift it, or test it without masking.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-inputs-outputs role=inputs-outputs -->
## Operands and destination codes

- `SrcL` supplies the left operand through the `Reg5` source rules: codes `0` to `23` read absolute GPRs, codes `24` to `27` read the T queue, and codes `28` to `31` read the U queue. A queue code whose entry is not valid rejects the instruction before any read.

- `uimm24` supplies the `24`-bit unsigned bound, encoded in two pieces of `12` bits and `12` bits.

- `RegDst` selects the destination with the ordinary `Reg5` rules: codes `0` to `23` name absolute GPRs, codes `24` to `29` write nothing, code `30` pushes the U queue, and code `31` pushes the T queue.

Design point: this form has no right-source modifier field, so it has no `.sw`, `.uw`, or `.not` spelling. The left operand is used exactly as read, and the only transformation is the extension of the immediate.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-effects role=effects -->
## Effects and ordering

The canonical `1` or `0` is written through the selected destination, and nothing else is written. Because the handler does not write `TPC`, the dispatch boundary then advances `TPC` by `6` bytes, the encoded length of the `48`-bit form.

`HL.CMP.LTUI` is not a condition setter, so it never touches `_CommitArgument`, `BARG.TAKEN`, or the bundle condition marker, and no Conditional-block placement is required for it. The relational commit twin with the same condition is `HL.SETC.LTUI`.

The handler reads no memory, takes no reservation, and records no numeric status, so the only architectural difference an accepted execution makes is the destination word and the advanced `TPC`.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-constraints role=constraints -->
## Legality and fault order

The fixed bits of the form must match, otherwise the pattern does not decode as this instruction and raises `Fault_IllegalInstruction`. No field value is reserved: all `32` `RegDst` codes and all values of the `24`-bit immediate field are assigned. The selected `SrcL` code must also be usable, so a T or U queue code whose entry is not valid raises the same fault.

Design point: the decode, source, and destination checks all run before an operand is read and before the destination is written, so a rejected encoding changes neither the destination nor `TPC`.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

With `a0` holding `0`, `hl.cmp.ltui a0, 1, ->a1` writes `1`. With `a0` holding `0xFFFFFFFFFFFFFFFF`, the same encoding writes `0`, because that word is the largest unsigned value.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.cmp.ltui SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_cmp_ltui_48_d12167277d58 | HL48 | 48 | 0x00006055000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_cmp_ltui_48_d12167277d58 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_cmp_ltui_48_d12167277d58 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_cmp_ltui_48_d12167277d58 | uimm24 | 24 | unsigned | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_cmp_ltui_48_d12167277d58 | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| hl_cmp_ltui_48_d12167277d58 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| hl_cmp_ltui_48_d12167277d58 | uimm24 | 24 | 0–16777215 | none | none | 24-bit unsigned immediate | Encoded zero supplies numeric zero for the 24-bit unsigned immediate. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| uimm24 | 24-bit unsigned immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.CMP.LTUI.asl -->
```asl
readonly func InstructionContractOperation_HL_CMP_LTUI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_LTUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.CMP.LTUI.asl -->
```asl
readonly func InstructionContractHandler_HL_CMP_LTUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;

pure func InstructionContractCondition_HL_CMP_LTUI()
    => ScalarCondition
begin
    return ScalarCondition_LTU;
end;

pure func InstructionContractCompareResult_HL_CMP_LTUI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_HL_CMP_LTUI(),
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

- HL.CMP.LTUI - Compare scalar operands and write the encoded boolean result.
- After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- hl.cmp.ltui SrcL, uimm, ->{t, u, Rd}
