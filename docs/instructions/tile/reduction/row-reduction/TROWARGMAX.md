# TROWARGMAX

Execute the TROWARGMAX Tile operation contract.

<!-- ASL-SOURCE: asl/tile/reduction/row-reduction/TROWARGMAX.asl -->

## Normative identity {#PTO-INST-TILE-TROWARGMAX}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TROWARGMAX <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TROWARGMAX | TEPL | 0x04C | 12 | 2 | ExecuteTileReduction |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduction/row-reduction/TROWARGMAX.asl -->
```asl
readonly func InstructionContractOperation_TROWARGMAX() => TileOperation
begin
    return TileOperation_TROWARGMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TROWARGMAX, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduction/row-reduction/TROWARGMAX.asl -->
```asl
readonly func InstructionContractHandler_TROWARGMAX() => TileSemanticHandler
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
