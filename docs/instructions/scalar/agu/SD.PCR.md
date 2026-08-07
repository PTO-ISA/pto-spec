# SD.PCR

Execute the SD.PCR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/SD.PCR.asl -->

## Assembly

```asm
sd.pcr SrcL, [symbol]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SD.PCR.asl -->
```asl
readonly func InstructionContractOperation_SD_PCR() => ScalarOperation
begin
    return ScalarOperation_SD_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SD.PCR.asl -->
```asl
readonly func InstructionContractHandler_SD_PCR() => ScalarSemanticHandler
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
