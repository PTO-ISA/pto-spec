# DC.CIVA

Execute the DC.CIVA scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/DC.CIVA.asl -->

## Assembly

```asm
dc.civa SrcL
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.CIVA.asl -->
```asl
readonly func InstructionContractOperation_DC_CIVA() => ScalarOperation
begin
    return ScalarOperation_DC_CIVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.CIVA.asl -->
```asl
readonly func InstructionContractHandler_DC_CIVA() => ScalarSemanticHandler
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
