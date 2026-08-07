# TCOLEXPANDMIN

Execute the TCOLEXPANDMIN Tile operation contract.

<!-- ASL-SOURCE: asl/tile/vector-tile-expansion/column-expansion/TCOLEXPANDMIN.asl -->

## Assembly

```asm
TCOLEXPANDMIN <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/vector-tile-expansion/column-expansion/TCOLEXPANDMIN.asl -->
```asl
readonly func InstructionContractOperation_TCOLEXPANDMIN() => TileOperation
begin
    return TileOperation_TCOLEXPANDMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TCOLEXPANDMIN, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/vector-tile-expansion/column-expansion/TCOLEXPANDMIN.asl -->
```asl
readonly func InstructionContractHandler_TCOLEXPANDMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
