# FCVTP

Execute the FCVTP scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/FCVTP.asl -->

## Assembly

```asm
fcvtp.{srcT2dstT} SrcL, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FCVTP.asl -->
```asl
readonly func InstructionContractOperation_FCVTP() => ScalarOperation
begin
    return ScalarOperation_FCVTP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FCVTP.asl -->
```asl
readonly func InstructionContractHandler_FCVTP() => ScalarSemanticHandler
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
