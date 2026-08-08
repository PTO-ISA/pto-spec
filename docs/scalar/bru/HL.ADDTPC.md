<!-- GENERATED FROM: asl/scalar/bru/HL.ADDTPC.asl -->
# HL.ADDTPC

**Normative ASL source:** `asl/scalar/bru/HL.ADDTPC.asl`

HL.ADDTPC - Add the encoded displacement to the program counter.

## Normative identity {#PTO-INST-SCALAR-HL-ADDTPC}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.addtpc imm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_addtpc_48_2e8e692eea09 | HL48 | 48 | 0x00000007000e / 0x0000007f000f | [{"field":"RegDst","operator":"not-equal","value":10}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_addtpc_48_2e8e692eea09 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_addtpc_48_2e8e692eea09 | imm32 | 32 | encoding-defined | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| imm32 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.ADDTPC.asl -->
```asl
readonly func InstructionContractOperation_HL_ADDTPC() => ScalarOperation
begin
    return ScalarOperation_HL_ADDTPC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.ADDTPC.asl -->
```asl
readonly func InstructionContractHandler_HL_ADDTPC() => ScalarSemanticHandler
begin
    return ScalarHandler_AddToPC;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Constraints:** `[{"field": "RegDst", "operator": "not-equal", "value": 10}]`

## Operational information

- **Semantic summary:** `HL.ADDTPC - Add the encoded displacement to the program counter.`
- **Semantic handler:** `AddToPC`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
