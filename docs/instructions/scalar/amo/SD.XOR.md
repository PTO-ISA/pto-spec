# SD.XOR

Execute the SD.XOR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/SD.XOR.asl -->

## Assembly

```asm
sd.xor<.{rl, f, rlf}> [SrcL], SrcR
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SD.XOR.asl -->
```asl
readonly func InstructionContractOperation_SD_XOR() => ScalarOperation
begin
    return ScalarOperation_SD_XOR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SD.XOR.asl -->
```asl
readonly func InstructionContractHandler_SD_XOR() => ScalarSemanticHandler
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
