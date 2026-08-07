# HL.BSTART.STD

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/encoding/HL.BSTART.STD.asl -->

## Assembly

```asm
HL.BSTART.STD CALL, <label>
HL.BSTART.STD FALL<, fixup_label>
HL.BSTART.STD COND, <label>
HL.BSTART.STD DIRECT, <label>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/HL.BSTART.STD.asl -->
```asl
readonly func InstructionContractMatches_HL_BSTART_STD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_bstart_std_48_51f78942222e) ||
           (operation == CommandOperation_hl_bstart_std_48_9ba705800872) ||
           (operation == CommandOperation_hl_bstart_std_48_b13f22c7c4a3) ||
           (operation == CommandOperation_hl_bstart_std_48_d814d26508a4);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/HL.BSTART.STD.asl -->
```asl
readonly func InstructionContractHandler_HL_BSTART_STD() => CommandSemanticHandler
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
