# BSTART.STD

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/execution/BSTART.STD.asl -->

## Assembly

```asm
BSTART.STD COND, <label>
BSTART.STD ICALL
BSTART.STD FALL<, fixup_label>
BSTART.STD RET
BSTART.STD IND
BSTART.STD CALL, <label>
BSTART.STD DIRECT, <label>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.STD.asl -->
```asl
readonly func InstructionContractMatches_BSTART_STD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_std_32_1ef99c4cedcb) ||
           (operation == CommandOperation_bstart_std_32_3f6980d013f7) ||
           (operation == CommandOperation_bstart_std_32_441ad677fffe) ||
           (operation == CommandOperation_bstart_std_32_816dfa76cc4a) ||
           (operation == CommandOperation_bstart_std_32_986b7ee2cf6a) ||
           (operation == CommandOperation_bstart_std_32_b05390d367cf) ||
           (operation == CommandOperation_bstart_std_32_c1de85e06878);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.STD.asl -->
```asl
readonly func InstructionContractHandler_BSTART_STD() => CommandSemanticHandler
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
