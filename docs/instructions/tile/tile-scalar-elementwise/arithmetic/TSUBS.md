# TSUBS

Execute the TSUBS Tile operation contract.

<!-- ASL-SOURCE: asl/tile/tile-scalar-elementwise/arithmetic/TSUBS.asl -->

## Assembly

```asm
TSUBS <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-elementwise/arithmetic/TSUBS.asl -->
```asl
readonly func InstructionContractOperation_TSUBS() => TileOperation
begin
    return TileOperation_TSUBS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TSUBS, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-elementwise/arithmetic/TSUBS.asl -->
```asl
readonly func InstructionContractHandler_TSUBS() => TileSemanticHandler
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
