<!-- GENERATED FROM: asl/block/lifecycle/FRET.RA.asl -->
# FRET.RA

**Normative ASL source:** `asl/block/lifecycle/FRET.RA.asl`

Restores a frame and returns through the retained return-address target.

## Normative identity {#PTO-INST-BLOCK-FRET-RA}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
FRET.RA [RegDst0 ~ RegDstn], sp!, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fret_ra_32_659c886221c1 | L32 | 32 | 0x00002041 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fret_ra_32_659c886221c1 | DstBegin | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fret_ra_32_659c886221c1 | DstEnd | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fret_ra_32_659c886221c1 | uimm | 15 | unsigned | [{"instruction_lsb":25,"value_lsb":3,"width":7},{"instruction_lsb":7,"value_lsb":10,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/FRET.RA.asl -->
```asl
readonly func InstructionContractMatches_FRET_RA(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fret_ra_32_659c886221c1);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/FRET.RA.asl -->
```asl
readonly func InstructionContractHandler_FRET_RA() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameReturnAddress;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
