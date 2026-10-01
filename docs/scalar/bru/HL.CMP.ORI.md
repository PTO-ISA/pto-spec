<!-- GENERATED FROM: asl/scalar/bru/HL.CMP.ORI.asl -->
# HL.CMP.ORI

**Normative ASL source:** `asl/scalar/bru/HL.CMP.ORI.asl`

HL.CMP.ORI - Combine scalar comparison results with the encoded logical operation.

## Normative identity {#PTO-INST-SCALAR-HL-CMP-ORI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-cmp-ori-purpose role=purpose -->
## What HL.CMP.ORI does

`HL.CMP.ORI` tests whether the bitwise OR of a scalar register and a `24`-bit immediate is nonzero, and writes `1` or `0` as the result. It is the OR member of the wide-immediate compare family, using a `24`-bit immediate where the `32`-bit `CMP.ORI` uses `12` bits.

Design point: the OR result itself is not published. With a zero immediate the instruction is a plain nonzero test of `SrcL`; with a nonzero immediate a set bit in either operand forces the answer to `1`.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ori-mechanism role=mechanism -->
## How the logical OR test is evaluated

`SrcL` is read and `simm24` is sign-extended to `PTO_XLEN`. The two are combined with bitwise OR, and the handler writes `1` when the combination is nonzero and `0` when it is zero.

Design point: because the immediate is sign-extended, a negative immediate sets all upper bits of the right operand, so `hl.cmp.ori a0, -1` writes `1` for every value of `a0`.

Design point: the written word is always `1` or `0`, never an all-ones mask, so a consumer can add it to a counter, shift it, or test it without masking.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ori-inputs-outputs role=inputs-outputs -->
## Operands and destination codes

- `SrcL` supplies the left operand through the `Reg5` source rules: codes `0` to `23` read absolute GPRs, codes `24` to `27` read the T queue, and codes `28` to `31` read the U queue. A queue code whose entry is not valid rejects the instruction before any read.

- `simm24` supplies the `24`-bit signed constant, encoded in two pieces of `12` bits and `12` bits.

- `RegDst` selects the destination with the ordinary `Reg5` rules: codes `0` to `23` name absolute GPRs, codes `24` to `29` write nothing, code `30` pushes the U queue, and code `31` pushes the T queue.

Design point: this form has no right-source modifier field, so it has no `.sw`, `.uw`, or `.not` spelling. The left operand is used exactly as read, and the only transformation is the extension of the immediate.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ori-effects role=effects -->
## Effects and ordering

The canonical `1` or `0` is written through the selected destination, and nothing else is written. Because the handler does not write `TPC`, the dispatch boundary then advances `TPC` by `6` bytes, the encoded length of the `48`-bit form.

`HL.CMP.ORI` is not a condition setter, so it never touches `_CommitArgument`, `BARG.TAKEN`, or the bundle condition marker, and no Conditional-block placement is required for it. The relational commit twin with the same condition is `HL.SETC.ORI`.

The handler reads no memory, takes no reservation, and records no numeric status, so the only architectural difference an accepted execution makes is the destination word and the advanced `TPC`.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ori-constraints role=constraints -->
## Legality and fault order

The fixed bits of the form must match, otherwise the pattern does not decode as this instruction and raises `Fault_IllegalInstruction`. No field value is reserved: all `32` `RegDst` codes and all values of the `24`-bit immediate field are assigned. The selected `SrcL` code must also be usable, so a T or U queue code whose entry is not valid raises the same fault.

Design point: the decode, source, and destination checks all run before an operand is read and before the destination is written, so a rejected encoding changes neither the destination nor `TPC`.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ori-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

With `a0` holding `0x0000000000000005`, `hl.cmp.ori a0, 0, ->a1` writes `1`. With `a0` holding `0`, the same encoding writes `0`, and `hl.cmp.ori a0, 1, ->a1` writes `1` again because the immediate alone makes the OR nonzero.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.cmp.ori SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_cmp_ori_48_4167568cb50b | HL48 | 48 | 0x00003055000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_cmp_ori_48_4167568cb50b | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_cmp_ori_48_4167568cb50b | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_cmp_ori_48_4167568cb50b | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_cmp_ori_48_4167568cb50b | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| hl_cmp_ori_48_4167568cb50b | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| hl_cmp_ori_48_4167568cb50b | simm24 | 24 | 0–16777215 | none | none | 24-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 24-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| simm24 | 24-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.CMP.ORI.asl -->
```asl
readonly func InstructionContractOperation_HL_CMP_ORI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_ORI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.CMP.ORI.asl -->
```asl
readonly func InstructionContractHandler_HL_CMP_ORI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompareLogical;
end;

pure func InstructionContractCombinesWithOR_HL_CMP_ORI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCompareLogicalValue_HL_CMP_ORI(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_HL_CMP_ORI() then
        return left OR right;
    end;
    return left AND right;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- HL.CMP.ORI - Combine scalar comparison results with the encoded logical operation.
- After decode and legality checks, execute the normative ExecuteCompareLogical ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- hl.cmp.ori SrcL, simm, ->{t, u, Rd}
