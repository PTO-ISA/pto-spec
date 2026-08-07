# HL.SHIP.U

Execute the HL.SHIP.U scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.SHIP.U.asl -->

## Assembly

```asm
hl.ship.u SrcD, SrcD1, [SrcR, simm]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SHIP.U.asl -->
```asl
readonly func InstructionContractOperation_HL_SHIP_U() => ScalarOperation
begin
    return ScalarOperation_HL_SHIP_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SHIP.U.asl -->
```asl
readonly func InstructionContractHandler_HL_SHIP_U() => ScalarSemanticHandler
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
