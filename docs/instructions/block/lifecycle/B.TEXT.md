# B.TEXT

Sets the out-of-line body entry address for a decoupled bundle.

<!-- ASL-SOURCE: asl/block/lifecycle/B.TEXT.asl -->

## Assembly

```asm
B.TEXT <label>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/B.TEXT.asl -->
```asl
readonly func InstructionContractMatches_B_TEXT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_text_32_1ce09f50e5dd);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/B.TEXT.asl -->
```asl
readonly func InstructionContractHandler_B_TEXT() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleBodyAddress;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
