# DMA

Execute the DMA scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/amo/DMA.asl -->

## Assembly

```asm
dma [SrcL], SrcR
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/DMA.asl -->
```asl
readonly func InstructionContractOperation_DMA() => ScalarOperation
begin
    return ScalarOperation_DMA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/DMA.asl -->
```asl
readonly func InstructionContractHandler_DMA() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDMACopy64;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
