# SD.SMAX

Execute the SD.SMAX scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/SD.SMAX.asl -->

## Assembly

```asm
sd.smax<.{rl, f, rlf}> [SrcL], SrcR
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SD.SMAX.asl -->
```asl
readonly func InstructionContractOperation_SD_SMAX() => ScalarOperation
begin
    return ScalarOperation_SD_SMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SD.SMAX.asl -->
```asl
readonly func InstructionContractHandler_SD_SMAX() => ScalarSemanticHandler
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
