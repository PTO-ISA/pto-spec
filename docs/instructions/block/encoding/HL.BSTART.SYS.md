# HL.BSTART.SYS

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/encoding/HL.BSTART.SYS.asl -->

## Assembly

```asm
HL.BSTART.SYS FALL<, fixup_label>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/HL.BSTART.SYS.asl -->
```asl
readonly func InstructionContractMatches_HL_BSTART_SYS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_bstart_sys_48_5bf0381f7bf8);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/HL.BSTART.SYS.asl -->
```asl
readonly func InstructionContractHandler_HL_BSTART_SYS() => CommandSemanticHandler
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
