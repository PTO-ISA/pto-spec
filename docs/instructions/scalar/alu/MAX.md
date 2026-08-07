# MAX

Execute the MAX scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/MAX.asl -->

## Assembly

```asm
max SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MAX.asl -->
```asl
readonly func InstructionContractOperation_MAX() => ScalarOperation
begin
    return ScalarOperation_MAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MAX.asl -->
```asl
readonly func InstructionContractHandler_MAX() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
