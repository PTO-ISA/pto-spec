# TSORT

Execute the TSORT Tile operation contract.

<!-- ASL-SOURCE: asl/tile/complex-layout/sorting/TSORT.asl -->

## Assembly

```asm
TSORT <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/complex-layout/sorting/TSORT.asl -->
```asl
readonly func InstructionContractOperation_TSORT() => TileOperation
begin
    return TileOperation_TSORT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TSORT, DataType
B.DIM sort_width -> LB0
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/complex-layout/sorting/TSORT.asl -->
```asl
readonly func InstructionContractHandler_TSORT() => TileSemanticHandler
begin
    return TileHandler_TSORT;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
