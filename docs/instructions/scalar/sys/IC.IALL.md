# IC.IALL

Execute the IC.IALL scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/IC.IALL.asl -->

## Assembly

```asm
ic.iall
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/IC.IALL.asl -->
```asl
readonly func InstructionContractOperation_IC_IALL() => ScalarOperation
begin
    return ScalarOperation_IC_IALL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/IC.IALL.asl -->
```asl
readonly func InstructionContractHandler_IC_IALL() => ScalarSemanticHandler
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
