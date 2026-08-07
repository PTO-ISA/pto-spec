# L.BSTART.STD

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/encoding/L.BSTART.STD.asl -->

## Assembly

```asm
L.BSTART.STD DIRECT, <label>
L.BSTART.STD CALL, <label>
L.BSTART.STD COND, <label>
L.BSTART.STD FALL<, fixup_label>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/L.BSTART.STD.asl -->
```asl
readonly func InstructionContractMatches_L_BSTART_STD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_l_bstart_std_64_37e84068ce61) ||
           (operation == CommandOperation_l_bstart_std_64_463a1567da91) ||
           (operation == CommandOperation_l_bstart_std_64_72d502fcd30d) ||
           (operation == CommandOperation_l_bstart_std_64_899592f9c5bc);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/L.BSTART.STD.asl -->
```asl
readonly func InstructionContractHandler_L_BSTART_STD() => CommandSemanticHandler
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
