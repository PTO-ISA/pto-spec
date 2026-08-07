# TSQRT

Execute the TSQRT Tile operation contract.

<!-- ASL-SOURCE: asl/tile/unary-tile-elementwise/transcendental/TSQRT.asl -->

## Assembly

```asm
TSQRT <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/unary-tile-elementwise/transcendental/TSQRT.asl -->
```asl
readonly func InstructionContractOperation_TSQRT() => TileOperation
begin
    return TileOperation_TSQRT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TSQRT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/unary-tile-elementwise/transcendental/TSQRT.asl -->
```asl
readonly func InstructionContractHandler_TSQRT() => TileSemanticHandler
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
