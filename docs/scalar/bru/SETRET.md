<!-- GENERATED FROM: asl/scalar/bru/SETRET.asl -->
# SETRET

**Normative ASL source:** `asl/scalar/bru/SETRET.asl`

SETRET - Write the architectural return address.

## Normative identity {#PTO-INST-SCALAR-SETRET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
setret uimm, ->Ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setret_32_72003dcf3b59 | L32 | 32 | 0x00000507 / 0x00000fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setret_32_72003dcf3b59 | imm20 | 20 | encoding-defined | [{"instruction_lsb":12,"value_lsb":0,"width":20}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| imm20 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETRET.asl -->
```asl
readonly func InstructionContractOperation_SETRET() => ScalarOperation
begin
    return ScalarOperation_SETRET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETRET.asl -->
```asl
readonly func InstructionContractHandler_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `SETRET - Write the architectural return address.`
- **Semantic handler:** `SetReturnAddress`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
