# HL.QMT

Moves values between scalar temporary queues according to encoded queue controls.

<!-- ASL-SOURCE: asl/block/lifecycle/HL.QMT.asl -->

## Assembly

```asm
hl.qmt.{i,e,s,r,ie,is,ir,es,er,ies,ier} SrcL, SrcR, ->{t, u}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/HL.QMT.asl -->
```asl
readonly func InstructionContractMatches_HL_QMT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_qmt_48_eb9e41958045);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/HL.QMT.asl -->
```asl
readonly func InstructionContractHandler_HL_QMT() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteQueueMove;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
