# HL.SETRET

Execute the HL.SETRET scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/HL.SETRET.asl -->

## Assembly

```asm
hl.setret imm, ->Ra
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.SETRET.asl -->
```asl
readonly func InstructionContractOperation_HL_SETRET() => ScalarOperation
begin
    return ScalarOperation_HL_SETRET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.SETRET.asl -->
```asl
readonly func InstructionContractHandler_HL_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
