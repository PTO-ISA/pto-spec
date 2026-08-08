<!-- GENERATED FROM: asl/block/lifecycle/B.TEXT.asl -->
# B.TEXT

**Normative ASL source:** `asl/block/lifecycle/B.TEXT.asl`

Sets the out-of-line body entry address for a decoupled bundle.

## Normative identity {#PTO-INST-BLOCK-B-TEXT}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
B.TEXT <label>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_text_32_1ce09f50e5dd | L32 | 32 | 0x00000003 / 0x0000007f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_text_32_1ce09f50e5dd | simm25 | 25 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm25 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/B.TEXT.asl -->
```asl
readonly func InstructionContractMatches_B_TEXT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_text_32_1ce09f50e5dd);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/B.TEXT.asl -->
```asl
readonly func InstructionContractHandler_B_TEXT() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleBodyAddress;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `Sets the out-of-line body entry address for a decoupled bundle.`
- **Semantic handler:** `SetBundleBodyAddress`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
