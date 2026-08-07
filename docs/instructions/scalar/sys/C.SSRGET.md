# C.SSRGET

Execute the C.SSRGET scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/C.SSRGET.asl -->

## Assembly

```asm
c.ssrget SSR-ID, ->t
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/C.SSRGET.asl -->
```asl
readonly func InstructionContractOperation_C_SSRGET() => ScalarOperation
begin
    return ScalarOperation_C_SSRGET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/C.SSRGET.asl -->
```asl
readonly func InstructionContractHandler_C_SSRGET() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompressedSystemRegisterGet;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
