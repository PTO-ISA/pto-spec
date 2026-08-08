<!-- GENERATED FROM: asl/scalar/bru/HL.SETRET.asl -->
# HL.SETRET

**Normative ASL source:** `asl/scalar/bru/HL.SETRET.asl`

HL.SETRET - Write the architectural return address.

## Normative identity {#PTO-INST-SCALAR-HL-SETRET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.setret imm, ->Ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_setret_48_302bb793a800 | HL48 | 48 | 0x00000507000e / 0x00000fff000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_setret_48_302bb793a800 | imm32 | 32 | encoding-defined | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| imm32 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.SETRET.asl -->
```asl
readonly func InstructionContractOperation_HL_SETRET() => ScalarOperation
begin
    return ScalarOperation_HL_SETRET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.SETRET.asl -->
```asl
readonly func InstructionContractHandler_HL_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.SETRET - Write the architectural return address.`
- **Semantic handler:** `SetReturnAddress`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
