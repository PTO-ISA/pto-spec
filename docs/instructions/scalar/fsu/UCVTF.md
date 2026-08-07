# UCVTF

Execute the UCVTF scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/UCVTF.asl -->

## Assembly

```asm
ucvtf.{srcT2dstT} SrcL, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/UCVTF.asl -->
```asl
readonly func InstructionContractOperation_UCVTF() => ScalarOperation
begin
    return ScalarOperation_UCVTF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/UCVTF.asl -->
```asl
readonly func InstructionContractHandler_UCVTF() => ScalarSemanticHandler
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
