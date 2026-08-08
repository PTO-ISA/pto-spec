<!-- GENERATED FROM: asl/scalar/alu/C.SEXT.W.asl -->
# C.SEXT.W

**Normative ASL source:** `asl/scalar/alu/C.SEXT.W.asl`

C.SEXT.W - Sign-extend or zero-extend the selected scalar subword.

## Normative identity {#PTO-INST-SCALAR-C-SEXT-W}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.sext.w srcL, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_sext_w_16_f2bb13f0797b | C16 | 16 | 0x501c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_sext_w_16_f2bb13f0797b | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SEXT.W.asl -->
```asl
readonly func InstructionContractOperation_C_SEXT_W() => ScalarOperation
begin
    return ScalarOperation_C_SEXT_W;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SEXT.W.asl -->
```asl
readonly func InstructionContractHandler_C_SEXT_W() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `C.SEXT.W - Sign-extend or zero-extend the selected scalar subword.`
- **Semantic handler:** `ExtendScalarValue`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
