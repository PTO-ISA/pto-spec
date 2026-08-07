# HL.BFI

Execute the HL.BFI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.BFI.asl -->

## Assembly

```asm
hl.bfi SrcL, SrcR, M, N, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.BFI.asl -->
```asl
readonly func InstructionContractOperation_HL_BFI() => ScalarOperation
begin
    return ScalarOperation_HL_BFI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.BFI.asl -->
```asl
readonly func InstructionContractHandler_HL_BFI() => ScalarSemanticHandler
begin
    return ScalarHandler_InsertBitfield;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
