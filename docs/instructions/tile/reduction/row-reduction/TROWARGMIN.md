# TROWARGMIN

Execute the TROWARGMIN Tile operation contract.

<!-- ASL-SOURCE: asl/tile/reduction/row-reduction/TROWARGMIN.asl -->

## Assembly

```asm
TROWARGMIN <bundle operands>
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduction/row-reduction/TROWARGMIN.asl -->
```asl
readonly func InstructionContractOperation_TROWARGMIN() => TileOperation
begin
    return TileOperation_TROWARGMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TROWARGMIN, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduction/row-reduction/TROWARGMIN.asl -->
```asl
readonly func InstructionContractHandler_TROWARGMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
