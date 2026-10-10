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
