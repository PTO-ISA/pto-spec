# BSTART.MGATHER.CAS

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/execution/BSTART.MGATHER.CAS.asl -->

## Assembly

```asm
BSTART.MGATHER.CAS DataType
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.MGATHER.CAS.asl -->
```asl
readonly func InstructionContractMatches_BSTART_MGATHER_CAS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mgather_cas_32_fd8c8a3b720a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.MGATHER.CAS.asl -->
```asl
readonly func InstructionContractHandler_BSTART_MGATHER_CAS() => CommandSemanticHandler
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
