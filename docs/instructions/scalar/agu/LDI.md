# LDI

Execute the LDI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/LDI.asl -->

## Assembly

```asm
ldi [SrcL, simm], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LDI.asl -->
```asl
readonly func InstructionContractOperation_LDI() => ScalarOperation
begin
    return ScalarOperation_LDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LDI.asl -->
```asl
readonly func InstructionContractHandler_LDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
