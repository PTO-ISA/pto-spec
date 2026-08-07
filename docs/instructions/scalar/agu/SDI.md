# SDI

Execute the SDI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/SDI.asl -->

## Assembly

```asm
sdi SrcL, [SrcR, simm]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SDI.asl -->
```asl
readonly func InstructionContractOperation_SDI() => ScalarOperation
begin
    return ScalarOperation_SDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SDI.asl -->
```asl
readonly func InstructionContractHandler_SDI() => ScalarSemanticHandler
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
