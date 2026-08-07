# TQUANT

Execute the TQUANT Tile operation contract.

<!-- ASL-SOURCE: asl/tile/complex-layout/format-conversion/TQUANT.asl -->

## Assembly

```asm
TQUANT <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/format-conversion/TQUANT.asl -->
```asl
readonly func InstructionContractOperation_TQUANT() => TileOperation
begin
    return TileOperation_TQUANT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TQUANT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/format-conversion/TQUANT.asl -->
```asl
readonly func InstructionContractHandler_TQUANT() => TileSemanticHandler
begin
    return TileHandler_TQUANT;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
