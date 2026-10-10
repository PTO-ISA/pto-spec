<!-- GENERATED FROM: asl/tile/model/shape/cube-double-cell.asl -->
# CUBE Double Cell

**Normative ASL source:** `asl/tile/model/shape/cube-double-cell.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-SHAPE-CUBE-DOUBLE-CELL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-shape-cube-double-cell-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the double-CELL representation used by Local `CUBE_M32` Tiles whose element type is `FP64`, `S64`, or `U64`. It preserves 32 logical rows and one 64-bit `Word` per logical element while charging two ordered 128-byte CELLs for each logical column.

<!-- PTO-READER-BLOCK: tile-model-shape-cube-double-cell-concepts role=concepts-state -->
## Concepts and visible state

For logical column `c`, physical CELL `2*c` stores the low 32-bit word for rows 0 through 31 and CELL `2*c+1` stores the high 32-bit word for the same rows. Within either CELL, the word index is the logical row. One logical column therefore occupies 256 bytes.

The Tile payload remains logical: `TileCubeM32B64PayloadIndex(row, column)` selects one 64-bit element at `column * 32 + row`. The paired CELLs describe physical storage, transport, subviews, and generation ranges; they do not split the architectural element into two payload elements.

<!-- PTO-READER-BLOCK: tile-model-shape-cube-double-cell-rules role=rules-interactions -->
## Rules and interactions

`TileCubeLayoutDataTypeSupported` admits 64-bit elements only for `CUBE_M32` with `FP64`, `S64`, or `U64`, while retaining the separate `CUBE_N8/U64` exception. `CUBE_M16` remains illegal for every 64-bit type.

`TileCubePhysicalCellsPerLogicalGroup` returns two for the M32 64-bit forms and one otherwise. Physical offsets and counts must therefore begin and end on complete pairs. Helpers convert complete physical CELL counts back to logical column groups and map a row and column to the low or high plane's byte offset.

Raw helpers extract or replace one 32-bit half of a 64-bit value. They support word-oriented pack, unpack, shuffle, transport, and mask paths without changing the rule that ordinary operations mask one whole logical 64-bit element.

<!-- PTO-READER-BLOCK: tile-model-shape-cube-double-cell-boundaries role=boundaries -->
## Architectural boundaries

This unit defines geometry and raw half-word access only. Operation-kind legality still decides whether `FP64`, `S64`, `U64`, or a raw b64 carrier applies. Matrix/MX type sets, fixed-width atomics, narrow conversion tuples, and `TGPR2T` keep their own exclusions.

Subview, generation, transport, and publication boundaries may not expose only one CELL of a pair. The existing raw pack/unpack per-word mask exception may gate the low and high raw words separately; other ExecutionMask consumers use one activity bit for the complete 64-bit logical element.

<!-- PTO-READER-BLOCK: tile-model-shape-cube-double-cell-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative rule.

A `CUBE_M32 U64` Tile with two logical columns has four physical CELLs and needs 512 bytes. CELLs 0 and 1 are the low and high planes of column 0; CELLs 2 and 3 are the planes of column 1. Row 7, column 1 is one logical 64-bit payload value, with its low half at CELL 2 word 7 and high half at CELL 3 word 7.

<!-- PTO-READER-BLOCK: tile-model-shape-cube-double-cell-related role=related-owners-navigation -->
## Related owners

- [CUBE cell geometry](cube-cell.md) derives descriptor counts and capacity from the pairing factor.
- [Data-type and layout legality](../legality/dtype-layout.md) defines operation applicability.
- [Subview descriptor](../../../block/model/operands/subview-descriptor.md) requires complete pair ranges.
- [Local CUBE generation](../../../block/model/operands/local-generation-cube.md) finalizes paired writer extents.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/shape/cube-double-cell.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-SHAPE-CUBE-DOUBLE-CELL","surface":"tile","classification":["model","shape","cube-double-cell"],"depends_on":["PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES","PTO-ARCH-FEATURES-TILE-ALLOCATION"]}
// NDF-BEGIN: PTO-CUBE-M32-B64-DOUBLE-CELL-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Local CUBE_M32 FP64, S64, and U64 storage MUST retain 32 logical rows and
// one Word payload per logical element while charging two ordered 128-byte
// CELLs per logical column. CELL 2*c carries low words and CELL 2*c+1 carries
// high words, with word index equal to row. Views and publications MUST begin
// and end on complete pairs; M16 b64 remains illegal and N8/U64 is unchanged.
// NDF-END: PTO-CUBE-M32-B64-DOUBLE-CELL-001

pure func TileLayoutIsCube(layout: TileLayout) => boolean
begin
    return layout == TileLayout_CUBE_M16 ||
           layout == TileLayout_CUBE_M32 ||
           layout == TileLayout_CUBE_N8;
end;

pure func TileCubeM32B64DataType(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP64 ||
           data_type == TileDataType_S64 ||
           data_type == TileDataType_U64;
end;

pure func TileCubeDataTypeSupported(data_type: TileDataType) => boolean
begin
    return TileElementBits(data_type) != 64 ||
           TileCubeM32B64DataType(data_type);
end;

pure func TileCubeLayoutDataTypeSupported(
    layout: TileLayout, data_type: TileDataType) => boolean
begin
    if TileElementBits(data_type) != 64 then
        return TileCubeDataTypeSupported(data_type);
    end;
    return (layout == TileLayout_CUBE_M32 &&
            TileCubeM32B64DataType(data_type)) ||
           (layout == TileLayout_CUBE_N8 &&
            data_type == TileDataType_U64);
end;

pure func TileCubePhysicalCellsPerLogicalGroup(
    layout: TileLayout, data_type: TileDataType) => integer {1..2}
begin
    if layout == TileLayout_CUBE_M32 &&
       TileCubeM32B64DataType(data_type) then return 2; end;
    return 1;
end;

pure func TileCubePhysicalCellRangeComplete(
    layout: TileLayout, data_type: TileDataType,
    offset_cells: integer, cell_count: integer) => boolean
begin
    let factor = TileCubePhysicalCellsPerLogicalGroup(layout, data_type);
    return offset_cells >= 0 && cell_count > 0 &&
           offset_cells MOD factor == 0 && cell_count MOD factor == 0;
end;

pure func TileCubeLogicalGroupsForPhysicalCells(
    layout: TileLayout, data_type: TileDataType,
    cell_count: integer) => integer
begin
    let factor = TileCubePhysicalCellsPerLogicalGroup(layout, data_type);
    assert cell_count >= 0 && cell_count MOD factor == 0;
    return cell_count DIVRM factor;
end;

pure func TileCubeM32B64PlaneCellIndex(
    column: integer {0..1023}, high_plane: boolean) => integer {0..2047}
begin
    return (column * 2 + (if high_plane then 1 else 0))
        as integer {0..2047};
end;

pure func TileCubeM32DoubleCellIndex(
    column: integer {0..8191}, high_plane: boolean) => integer {0..16383}
begin
    return (column * 2 + (if high_plane then 1 else 0))
        as integer {0..16383};
end;

pure func TileCubeM32B64PlaneWordIndex(
    row: integer {0..31}) => integer {0..31}
begin
    return row;
end;

pure func TileCubeM32DoubleCellWord(
    row: integer {0..31}) => integer {0..31}
begin
    return row;
end;

pure func TileCubeM32DoubleCellLogical(
    cell: integer {0..16383}, word: integer {0..31})
    => (integer {0..8191}, integer {0..31}, boolean)
begin
    return ((cell DIVRM 2) as integer {0..8191}, word, cell MOD 2 == 1);
end;

pure func TileCubeM32B64PlaneByteOffset(
    row: integer {0..31}, column: integer {0..1023},
    high_plane: boolean) => integer {0..262143}
begin
    return (TileCubeM32B64PlaneCellIndex(column, high_plane) *
            PTO_TILE_CELL_BYTES + TileCubeM32B64PlaneWordIndex(row) * 4)
        as integer {0..262143};
end;

pure func TileCubeM32B64RawPlaneWord(
    value: Word, high_plane: boolean) => bits(32)
begin
    return if high_plane then value[63:32] else value[31:0];
end;

pure func TileCubeM32B64WithRawPlaneWord(
    value: Word, raw: bits(32), high_plane: boolean) => Word
begin
    var result = value;
    if high_plane then result[63:32] = raw;
    else result[31:0] = raw;
    end;
    return result;
end;

pure func TileCubeM32B64PayloadIndex(
    row: integer {0..31}, column: integer {0..1023})
    => integer {0..32767}
begin
    return (column * 32 + row) as integer {0..32767};
end;
```
<!-- GENERATED-ASL-END: unit -->
