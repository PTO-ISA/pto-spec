<!-- GENERATED FROM: asl/scalar/agu/LWI.asl -->
# LWI

**Normative ASL source:** `asl/scalar/agu/LWI.asl`

LWI - Load scalar data using this mnemonic's width, signedness, and address-update form.

## Normative identity {#PTO-INST-SCALAR-LWI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
lwi [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lwi_32_7085c98058fa | L32 | 32 | 0x00002019 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lwi_32_7085c98058fa | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lwi_32_7085c98058fa | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lwi_32_7085c98058fa | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SrcL | encoded operand or control |
| simm12 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LWI.asl -->
```asl
readonly func InstructionContractOperation_LWI() => ScalarOperation
begin
    return ScalarOperation_LWI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LWI.asl -->
```asl
readonly func InstructionContractHandler_LWI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `LWI - Load scalar data using this mnemonic's width, signedness, and address-update form.`
- **Semantic handler:** `ExecuteScalarLoad`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
