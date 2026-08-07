# HL.SSRSET

Execute the HL.SSRSET scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/HL.SSRSET.asl -->

## Assembly

```asm
hl.ssrset SrcL, SSR_ID
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/HL.SSRSET.asl -->
```asl
readonly func InstructionContractOperation_HL_SSRSET() => ScalarOperation
begin
    return ScalarOperation_HL_SSRSET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/HL.SSRSET.asl -->
```asl
readonly func InstructionContractHandler_HL_SSRSET() => ScalarSemanticHandler
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
