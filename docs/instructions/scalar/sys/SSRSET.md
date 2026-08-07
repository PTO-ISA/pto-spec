# SSRSET

Execute the SSRSET scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/SSRSET.asl -->

## Assembly

```asm
ssrset SrcL, SSR_ID
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/SSRSET.asl -->
```asl
readonly func InstructionContractOperation_SSRSET() => ScalarOperation
begin
    return ScalarOperation_SSRSET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/SSRSET.asl -->
```asl
readonly func InstructionContractHandler_SSRSET() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterSet;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
