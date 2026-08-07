# B.CATR

Latches bundle control, trap, atomic, ordering, and address-class attributes.

<!-- ASL-SOURCE: asl/block/attributes/B.CATR.asl -->

## Assembly

```asm
B.CATR {trap, atomic, <aq, rl, aqrl>, far, dr}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/B.CATR.asl -->
```asl
readonly func InstructionContractMatches_B_CATR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_catr_32_e90bd52fa480);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/B.CATR.asl -->
```asl
readonly func InstructionContractHandler_B_CATR() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleControlAttributes;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
