<!-- GENERATED FROM: asl/block/lifecycle/MSET.asl -->
# MSET

**Normative ASL source:** `asl/block/lifecycle/MSET.asl`

Fills an encoded memory range after complete access preflight.

## Normative identity {#PTO-INST-BLOCK-MSET}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
MSET [RegSrc0, RegSrc1, RegSrc2]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| mset_32_0b932f291932 | L32 | 32 | 0x00001031 / 0x06007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| mset_32_0b932f291932 | RegSrc0 | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| mset_32_0b932f291932 | RegSrc1 | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| mset_32_0b932f291932 | RegSrc2 | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/MSET.asl -->
```asl
readonly func InstructionContractMatches_MSET(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_mset_32_0b932f291932);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/MSET.asl -->
```asl
readonly func InstructionContractHandler_MSET() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteMemorySet;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
