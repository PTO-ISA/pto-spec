# HL.LUI

Execute the HL.LUI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.LUI.asl -->

## Assembly

```asm
hl.lui imm, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.LUI.asl -->
```asl
readonly func InstructionContractOperation_HL_LUI() => ScalarOperation
begin
    return ScalarOperation_HL_LUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.LUI.asl -->
```asl
readonly func InstructionContractHandler_HL_LUI() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLongSigned;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
