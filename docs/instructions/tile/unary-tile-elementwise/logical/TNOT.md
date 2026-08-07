# TNOT

Execute the TNOT Tile operation contract.

<!-- ASL-SOURCE: asl/tile/unary-tile-elementwise/logical/TNOT.asl -->

## Assembly

```asm
TNOT <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/unary-tile-elementwise/logical/TNOT.asl -->
```asl
readonly func InstructionContractOperation_TNOT() => TileOperation
begin
    return TileOperation_TNOT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TNOT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/unary-tile-elementwise/logical/TNOT.asl -->
```asl
readonly func InstructionContractHandler_TNOT() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
