# FEXIT

Atomically validates and commits a frame-template exit state.

<!-- ASL-SOURCE: asl/block/lifecycle/FEXIT.asl -->

## Normative identity {#PTO-INST-BLOCK-FEXIT}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
FEXIT [RegDst0 ~ RegDstn], sp!, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fexit_32_37b663f2a34d | L32 | 32 | 0x00001041 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fexit_32_37b663f2a34d | DstBegin | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fexit_32_37b663f2a34d | DstEnd | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fexit_32_37b663f2a34d | uimm | 15 | unsigned | [{"instruction_lsb":25,"value_lsb":3,"width":7},{"instruction_lsb":7,"value_lsb":10,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/FEXIT.asl -->
```asl
readonly func InstructionContractMatches_FEXIT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fexit_32_37b663f2a34d);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/FEXIT.asl -->
```asl
readonly func InstructionContractHandler_FEXIT() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameExit;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
