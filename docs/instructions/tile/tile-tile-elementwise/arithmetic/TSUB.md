# TSUB

Execute the TSUB Tile operation contract.

<!-- ASL-SOURCE: asl/tile/tile-tile-elementwise/arithmetic/TSUB.asl -->

## Assembly

```asm
TSUB <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-tile-elementwise/arithmetic/TSUB.asl -->
```asl
readonly func InstructionContractOperation_TSUB() => TileOperation
begin
    return TileOperation_TSUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TSUB, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-tile-elementwise/arithmetic/TSUB.asl -->
```asl
readonly func InstructionContractHandler_TSUB() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
