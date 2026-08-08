<!-- GENERATED FROM: asl/scalar/alu/C.ZEXT.H.asl -->
# C.ZEXT.H

**Normative ASL source:** `asl/scalar/alu/C.ZEXT.H.asl`

C.ZEXT.H - Sign-extend or zero-extend the selected scalar subword.

## Normative identity {#PTO-INST-SCALAR-C-ZEXT-H}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.zext.h srcL, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_zext_h_16_4c0976791cbc | C16 | 16 | 0x601c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_zext_h_16_4c0976791cbc | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.ZEXT.H.asl -->
```asl
readonly func InstructionContractOperation_C_ZEXT_H() => ScalarOperation
begin
    return ScalarOperation_C_ZEXT_H;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.ZEXT.H.asl -->
```asl
readonly func InstructionContractHandler_C_ZEXT_H() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `C.ZEXT.H - Sign-extend or zero-extend the selected scalar subword.`
- **Semantic handler:** `ExtendScalarValue`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
