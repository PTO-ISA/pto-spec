# C.CMP.NEI

Execute the C.CMP.NEI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/C.CMP.NEI.asl -->

## Assembly

```asm
c.cmp.nei t#1, simm, ->t
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/C.CMP.NEI.asl -->
```asl
readonly func InstructionContractOperation_C_CMP_NEI() => ScalarOperation
begin
    return ScalarOperation_C_CMP_NEI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/C.CMP.NEI.asl -->
```asl
readonly func InstructionContractHandler_C_CMP_NEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
