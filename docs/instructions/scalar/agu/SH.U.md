# SH.U

Execute the SH.U scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/SH.U.asl -->

## Assembly

```asm
sh.u SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SH.U.asl -->
```asl
readonly func InstructionContractOperation_SH_U() => ScalarOperation
begin
    return ScalarOperation_SH_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SH.U.asl -->
```asl
readonly func InstructionContractHandler_SH_U() => ScalarSemanticHandler
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
