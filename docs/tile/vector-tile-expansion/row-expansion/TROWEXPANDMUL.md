<!-- GENERATED FROM: asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDMUL.asl -->
# TROWEXPANDMUL

**Normative ASL source:** `asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDMUL.asl`

Execute the TROWEXPANDMUL Tile operation contract.

## Normative identity {#PTO-INST-TILE-TROWEXPANDMUL}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TROWEXPANDMUL <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TROWEXPANDMUL | TEPL | 0x047 | 7 | 2 | ExecuteTileExpand |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDMUL.asl -->
```asl
readonly func InstructionContractOperation_TROWEXPANDMUL() => TileOperation
begin
    return TileOperation_TROWEXPANDMUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TROWEXPANDMUL, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDMUL.asl -->
```asl
readonly func InstructionContractHandler_TROWEXPANDMUL() => TileSemanticHandler
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
