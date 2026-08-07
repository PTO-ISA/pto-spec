# ACRC

Execute the ACRC scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/ACRC.asl -->

## Assembly

```asm
acrc rst_type
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/ACRC.asl -->
```asl
readonly func InstructionContractOperation_ACRC() => ScalarOperation
begin
    return ScalarOperation_ACRC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/ACRC.asl -->
```asl
readonly func InstructionContractHandler_ACRC() => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureCloseRequest;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
