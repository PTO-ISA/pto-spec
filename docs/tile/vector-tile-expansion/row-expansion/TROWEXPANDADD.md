<!-- GENERATED FROM: asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDADD.asl -->
# TROWEXPANDADD

**Normative ASL source:** `asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDADD.asl`

Execute the TROWEXPANDADD Tile operation contract.

## Normative identity {#PTO-INST-TILE-TROWEXPANDADD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TROWEXPANDADD <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TROWEXPANDADD | TEPL | 0x045 | 5 | 2 | ExecuteTileExpand |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDADD.asl -->
```asl
readonly func InstructionContractOperation_TROWEXPANDADD() => TileOperation
begin
    return TileOperation_TROWEXPANDADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TROWEXPANDADD, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDADD.asl -->
```asl
readonly func InstructionContractHandler_TROWEXPANDADD() => TileSemanticHandler
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
