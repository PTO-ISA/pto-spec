# TADDS

Execute the TADDS Tile operation contract.

<!-- ASL-SOURCE: asl/tile/tile-scalar-elementwise/arithmetic/TADDS.asl -->

## Assembly

```asm
TADDS <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-elementwise/arithmetic/TADDS.asl -->
```asl
readonly func InstructionContractOperation_TADDS() => TileOperation
begin
    return TileOperation_TADDS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TADDS, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-elementwise/arithmetic/TADDS.asl -->
```asl
readonly func InstructionContractHandler_TADDS() => TileSemanticHandler
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
