# HL.SHIP

Execute the HL.SHIP scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SHIP.asl -->

## Assembly

```asm
hl.ship SrcD, SrcD1, [SrcR, simm]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SHIP.asl -->
```asl
readonly func InstructionContractOperation_HL_SHIP() => ScalarOperation
begin
    return ScalarOperation_HL_SHIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SHIP.asl -->
```asl
readonly func InstructionContractHandler_HL_SHIP() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
