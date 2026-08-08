<!-- GENERATED FROM: asl/scalar/agu/LWUI.U.asl -->
# LWUI.U

**Normative ASL source:** `asl/scalar/agu/LWUI.U.asl`

LWUI.U - Load scalar data using this mnemonic's width, signedness, and address-update form.

## Normative identity {#PTO-INST-SCALAR-LWUI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
lwui.u [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lwui_u_32_1fcbb98df571 | L32 | 32 | 0x00006029 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lwui_u_32_1fcbb98df571 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lwui_u_32_1fcbb98df571 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lwui_u_32_1fcbb98df571 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| simm12 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LWUI.U.asl -->
```asl
readonly func InstructionContractOperation_LWUI_U() => ScalarOperation
begin
    return ScalarOperation_LWUI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LWUI.U.asl -->
```asl
readonly func InstructionContractHandler_LWUI_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `LWUI.U - Load scalar data using this mnemonic's width, signedness, and address-update form.`
- **Semantic handler:** `ExecuteScalarLoad`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
