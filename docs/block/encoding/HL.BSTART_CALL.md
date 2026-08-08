<!-- GENERATED FROM: asl/block/encoding/HL.BSTART_CALL.asl -->
# HL.BSTART CALL

**Normative ASL source:** `asl/block/encoding/HL.BSTART_CALL.asl`

Atomically closes the current bundle, computes the call target from the signed displacement and the return address from the independent unsigned displacement, writes ra, and transfers control to the call bundle.

## Normative identity {#PTO-INST-BLOCK-HL-BSTART-CALL}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
HL.BSTART.CALL <br_label>, <rt_label>, ->ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_bstart_call_48_3c784c583c90 | HL48 | 48 | 0x501600000011 / 0xf83f0000007f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_bstart_call_48_3c784c583c90 | simm25 | 25 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25}] |
| hl_bstart_call_48_3c784c583c90 | uimm5 | 5 | unsigned | [{"instruction_lsb":38,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm25 | encoded operand or control |
| uimm5 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/HL.BSTART_CALL.asl -->
```asl
readonly func InstructionContractMatches_HL_BSTART_CALL(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_bstart_call_48_3c784c583c90);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/HL.BSTART_CALL.asl -->
```asl
readonly func InstructionContractHandler_HL_BSTART_CALL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `Atomically closes the current bundle, computes the call target from the signed displacement and the return address from the independent unsigned displacement, writes ra, and transfers control to the call bundle.`
- **Semantic handler:** `ExecuteBundleStart`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
