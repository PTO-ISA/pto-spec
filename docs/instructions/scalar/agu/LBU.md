# LBU

Execute the LBU scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/LBU.asl -->

## Assembly

```asm
lbu [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LBU.asl -->
```asl
readonly func InstructionContractOperation_LBU() => ScalarOperation
begin
    return ScalarOperation_LBU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LBU.asl -->
```asl
readonly func InstructionContractHandler_LBU() => ScalarSemanticHandler
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
