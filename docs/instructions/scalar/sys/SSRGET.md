# SSRGET

Execute the SSRGET scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/SSRGET.asl -->

## Assembly

```asm
ssrget SSR_ID, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/SSRGET.asl -->
```asl
readonly func InstructionContractOperation_SSRGET() => ScalarOperation
begin
    return ScalarOperation_SSRGET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/SSRGET.asl -->
```asl
readonly func InstructionContractHandler_SSRGET() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterGet;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
