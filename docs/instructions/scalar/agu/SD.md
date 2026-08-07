# SD

Execute the SD scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/SD.asl -->

## Assembly

```asm
sd SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<3]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SD.asl -->
```asl
readonly func InstructionContractOperation_SD() => ScalarOperation
begin
    return ScalarOperation_SD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SD.asl -->
```asl
readonly func InstructionContractHandler_SD() => ScalarSemanticHandler
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
