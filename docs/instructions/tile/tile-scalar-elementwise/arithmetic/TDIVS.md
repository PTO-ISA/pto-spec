# TDIVS

Execute the TDIVS Tile operation contract.

<!-- ASL-SOURCE: asl/tile/tile-scalar-elementwise/arithmetic/TDIVS.asl -->

## Assembly

```asm
TDIVS <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-elementwise/arithmetic/TDIVS.asl -->
```asl
readonly func InstructionContractOperation_TDIVS() => TileOperation
begin
    return TileOperation_TDIVS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TDIVS, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-elementwise/arithmetic/TDIVS.asl -->
```asl
readonly func InstructionContractHandler_TDIVS() => TileSemanticHandler
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
