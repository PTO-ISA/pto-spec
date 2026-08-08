<!-- GENERATED FROM: asl/block/lifecycle/FRET.STK.asl -->
# FRET.STK

**Normative ASL source:** `asl/block/lifecycle/FRET.STK.asl`

Restores a frame and returns through the validated stack target.

## Normative identity {#PTO-INST-BLOCK-FRET-STK}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
FRET.STK [RegDst0 ~ RegDstn], sp!, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fret_stk_32_4fe246bd8241 | L32 | 32 | 0x00003041 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fret_stk_32_4fe246bd8241 | DstBegin | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fret_stk_32_4fe246bd8241 | DstEnd | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fret_stk_32_4fe246bd8241 | uimm | 15 | unsigned | [{"instruction_lsb":25,"value_lsb":3,"width":7},{"instruction_lsb":7,"value_lsb":10,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstBegin | encoded operand or control |
| DstEnd | encoded operand or control |
| uimm | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/FRET.STK.asl -->
```asl
readonly func InstructionContractMatches_FRET_STK(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fret_stk_32_4fe246bd8241);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/FRET.STK.asl -->
```asl
readonly func InstructionContractHandler_FRET_STK() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameReturnStack;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `Restores a frame and returns through the validated stack target.`
- **Semantic handler:** `ExecuteFrameReturnStack`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
