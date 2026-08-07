# FCVTA

Execute the FCVTA scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/FCVTA.asl -->

## Assembly

```asm
fcvta.{srcT2dstT} SrcL, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FCVTA.asl -->
```asl
readonly func InstructionContractOperation_FCVTA() => ScalarOperation
begin
    return ScalarOperation_FCVTA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FCVTA.asl -->
```asl
readonly func InstructionContractHandler_FCVTA() => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
