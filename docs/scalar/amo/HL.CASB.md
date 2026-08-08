<!-- GENERATED FROM: asl/scalar/amo/HL.CASB.asl -->
# HL.CASB

**Normative ASL source:** `asl/scalar/amo/HL.CASB.asl`

HL.CASB - Atomically compare the scalar memory value and conditionally store the replacement.

## Normative identity {#PTO-INST-SCALAR-HL-CASB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.casb<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, SrcD, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_casb_48_21fb578617a8 | HL48 | 48 | 0x0000600b000e / 0xf000707ff83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_casb_48_21fb578617a8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_casb_48_21fb578617a8 | SrcD | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_casb_48_21fb578617a8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_casb_48_21fb578617a8 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_casb_48_21fb578617a8 | aq | 1 | encoding-defined | [{"instruction_lsb":42,"value_lsb":0,"width":1}] |
| hl_casb_48_21fb578617a8 | far | 1 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":1}] |
| hl_casb_48_21fb578617a8 | rl | 1 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":1}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcD | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| aq | encoded operand or control |
| far | encoded operand or control |
| rl | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/HL.CASB.asl -->
```asl
readonly func InstructionContractOperation_HL_CASB() => ScalarOperation
begin
    return ScalarOperation_HL_CASB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/HL.CASB.asl -->
```asl
readonly func InstructionContractHandler_HL_CASB() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.CASB - Atomically compare the scalar memory value and conditionally store the replacement.`
- **Semantic handler:** `CompareAndSwap`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
