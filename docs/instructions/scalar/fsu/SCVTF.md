# SCVTF

Execute the SCVTF scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/SCVTF.asl -->

## Assembly

```asm
scvtf.{srcT2dstT} SrcL, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/SCVTF.asl -->
```asl
readonly func InstructionContractOperation_SCVTF() => ScalarOperation
begin
    return ScalarOperation_SCVTF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/SCVTF.asl -->
```asl
readonly func InstructionContractHandler_SCVTF() => ScalarSemanticHandler
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
