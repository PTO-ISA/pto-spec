# SHI

Execute the SHI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/SHI.asl -->

## Assembly

```asm
shi SrcL, [SrcR, simm]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SHI.asl -->
```asl
readonly func InstructionContractOperation_SHI() => ScalarOperation
begin
    return ScalarOperation_SHI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SHI.asl -->
```asl
readonly func InstructionContractHandler_SHI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
