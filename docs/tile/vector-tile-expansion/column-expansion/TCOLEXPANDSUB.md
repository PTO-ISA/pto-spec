<!-- GENERATED FROM: asl/tile/vector-tile-expansion/column-expansion/TCOLEXPANDSUB.asl -->
# TCOLEXPANDSUB

**Normative ASL source:** `asl/tile/vector-tile-expansion/column-expansion/TCOLEXPANDSUB.asl`

Execute the TCOLEXPANDSUB Tile operation contract.

## Normative identity {#PTO-INST-TILE-TCOLEXPANDSUB}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TCOLEXPANDSUB <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCOLEXPANDSUB | TEPL | 0x056 | 22 | 2 | ExecuteTileExpand |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/vector-tile-expansion/column-expansion/TCOLEXPANDSUB.asl -->
```asl
readonly func InstructionContractOperation_TCOLEXPANDSUB() => TileOperation
begin
    return TileOperation_TCOLEXPANDSUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Block composition

```asm
BSTART.TEPL TCOLEXPANDSUB, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/vector-tile-expansion/column-expansion/TCOLEXPANDSUB.asl -->
```asl
readonly func InstructionContractHandler_TCOLEXPANDSUB() => TileSemanticHandler
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
