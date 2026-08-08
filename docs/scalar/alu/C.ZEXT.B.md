<!-- GENERATED FROM: asl/scalar/alu/C.ZEXT.B.asl -->
# C.ZEXT.B

**Normative ASL source:** `asl/scalar/alu/C.ZEXT.B.asl`

C.ZEXT.B - Sign-extend or zero-extend the selected scalar subword.

## Normative identity {#PTO-INST-SCALAR-C-ZEXT-B}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.zext.b srcL, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_zext_b_16_7ea1a59fa2da | C16 | 16 | 0x581c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_zext_b_16_7ea1a59fa2da | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.ZEXT.B.asl -->
```asl
readonly func InstructionContractOperation_C_ZEXT_B() => ScalarOperation
begin
    return ScalarOperation_C_ZEXT_B;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.ZEXT.B.asl -->
```asl
readonly func InstructionContractHandler_C_ZEXT_B() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `C.ZEXT.B - Sign-extend or zero-extend the selected scalar subword.`
- **Semantic handler:** `ExtendScalarValue`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
