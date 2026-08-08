<!-- GENERATED FROM: asl/scalar/sys/C.SSRGET.asl -->
# C.SSRGET

**Normative ASL source:** `asl/scalar/sys/C.SSRGET.asl`

C.SSRGET - Read the compressed-form system register.

## Normative identity {#PTO-INST-SCALAR-C-SSRGET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.ssrget SSR-ID, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_ssrget_16_9d83a6f2749a | C16 | 16 | 0x802c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_ssrget_16_9d83a6f2749a | SSRID | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SSRID | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/C.SSRGET.asl -->
```asl
readonly func InstructionContractOperation_C_SSRGET() => ScalarOperation
begin
    return ScalarOperation_C_SSRGET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/C.SSRGET.asl -->
```asl
readonly func InstructionContractHandler_C_SSRGET() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompressedSystemRegisterGet;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `C.SSRGET - Read the compressed-form system register.`
- **Semantic handler:** `ExecuteCompressedSystemRegisterGet`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
