# TROWEXPANDDIV

Execute the TROWEXPANDDIV Tile operation contract.

<!-- ASL-SOURCE: asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDDIV.asl -->

## Normative identity {#PTO-INST-TILE-TROWEXPANDDIV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TROWEXPANDDIV <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TROWEXPANDDIV | TEPL | 0x048 | 8 | 2 | ExecuteTileExpand |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDDIV.asl -->
```asl
readonly func InstructionContractOperation_TROWEXPANDDIV() => TileOperation
begin
    return TileOperation_TROWEXPANDDIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TROWEXPANDDIV, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDDIV.asl -->
```asl
readonly func InstructionContractHandler_TROWEXPANDDIV() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
