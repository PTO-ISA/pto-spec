# C.BSTART.MSEQ

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/encoding/C.BSTART.MSEQ.asl -->

## Normative identity {#PTO-INST-BLOCK-C-BSTART-MSEQ}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
C.BSTART.MSEQ FALL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_bstart_mseq_16_b5597e0e41c2 | C16 | 16 | 0x48c0 / 0xffff | [] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.MSEQ.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART_MSEQ(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_mseq_16_b5597e0e41c2);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.MSEQ.asl -->
```asl
readonly func InstructionContractHandler_C_BSTART_MSEQ() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
