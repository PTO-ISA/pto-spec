# B.IOS

Binds one ordered absolute core-private Shared register S0..S255 with a per-PE source/destination size code and four-PE participation mask.

<!-- ASL-SOURCE: asl/block/operands/B.IOS.asl -->

## Assembly

```asm
B.IOS S<SharedTID>, mask=<PE_MASK> | B.IOS mask=<PE_MASK>, ->S<SharedTID><TSize>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/operands/B.IOS.asl -->
```asl
readonly func InstructionContractMatches_B_IOS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_ios_32_4ba5ef98fdaa);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/operands/B.IOS.asl -->
```asl
readonly func InstructionContractHandler_B_IOS() => CommandSemanticHandler
begin
    return CommandHandler_BindBundleSharedIO;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
