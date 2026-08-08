<!-- GENERATED FROM: asl/tile/vector-tile-expansion/column-expansion/TCOLEXPANDDIV.asl -->
# TCOLEXPANDDIV

**Normative ASL source:** `asl/tile/vector-tile-expansion/column-expansion/TCOLEXPANDDIV.asl`

Execute the TCOLEXPANDDIV Tile operation contract.

## Normative identity {#PTO-INST-TILE-TCOLEXPANDDIV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TCOLEXPANDDIV <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCOLEXPANDDIV | TEPL | 0x058 | 24 | 2 | ExecuteTileExpand |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/vector-tile-expansion/column-expansion/TCOLEXPANDDIV.asl -->
```asl
readonly func InstructionContractOperation_TCOLEXPANDDIV() => TileOperation
begin
    return TileOperation_TCOLEXPANDDIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TCOLEXPANDDIV, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/vector-tile-expansion/column-expansion/TCOLEXPANDDIV.asl -->
```asl
readonly func InstructionContractHandler_TCOLEXPANDDIV() => TileSemanticHandler
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
