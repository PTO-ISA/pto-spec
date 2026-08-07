# TLB.IALL

Execute the TLB.IALL scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/TLB.IALL.asl -->

## Assembly

```asm
tlb.iall
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/TLB.IALL.asl -->
```asl
readonly func InstructionContractOperation_TLB_IALL() => ScalarOperation
begin
    return ScalarOperation_TLB_IALL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/TLB.IALL.asl -->
```asl
readonly func InstructionContractHandler_TLB_IALL() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
