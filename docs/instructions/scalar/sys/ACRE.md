# ACRE

Execute the ACRE scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/ACRE.asl -->

## Assembly

```asm
acre rra_type
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/ACRE.asl -->
```asl
readonly func InstructionContractOperation_ACRE() => ScalarOperation
begin
    return ScalarOperation_ACRE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/ACRE.asl -->
```asl
readonly func InstructionContractHandler_ACRE() => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureEnterRequest;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
