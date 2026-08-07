# TRELU

Execute the TRELU Tile operation contract.

<!-- ASL-SOURCE: asl/tile/unary-tile-elementwise/logical/TRELU.asl -->

## Assembly

```asm
TRELU <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/unary-tile-elementwise/logical/TRELU.asl -->
```asl
readonly func InstructionContractOperation_TRELU() => TileOperation
begin
    return TileOperation_TRELU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TRELU, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/unary-tile-elementwise/logical/TRELU.asl -->
```asl
readonly func InstructionContractHandler_TRELU() => TileSemanticHandler
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
