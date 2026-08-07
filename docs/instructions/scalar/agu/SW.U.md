# SW.U

Execute the SW.U scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/SW.U.asl -->

## Assembly

```asm
sw.u SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SW.U.asl -->
```asl
readonly func InstructionContractOperation_SW_U() => ScalarOperation
begin
    return ScalarOperation_SW_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SW.U.asl -->
```asl
readonly func InstructionContractHandler_SW_U() => ScalarSemanticHandler
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
