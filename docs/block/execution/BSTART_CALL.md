<!-- GENERATED FROM: asl/block/execution/BSTART_CALL.asl -->
# BSTART CALL

**Normative ASL source:** `asl/block/execution/BSTART_CALL.asl`

Atomically closes the current bundle, computes the call target from the signed displacement and the return address from the independent unsigned displacement, writes ra, and transfers control to the call bundle.

## Normative identity {#PTO-INST-BLOCK-BSTART-CALL}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
BSTART.CALL <br_label>, <rt_label>, ->ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_call_32_9404418d1ae5 | L32 | 32 | 0x50160002 / 0xf83f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_call_32_9404418d1ae5 | simm12 | 12 | signed | [{"instruction_lsb":4,"value_lsb":0,"width":12}] |
| bstart_call_32_9404418d1ae5 | uimm5 | 5 | unsigned | [{"instruction_lsb":22,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm12 | encoded operand or control |
| uimm5 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART_CALL.asl -->
```asl
readonly func InstructionContractMatches_BSTART_CALL(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_call_32_9404418d1ae5);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART_CALL.asl -->
```asl
readonly func InstructionContractHandler_BSTART_CALL() => CommandSemanticHandler
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
