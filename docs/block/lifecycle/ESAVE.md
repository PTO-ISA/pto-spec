<!-- GENERATED FROM: asl/block/lifecycle/ESAVE.asl -->
# ESAVE

**Normative ASL source:** `asl/block/lifecycle/ESAVE.asl`

Saves the encoded execution-context range to memory.

## Normative identity {#PTO-INST-BLOCK-ESAVE}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
ESAVE [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| esave_32_4c4f79fe3171 | L32 | 32 | 0x00002031 / 0x06007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| esave_32_4c4f79fe3171 | RegSrc0 | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| esave_32_4c4f79fe3171 | RegSrc1 | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| esave_32_4c4f79fe3171 | RegSrc2 | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegSrc0 | encoded operand or control |
| RegSrc1 | encoded operand or control |
| RegSrc2 | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/ESAVE.asl -->
```asl
readonly func InstructionContractMatches_ESAVE(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_esave_32_4c4f79fe3171);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/ESAVE.asl -->
```asl
readonly func InstructionContractHandler_ESAVE() => CommandSemanticHandler
begin
    return CommandHandler_SaveExecutionContext;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `Saves the encoded execution-context range to memory.`
- **Semantic handler:** `SaveExecutionContext`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
