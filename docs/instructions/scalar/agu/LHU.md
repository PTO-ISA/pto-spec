# LHU

Execute the LHU scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/LHU.asl -->

## Assembly

```asm
lhu [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LHU.asl -->
```asl
readonly func InstructionContractOperation_LHU() => ScalarOperation
begin
    return ScalarOperation_LHU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LHU.asl -->
```asl
readonly func InstructionContractHandler_LHU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
