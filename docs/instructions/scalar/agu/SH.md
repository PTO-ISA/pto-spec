# SH

Execute the SH scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/SH.asl -->

## Assembly

```asm
sh SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<1]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SH.asl -->
```asl
readonly func InstructionContractOperation_SH() => ScalarOperation
begin
    return ScalarOperation_SH;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SH.asl -->
```asl
readonly func InstructionContractHandler_SH() => ScalarSemanticHandler
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
