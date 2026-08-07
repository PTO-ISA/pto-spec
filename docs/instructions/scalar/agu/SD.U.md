# SD.U

Execute the SD.U scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/SD.U.asl -->

## Assembly

```asm
sd.u SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SD.U.asl -->
```asl
readonly func InstructionContractOperation_SD_U() => ScalarOperation
begin
    return ScalarOperation_SD_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SD.U.asl -->
```asl
readonly func InstructionContractHandler_SD_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
