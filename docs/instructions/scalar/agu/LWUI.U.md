# LWUI.U

Execute the LWUI.U scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/LWUI.U.asl -->

## Assembly

```asm
lwui.u [SrcL, simm], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LWUI.U.asl -->
```asl
readonly func InstructionContractOperation_LWUI_U() => ScalarOperation
begin
    return ScalarOperation_LWUI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LWUI.U.asl -->
```asl
readonly func InstructionContractHandler_LWUI_U() => ScalarSemanticHandler
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
