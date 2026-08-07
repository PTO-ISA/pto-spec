# HL.BSTART.FP

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/encoding/HL.BSTART.FP.asl -->

## Assembly

```asm
HL.BSTART.FP COND, <label>
HL.BSTART.FP FALL<, fixup_label>
HL.BSTART.FP CALL, <label>
HL.BSTART.FP DIRECT, <label>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/HL.BSTART.FP.asl -->
```asl
readonly func InstructionContractMatches_HL_BSTART_FP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_bstart_fp_48_038e2e96cf64) ||
           (operation == CommandOperation_hl_bstart_fp_48_43530d2ebfae) ||
           (operation == CommandOperation_hl_bstart_fp_48_81b457553844) ||
           (operation == CommandOperation_hl_bstart_fp_48_eb938e9200eb);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/HL.BSTART.FP.asl -->
```asl
readonly func InstructionContractHandler_HL_BSTART_FP() => CommandSemanticHandler
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
