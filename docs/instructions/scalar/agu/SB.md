# SB

Execute the SB scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/SB.asl -->

## Assembly

```asm
sb SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SB.asl -->
```asl
readonly func InstructionContractOperation_SB() => ScalarOperation
begin
    return ScalarOperation_SB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SB.asl -->
```asl
readonly func InstructionContractHandler_SB() => ScalarSemanticHandler
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
