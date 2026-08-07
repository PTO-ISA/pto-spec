# BSTART.FP

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

<!-- ASL-SOURCE: asl/block/execution/BSTART.FP.asl -->

## Assembly

```asm
BSTART.FP RET
BSTART.FP ICALL
BSTART.FP COND, <label>
BSTART.FP IND
BSTART.FP DIRECT, <label>
BSTART.FP CALL, <label>
BSTART.FP FALL<, fixup_label>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.FP.asl -->
```asl
readonly func InstructionContractMatches_BSTART_FP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_fp_32_0c671a644214) ||
           (operation == CommandOperation_bstart_fp_32_24db3966d6ba) ||
           (operation == CommandOperation_bstart_fp_32_58ad7954fb49) ||
           (operation == CommandOperation_bstart_fp_32_7978795a29a1) ||
           (operation == CommandOperation_bstart_fp_32_d00a708a81f0) ||
           (operation == CommandOperation_bstart_fp_32_dd7bc8dd694c) ||
           (operation == CommandOperation_bstart_fp_32_face4f238d84);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.FP.asl -->
```asl
readonly func InstructionContractHandler_BSTART_FP() => CommandSemanticHandler
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
