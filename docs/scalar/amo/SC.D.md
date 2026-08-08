<!-- GENERATED FROM: asl/scalar/amo/SC.D.asl -->
# SC.D

**Normative ASL source:** `asl/scalar/amo/SC.D.asl`

SC.D - Conditionally store the scalar value when the matching reservation remains valid.

## Normative identity {#PTO-INST-SCALAR-SC-D}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
sc.d<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> SrcL, [SrcR], {->t, ->u, ->Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sc_d_32_2e714149031c | L32 | 32 | 0x3000100b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sc_d_32_2e714149031c | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sc_d_32_2e714149031c | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sc_d_32_2e714149031c | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sc_d_32_2e714149031c | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| sc_d_32_2e714149031c | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| sc_d_32_2e714149031c | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| SrcR | encoded operand or control |
| aq | encoded operand or control |
| far | encoded operand or control |
| rl | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SC.D.asl -->
```asl
readonly func InstructionContractOperation_SC_D() => ScalarOperation
begin
    return ScalarOperation_SC_D;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SC.D.asl -->
```asl
readonly func InstructionContractHandler_SC_D() => ScalarSemanticHandler
begin
    return ScalarHandler_StoreConditional;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `SC.D - Conditionally store the scalar value when the matching reservation remains valid.`
- **Semantic handler:** `StoreConditional`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
