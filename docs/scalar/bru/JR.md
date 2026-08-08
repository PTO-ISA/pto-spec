<!-- GENERATED FROM: asl/scalar/bru/JR.asl -->
# JR

**Normative ASL source:** `asl/scalar/bru/JR.asl`

JR - Jump to the scalar-register target.

## Normative identity {#PTO-INST-SCALAR-JR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
jr SrcL, label
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| jr_32_c4128e843b05 | L32 | 32 | 0x00006027 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| jr_32_c4128e843b05 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| jr_32_c4128e843b05 | SrcZero | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| jr_32_c4128e843b05 | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |
| SrcZero | encoded operand or control |
| simm12 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/JR.asl -->
```asl
readonly func InstructionContractOperation_JR() => ScalarOperation
begin
    return ScalarOperation_JR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/JR.asl -->
```asl
readonly func InstructionContractHandler_JR() => ScalarSemanticHandler
begin
    return ScalarHandler_JumpRegister;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `JR - Jump to the scalar-register target.`
- **Semantic handler:** `JumpRegister`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
