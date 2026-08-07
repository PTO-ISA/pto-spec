# SD.OR

Execute the SD.OR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/SD.OR.asl -->

## Assembly

```asm
sd.or<.{rl, f, rlf}> [SrcL], SrcR
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SD.OR.asl -->
```asl
readonly func InstructionContractOperation_SD_OR() => ScalarOperation
begin
    return ScalarOperation_SD_OR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SD.OR.asl -->
```asl
readonly func InstructionContractHandler_SD_OR() => ScalarSemanticHandler
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
