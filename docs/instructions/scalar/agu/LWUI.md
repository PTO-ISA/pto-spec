# LWUI

Execute the LWUI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/LWUI.asl -->

## Assembly

```asm
lwui [SrcL, simm], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LWUI.asl -->
```asl
readonly func InstructionContractOperation_LWUI() => ScalarOperation
begin
    return ScalarOperation_LWUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LWUI.asl -->
```asl
readonly func InstructionContractHandler_LWUI() => ScalarSemanticHandler
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
