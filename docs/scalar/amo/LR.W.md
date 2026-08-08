<!-- GENERATED FROM: asl/scalar/amo/LR.W.asl -->
# LR.W

**Normative ASL source:** `asl/scalar/amo/LR.W.asl`

LR.W - Load the scalar memory value and establish a matching reservation.

## Normative identity {#PTO-INST-SCALAR-LR-W}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
lr.w<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], {->t, ->u, ->Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lr_w_32_efecc735bb75 | L32 | 32 | 0x2000000b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lr_w_32_efecc735bb75 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lr_w_32_efecc735bb75 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lr_w_32_efecc735bb75 | SrcZero | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| lr_w_32_efecc735bb75 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| lr_w_32_efecc735bb75 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| lr_w_32_efecc735bb75 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcZero | encoded operand or control |
| aq | encoded operand or control |
| far | encoded operand or control |
| rl | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/LR.W.asl -->
```asl
readonly func InstructionContractOperation_LR_W() => ScalarOperation
begin
    return ScalarOperation_LR_W;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/LR.W.asl -->
```asl
readonly func InstructionContractHandler_LR_W() => ScalarSemanticHandler
begin
    return ScalarHandler_LoadReserved;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `LR.W - Load the scalar memory value and establish a matching reservation.`
- **Semantic handler:** `LoadReserved`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
