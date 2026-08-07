# HL.PRF

Execute the HL.PRF scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.PRF.asl -->

## Assembly

```asm
hl.prf{.l1,.l2,.l3} [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.PRF.asl -->
```asl
readonly func InstructionContractOperation_HL_PRF() => ScalarOperation
begin
    return ScalarOperation_HL_PRF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.PRF.asl -->
```asl
readonly func InstructionContractHandler_HL_PRF() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
