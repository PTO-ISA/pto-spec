# SD.SMIN

Execute the SD.SMIN scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/SD.SMIN.asl -->

## Assembly

```asm
sd.smin<.{rl, f, rlf}> [SrcL], SrcR
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SD.SMIN.asl -->
```asl
readonly func InstructionContractOperation_SD_SMIN() => ScalarOperation
begin
    return ScalarOperation_SD_SMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SD.SMIN.asl -->
```asl
readonly func InstructionContractHandler_SD_SMIN() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
