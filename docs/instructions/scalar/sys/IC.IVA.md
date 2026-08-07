# IC.IVA

Execute the IC.IVA scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/IC.IVA.asl -->

## Assembly

```asm
ic.iva SrcL
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/IC.IVA.asl -->
```asl
readonly func InstructionContractOperation_IC_IVA() => ScalarOperation
begin
    return ScalarOperation_IC_IVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/IC.IVA.asl -->
```asl
readonly func InstructionContractHandler_IC_IVA() => ScalarSemanticHandler
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
