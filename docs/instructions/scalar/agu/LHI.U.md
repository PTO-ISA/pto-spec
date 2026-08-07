# LHI.U

Execute the LHI.U scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/LHI.U.asl -->

## Assembly

```asm
lhi.u [SrcL, simm], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LHI.U.asl -->
```asl
readonly func InstructionContractOperation_LHI_U() => ScalarOperation
begin
    return ScalarOperation_LHI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LHI.U.asl -->
```asl
readonly func InstructionContractHandler_LHI_U() => ScalarSemanticHandler
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
