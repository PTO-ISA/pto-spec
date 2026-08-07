# HL.QPUSH

Pushes the encoded scalar values to the selected temporary queue.

<!-- ASL-SOURCE: asl/block/lifecycle/HL.QPUSH.asl -->

## Assembly

```asm
hl.qpush.{h,e,r,he,hr,er,her} SrcL, SrcR, ->{t, u}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/HL.QPUSH.asl -->
```asl
readonly func InstructionContractMatches_HL_QPUSH(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_qpush_48_3eab8e05d61a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/HL.QPUSH.asl -->
```asl
readonly func InstructionContractHandler_HL_QPUSH() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteQueuePush;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
