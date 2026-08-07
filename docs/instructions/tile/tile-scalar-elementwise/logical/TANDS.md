# TANDS

Execute the TANDS Tile operation contract.

<!-- ASL-SOURCE: asl/tile/tile-scalar-elementwise/logical/TANDS.asl -->

## Assembly

```asm
TANDS <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-elementwise/logical/TANDS.asl -->
```asl
readonly func InstructionContractOperation_TANDS() => TileOperation
begin
    return TileOperation_TANDS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TANDS, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-elementwise/logical/TANDS.asl -->
```asl
readonly func InstructionContractHandler_TANDS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileScalar;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
