<!-- GENERATED FROM: asl/scalar/sys/SSRGET.asl -->
# SSRGET

**Normative ASL source:** `asl/scalar/sys/SSRGET.asl`

SSRGET - Read the addressed system register.

## Normative identity {#PTO-INST-SCALAR-SSRGET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
ssrget SSR_ID, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ssrget_32_959957ab6b75 | L32 | 32 | 0x0000003b / 0x000ff07f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ssrget_32_959957ab6b75 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ssrget_32_959957ab6b75 | SSR_ID | 12 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| SSR_ID | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/SSRGET.asl -->
```asl
readonly func InstructionContractOperation_SSRGET() => ScalarOperation
begin
    return ScalarOperation_SSRGET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/SSRGET.asl -->
```asl
readonly func InstructionContractHandler_SSRGET() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterGet;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `SSRGET - Read the addressed system register.`
- **Semantic handler:** `ExecuteSystemRegisterGet`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
