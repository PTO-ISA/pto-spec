# TROWEXPANDMUL

Execute the TROWEXPANDMUL Tile operation contract.

<!-- ASL-SOURCE: asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDMUL.asl -->

## Assembly

```asm
TROWEXPANDMUL <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDMUL.asl -->
```asl
readonly func InstructionContractOperation_TROWEXPANDMUL() => TileOperation
begin
    return TileOperation_TROWEXPANDMUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TROWEXPANDMUL, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDMUL.asl -->
```asl
readonly func InstructionContractHandler_TROWEXPANDMUL() => TileSemanticHandler
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
