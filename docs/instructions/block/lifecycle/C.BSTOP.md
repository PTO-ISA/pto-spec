# C.BSTOP

Commits the current bundle and transfers to its selected continuation.

<!-- ASL-SOURCE: asl/block/lifecycle/C.BSTOP.asl -->

## Assembly

```asm
C.BSTOP
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_bstop_16_ca4743d8a95e | C16 | 16 | 0x0000 / 0xffff | [] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/C.BSTOP.asl -->
```asl
readonly func InstructionContractMatches_C_BSTOP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstop_16_ca4743d8a95e);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/C.BSTOP.asl -->
```asl
readonly func InstructionContractHandler_C_BSTOP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStop;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
