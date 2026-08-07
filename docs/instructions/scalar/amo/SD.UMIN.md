# SD.UMIN

Execute the SD.UMIN scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/SD.UMIN.asl -->

## Assembly

```asm
sd.umin<.{rl, f, rlf}> [SrcL], SrcR
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SD.UMIN.asl -->
```asl
readonly func InstructionContractOperation_SD_UMIN() => ScalarOperation
begin
    return ScalarOperation_SD_UMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SD.UMIN.asl -->
```asl
readonly func InstructionContractHandler_SD_UMIN() => ScalarSemanticHandler
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
