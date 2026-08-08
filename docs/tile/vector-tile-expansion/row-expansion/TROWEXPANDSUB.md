<!-- GENERATED FROM: asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDSUB.asl -->
# TROWEXPANDSUB

**Normative ASL source:** `asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDSUB.asl`

Execute the TROWEXPANDSUB Tile operation contract.

## Normative identity {#PTO-INST-TILE-TROWEXPANDSUB}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TROWEXPANDSUB <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TROWEXPANDSUB | TEPL | 0x046 | 6 | 2 | ExecuteTileExpand |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDSUB.asl -->
```asl
readonly func InstructionContractOperation_TROWEXPANDSUB() => TileOperation
begin
    return TileOperation_TROWEXPANDSUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TROWEXPANDSUB, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDSUB.asl -->
```asl
readonly func InstructionContractHandler_TROWEXPANDSUB() => TileSemanticHandler
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
