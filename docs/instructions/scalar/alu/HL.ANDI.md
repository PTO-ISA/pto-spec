# HL.ANDI

Execute the HL.ANDI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.ANDI.asl -->

## Assembly

```asm
hl.andi SrcL, simm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ANDI.asl -->
```asl
readonly func InstructionContractOperation_HL_ANDI() => ScalarOperation
begin
    return ScalarOperation_HL_ANDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ANDI.asl -->
```asl
readonly func InstructionContractHandler_HL_ANDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
