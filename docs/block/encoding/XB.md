<!-- GENERATED FROM: asl/block/encoding/XB.asl -->
# XB

**Normative ASL source:** `asl/block/encoding/XB.asl`

Transfers the named context value to a target virtual core block.

## Normative identity {#PTO-INST-BLOCK-XB}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
XB ACR-ID, C-ID
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| xb_32_40ad190a0a7f | L32 | 32 | 0x00006f81 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| xb_32_40ad190a0a7f | ACR-ID | 10 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":10}] |
| xb_32_40ad190a0a7f | CROSS-BID | 7 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":7}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| ACR-ID | encoded operand or control |
| CROSS-BID | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/XB.asl -->
```asl
readonly func InstructionContractMatches_XB(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_xb_32_40ad190a0a7f);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/XB.asl -->
```asl
readonly func InstructionContractHandler_XB() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteCrossBlockTransfer;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `Transfers the named context value to a target virtual core block.`
- **Semantic handler:** `ExecuteCrossBlockTransfer`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
