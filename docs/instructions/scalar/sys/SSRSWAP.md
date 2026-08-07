# SSRSWAP

Execute the SSRSWAP scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/SSRSWAP.asl -->

## Assembly

```asm
ssrswap SrcL, SSR_ID, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/SSRSWAP.asl -->
```asl
readonly func InstructionContractOperation_SSRSWAP() => ScalarOperation
begin
    return ScalarOperation_SSRSWAP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/SSRSWAP.asl -->
```asl
readonly func InstructionContractHandler_SSRSWAP() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterSwap;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
