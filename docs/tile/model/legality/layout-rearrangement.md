<!-- GENERATED FROM: asl/tile/model/legality/layout-rearrangement.asl -->
# Layout Rearrangement

**Normative ASL source:** `asl/tile/model/legality/layout-rearrangement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-layout-rearrangement-purpose role=purpose-scope -->
## Purpose and scope

This unit holds the operand legality predicates for the four CUBE cell rearrangement instructions: `TileOperandsLegal_TPERMUTE`, `TileOperandsLegal_TSHUF`, `TileOperandsLegal_TPACK`, and `TileOperandsLegal_TUNPACK`. Each instruction's `InstructionContractOperandsLegal_*` returns its predicate, and its catalog record names the predicate as `legality_handler`.

A legality predicate is a read-only check. It inspects descriptors, types, control fields, and element definedness, and it returns FALSE instead of changing state. The model execution functions in the rearrangement execution unit assert the same predicate before they build a result, so no destination byte is written for an operand set that fails it.

The unit also owns byte-level helpers that the execution unit reuses, such as `TileReadCellByte`, `TileCellRearrangementRowBytes`, and `TileCellRearrangementWordsPerRow`.

<!-- PTO-READER-BLOCK: tile-model-legality-layout-rearrangement-concepts role=concepts-state -->
## Concepts and visible state

A CUBE layout stores a Tile as cells. These instructions accept only `CUBE_M16` and `CUBE_M32` (`TileCellRearrangementLayoutLegal`). `TileCellRearrangementDescriptorLegal` also requires `TileCubeDescriptorLegal`, so the recorded cell geometry must match the shape.

- Cell row bytes: `TileCellRearrangementRowBytes` is 8 for `CUBE_M16` and 4 for `CUBE_M32`.
- Valid bytes of a row: `valid_columns` times the element width in bits, rounded up to whole bytes.
- Raw words of a row: the valid bytes rounded up to whole 32-bit words.
- Byte definedness: a byte is defined only if it lies inside the valid columns and every element that contributes bits to it is defined. For four-bit types, both nibbles of the byte are checked when both are inside the valid columns.

The scalar control word read by `TSHUF`, `TPACK`, and `TUNPACK` must have bits `[63:32]` equal to zero (`TileRearrangementControlWordLegal`).

<!-- PTO-READER-BLOCK: tile-model-legality-layout-rearrangement-rules role=rules-interactions -->
## Rules and interactions

`TPERMUTE` checks four Tiles: destination, `source0`, `source1`, and a U8 index Tile. All use the same layout. The data Tiles share one type and one valid shape, and the type is not 64-bit. The index Tile has the same valid rows, one column per valid destination byte, and the same cell count. For each active destination byte, the index byte must be defined and below twice the cell row bytes. An index below the row bytes selects `source0`, otherwise `source1`, and the selected source byte must be defined.

Design point: the index selects a byte inside the same cell row segment of the same row, because the source byte is the segment base plus the selected offset. A byte therefore cannot move to another row or another segment, and an index of 16 or more under `CUBE_M16` is illegal rather than wrapped.

`TSHUF` checks a data source, a U32 control Tile, and the control word. Bits `[7:0]` are the mode (0 to 3), bits `[15:8]` the segment code (0 to 4, widths 2, 4, 8, 16, 32), and bits `[23:16]` the boundary flag (0 or 1). Segment code 4 is legal only for `CUBE_M32`. For each active element, the controlling U32 word must be defined, and the source element that will actually be read must be defined.

`TPACK` and `TUNPACK` need numeric sources whose type is 8, 16, or 32 bits wide, and a destination of type U8, U16, or U32. The destination valid columns must equal the raw word count times the destination elements per word. `TPACK` takes 1 to 3 low bytes from each word of each source, at most 4 in total. `TUNPACK` takes a field at byte offset 0 to 3 with count 1 to 4 that ends by byte 4.

Design point: definedness is checked only for bytes the operation will read. An undefined byte that no index or control selects does not make the operation illegal.

<!-- PTO-READER-BLOCK: tile-model-legality-layout-rearrangement-boundaries role=boundaries -->
## Architectural boundaries

When an ExecutionMask is in force, the per-byte and per-element checks run only at active coordinates. `TPACK` and `TUNPACK` query the mask at `(row, word_index)`. One exception: the `TUNPACK` span rule, which requires offset plus count to fit in each word's valid bytes, is checked for every word, active or not.

The destination must be a different register from each data source, and `TSHUF` also requires it to differ from the control Tile. `TPERMUTE` requires the index Tile to differ from both data sources, but `source0` and `source1` may be the same Tile.

Bundle dispatch applies part of these rules earlier. `ResolveBundleCellRearrangementDestination` checks the source descriptors and the `TPACK`/`TUNPACK` source types and raises `Fault_TileLegality` before it allocates the destination.

`TileCellRearrangementValidRegionDefined` is defined here, but a search of `asl/` finds no caller.

<!-- PTO-READER-BLOCK: tile-model-legality-layout-rearrangement-example role=example-usage -->
## Non-normative reading example

Consider `TPERMUTE` with U8 data in `CUBE_M16`, valid shape 16 rows by 8 columns.

- Each row has 8 valid bytes, and the cell row bytes are 8, so the index Tile needs 8 valid columns.
- Legal index values are 0 to 15.
- Destination row 5, byte 2 with index 3 reads byte 3 of row 5 in `source0`.
- The same position with index 11 reads byte 3 of row 5 in `source1`.
- Any active index of 16 makes the predicate FALSE, and no destination byte is written.

<!-- PTO-READER-BLOCK: tile-model-legality-layout-rearrangement-related role=related-owners-navigation -->
## Related owners

- [Rearrangement execution](../execution/rearrangement.md) runs the four operations after these checks.
- [CUBE cell geometry](../shape/cube-cell.md) owns cell rows, cell columns, and cell counts.
- [Descriptor shape](descriptor-shape.md) owns `TileCubeDescriptorLegal`.
- [Cell rearrangement schema](../../../block/model/dispatch/cell-rearrangement-schema.md) owns the bundle-side destination checks.
- [TPERMUTE](../../layout-and-rearrangement/layout/TPERMUTE.md), [TSHUF](../../layout-and-rearrangement/layout/TSHUF.md), [TPACK](../../layout-and-rearrangement/layout/TPACK.md), and [TUNPACK](../../layout-and-rearrangement/layout/TUNPACK.md) are the instruction pages.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/layout-rearrangement.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT","surface":"tile","classification":["model","legality","layout-rearrangement"],"depends_on":["PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}

pure func TileCellRearrangementLayoutLegal(layout: TileLayout) => boolean
begin
    return layout == TileLayout_CUBE_M16 ||
           layout == TileLayout_CUBE_M32;
end;

readonly func TileCellRearrangementDescriptorLegal(index: TileIndex)
    => boolean
begin
    return TileCubeDescriptorLegal(_Tiles[[index]]) &&
           TileCellRearrangementLayoutLegal(_Tiles[[index]].layout);
end;

pure func TileCellRearrangementRowBytes(layout: TileLayout) => integer {4,8}
begin
    return if layout == TileLayout_CUBE_M32 then 4 else 8;
end;

pure func TileRearrangementControlWordLegal(control: Word) => boolean
begin
    return control[63:32] == Zeros{32};
end;

readonly func TileCellRearrangementValidBytes(tile: TileInfo)
    => integer {0..262144}
begin
    return ((tile.valid_columns * TileElementBits(tile.data_type) + 7) DIVRM 8)
        as integer {0..262144};
end;

readonly func TileCellRearrangementWordsPerRow(tile: TileInfo)
    => integer {0..65536}
begin
    return ((TileCellRearrangementValidBytes(tile) + 3) DIVRM 4)
        as integer {0..65536};
end;

readonly func TileCellRearrangementByteDefined(
    tile: TileInfo, row: integer {0..65535},
    byte_index: integer {0..262143}) => boolean
begin
    let element_bits = TileElementBits(tile.data_type);
    if element_bits == 4 then
        assert byte_index <= 32767;
        let first_byte_index = byte_index as integer {0..32767};
        let first_nibble = (first_byte_index * 2) as integer {0..65535};
        if first_nibble >= tile.valid_columns then return FALSE; end;
        let first_element = TileLogicalLinearIndex(tile, row,
            first_nibble as integer {0..65535});
        if !TileLogicalElementDefined(tile, first_element) then
            return FALSE;
        end;
        if first_nibble + 1 < tile.valid_columns then
            let second_element = TileLogicalLinearIndex(tile, row,
                (first_nibble + 1) as integer {0..65535});
            return TileLogicalElementDefined(tile, second_element);
        end;
        return TRUE;
    end;
    let element_bytes = TileElementBytes(tile.data_type);
    let element_column = (byte_index DIVRM element_bytes)
        as integer {0..65535};
    if element_column >= tile.valid_columns then return FALSE; end;
    let element = TileLogicalLinearIndex(tile, row,
        element_column as integer {0..65535});
    return TileLogicalElementDefined(tile, element);
end;

readonly func TileReadCellByte(tile: TileInfo,
                               row: integer {0..65535},
                               byte_index: integer {0..262143}) => Byte
begin
    let element_bits = TileElementBits(tile.data_type);
    if element_bits == 4 then
        assert byte_index <= 32767;
        let first_byte_index = byte_index as integer {0..32767};
        let first_nibble = (first_byte_index * 2) as integer {0..65535};
        let first_element = TileLogicalLinearIndex(tile, row,
            first_nibble as integer {0..65535});
        var result = Zeros{8};
        result[3:0] = TileReadLogicalElement(tile, first_element)[3:0];
        if first_nibble + 1 < tile.valid_columns then
            let second_element = TileLogicalLinearIndex(tile, row,
                (first_nibble + 1) as integer {0..65535});
            result[7:4] = TileReadLogicalElement(tile,
                second_element)[3:0];
        end;
        return result;
    end;
    let element_bytes = TileElementBytes(tile.data_type);
    let element_column = (byte_index DIVRM element_bytes)
        as integer {0..65535};
    let byte_in_element = (byte_index MOD element_bytes) as integer {0..7};
    let element = TileLogicalLinearIndex(tile, row,
        element_column as integer {0..65535});
    return TileReadLogicalElement(tile, element)[(byte_in_element * 8) +: 8];
end;

readonly func TileCellRearrangementValidRegionDefined(tile: TileInfo)
    => boolean
begin
    let valid_bytes = TileCellRearrangementValidBytes(tile);
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for byte_index = 0 to valid_bytes - 1 looplimit 262144 do
            if !TileCellRearrangementByteDefined(tile,
                row as integer {0..65535}, byte_index) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileCellRearrangementByteHasActiveCoordinate(
    tile: TileInfo, row: integer {0..65535},
    byte_index: integer {0..262143}) => boolean
begin
    let element_bits = TileElementBits(tile.data_type);
    if element_bits == 4 then
        let first_column = (byte_index * 2) as integer {0..65535};
        if first_column < tile.valid_columns &&
           BundleExecutionMaskActiveAt(tile.layout, row, first_column) then
            return TRUE;
        end;
        return first_column + 1 < tile.valid_columns &&
               BundleExecutionMaskActiveAt(
                   tile.layout, row,
                   (first_column + 1) as integer {0..65535});
    end;
    let element_column = (byte_index DIVRM
        TileElementBytes(tile.data_type)) as integer {0..65535};
    return element_column < tile.valid_columns &&
           BundleExecutionMaskActiveAt(tile.layout, row, element_column);
end;

pure func TileCellRearrangementElementWordIndex(
    data_type: TileDataType, column: integer {0..65535})
    => integer {0..65535}
begin
    return ((column * TileElementBits(data_type)) DIVRM 32)
        as integer {0..65535};
end;

readonly func TileOperandsLegal_TPERMUTE(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, indices: TileIndex) => boolean
begin
    if !TileCellRearrangementDescriptorLegal(destination) ||
       !TileCellRearrangementDescriptorLegal(source0) ||
       !TileCellRearrangementDescriptorLegal(source1) ||
       !TileCellRearrangementDescriptorLegal(indices) || destination == source0 ||
       destination == source1 || indices == source0 || indices == source1 then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let left = _Tiles[[source0]];
    let right = _Tiles[[source1]];
    let index_tile = _Tiles[[indices]];
    if destination_tile.storage_kind != TileStorage_Numeric ||
       left.storage_kind != TileStorage_Numeric ||
       right.storage_kind != TileStorage_Numeric ||
       index_tile.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementLayoutLegal(destination_tile.layout) ||
       destination_tile.layout != left.layout ||
       destination_tile.layout != right.layout ||
       destination_tile.data_type != left.data_type ||
       destination_tile.data_type != right.data_type ||
       !TileCubeDataTypeSupported(destination_tile.data_type) ||
       TileElementBits(destination_tile.data_type) == 64 ||
       index_tile.data_type != TileDataType_U8 ||
       index_tile.layout != destination_tile.layout ||
       destination_tile.valid_rows != left.valid_rows ||
       destination_tile.valid_rows != right.valid_rows ||
       destination_tile.valid_columns != left.valid_columns ||
       destination_tile.valid_columns != right.valid_columns ||
       index_tile.valid_rows != destination_tile.valid_rows ||
       index_tile.valid_columns !=
           TileCellRearrangementValidBytes(destination_tile) ||
       index_tile.cube_cell_count != destination_tile.cube_cell_count then
        return FALSE;
    end;
    let row_bytes = TileCellRearrangementRowBytes(destination_tile.layout);
    let valid_bytes = TileCellRearrangementValidBytes(destination_tile);
    if valid_bytes > row_bytes * destination_tile.cube_cell_count then
        return FALSE;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for byte_index = 0 to valid_bytes - 1 looplimit 262144 do
            if TileCellRearrangementByteHasActiveCoordinate(
                   destination_tile, row as integer {0..65535}, byte_index) then
                if !TileCellRearrangementByteDefined(index_tile,
                    row as integer {0..65535}, byte_index) then
                    return FALSE;
                end;
                let index_element = TileLogicalLinearIndex(index_tile,
                    row as integer {0..65535},
                    byte_index as integer {0..65535});
                let index_value = UInt(TileReadLogicalElement(
                    index_tile, index_element));
                if index_value >= row_bytes * 2 then return FALSE; end;
                let cell_base = (byte_index DIVRM row_bytes) * row_bytes;
                let selected_byte = if index_value < row_bytes then
                    index_value else index_value - row_bytes;
                let source_byte = cell_base + selected_byte;
                let selected_source = if index_value < row_bytes then
                    left else right;
                if !TileCellRearrangementByteDefined(selected_source,
                    row as integer {0..65535},
                    source_byte as integer {0..262143}) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_TSHUF(
    destination: TileIndex, source: TileIndex,
    controls: TileIndex, control: Word) => boolean
begin
    if !TileCellRearrangementDescriptorLegal(destination) ||
       !TileCellRearrangementDescriptorLegal(source) ||
       !TileCellRearrangementDescriptorLegal(controls) || destination == source ||
       destination == controls then return FALSE; end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let control_tile = _Tiles[[controls]];
    let mode = UInt(control[7:0]);
    let segment_code = UInt(control[15:8]);
    let boundary = UInt(control[23:16]);
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       control_tile.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementLayoutLegal(destination_tile.layout) ||
       destination_tile.layout != source_tile.layout ||
       destination_tile.layout != control_tile.layout ||
       destination_tile.data_type != source_tile.data_type ||
       control_tile.data_type != TileDataType_U32 ||
       destination_tile.valid_rows != source_tile.valid_rows ||
       destination_tile.valid_columns != source_tile.valid_columns ||
       control_tile.valid_rows != source_tile.valid_rows ||
       control_tile.valid_columns !=
           TileCellRearrangementWordsPerRow(source_tile) ||
       control_tile.cube_cell_count != source_tile.cube_cell_count ||
       mode > 3 || boundary > 1 || segment_code > 4 ||
       (segment_code == 4 &&
        destination_tile.layout != TileLayout_CUBE_M32) ||
       (destination_tile.layout == TileLayout_CUBE_M16 &&
        segment_code == 4) || !TileRearrangementControlWordLegal(control) ||
       !TileCubeDataTypeSupported(destination_tile.data_type) ||
       TileElementBits(destination_tile.data_type) == 64 then
        return FALSE;
    end;
    let segment_width = if segment_code == 0 then 2
        else if segment_code == 1 then 4
        else if segment_code == 2 then 8
        else if segment_code == 3 then 16
        else 32;
    let cell_rows = if destination_tile.layout == TileLayout_CUBE_M32 then 32
        else 16;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        let lane = (row MOD cell_rows) as integer {0..31};
        let segment_base = ((lane DIVRM segment_width) * segment_width)
            as integer {0..31};
        let local_lane = (lane - segment_base) as integer {0..31};
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let word_index = TileCellRearrangementElementWordIndex(
                    source_tile.data_type,
                    column as integer {0..65535});
                let control_element = TileLogicalLinearIndex(
                    control_tile, row as integer {0..65535}, word_index);
                if !TileLogicalElementDefined(
                       control_tile, control_element) then return FALSE; end;
                let control_word = TileReadLogicalElement(
                    control_tile, control_element);
                let b = UInt(control_word[4:0]);
                var candidate_valid = TRUE;
                var candidate_lane: integer {0..31} = lane;
                if mode == 0 then
                    if b > lane - segment_base then candidate_valid = FALSE;
                    else candidate_lane = (lane - b) as integer {0..31}; end;
                elsif mode == 1 then
                    if (lane - segment_base) + b >= segment_width then
                        candidate_valid = FALSE;
                    else candidate_lane = (lane + b) as integer {0..31}; end;
                elsif mode == 2 then
                    candidate_lane = (segment_base +
                        UInt(((Zeros{5} + local_lane) as bits(5)) XOR
                             ((Zeros{5} + b) as bits(5))))
                        as integer {0..31};
                    if candidate_lane >= segment_base + segment_width then
                        candidate_valid = FALSE;
                    end;
                else
                    candidate_lane = (segment_base +
                        (b MOD segment_width)) as integer {0..31};
                end;
                let candidate_row = (row - lane) + candidate_lane;
                var source_row: integer {0..65535} =
                    row as integer {0..65535};
                var source_required = boundary == 0;
                if candidate_valid &&
                   candidate_row < source_tile.valid_rows then
                    source_row = candidate_row as integer {0..65535};
                    source_required = TRUE;
                end;
                if source_required then
                    let source_element = TileLogicalLinearIndex(
                        source_tile, source_row,
                        column as integer {0..65535});
                    if !TileLogicalElementDefined(
                           source_tile, source_element) then return FALSE; end;
                end;
            end;
        end;
    end;
    return TRUE;
end;

pure func TileCellRearrangementDataTypeLegal(
    data_type: TileDataType) => boolean
begin
    return TileCubeDataTypeSupported(data_type) &&
           (TileElementBits(data_type) == 8 ||
            TileElementBits(data_type) == 16 ||
            TileElementBits(data_type) == 32);
end;

readonly func TileCellRearrangementSelectedBytesDefined(
    tile: TileInfo, row: integer {0..65535},
    byte_offset: integer {0..262143},
    byte_count: integer {0..4}) => boolean
begin
    for byte_index = 0 to byte_count - 1 looplimit 4 do
        if !TileCellRearrangementByteDefined(
            tile, row, (byte_offset + byte_index) as integer {0..262143}) then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_TPACK(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, control: Word) => boolean
begin
    if !TileCellRearrangementDescriptorLegal(destination) ||
       !TileCellRearrangementDescriptorLegal(source0) ||
       !TileCellRearrangementDescriptorLegal(source1) || destination == source0 ||
       destination == source1 then return FALSE; end;
    let destination_tile = _Tiles[[destination]];
    let left = _Tiles[[source0]];
    let right = _Tiles[[source1]];
    let left_bytes = UInt(control[7:0]);
    let right_bytes = UInt(control[15:8]);
    if left.storage_kind != TileStorage_Numeric ||
       right.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementDataTypeLegal(left.data_type) ||
       !TileCellRearrangementDataTypeLegal(right.data_type) then
        return FALSE;
    end;
    let words = TileCellRearrangementWordsPerRow(left);
    let destination_elements_per_word =
        if destination_tile.data_type == TileDataType_U8 then 4
        else if destination_tile.data_type == TileDataType_U16 then 2
        else if destination_tile.data_type == TileDataType_U32 then 1
        else 0;
    if destination_tile.storage_kind != TileStorage_Numeric ||
       left.storage_kind != TileStorage_Numeric ||
       right.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementDataTypeLegal(left.data_type) ||
       !TileCellRearrangementDataTypeLegal(right.data_type) ||
       destination_elements_per_word == 0 ||
       destination_tile.layout != left.layout ||
       destination_tile.layout != right.layout ||
       destination_tile.valid_rows != left.valid_rows ||
       destination_tile.valid_rows != right.valid_rows ||
       TileCellRearrangementWordsPerRow(right) != words ||
       destination_tile.valid_columns !=
           words * destination_elements_per_word ||
       left_bytes < 1 || left_bytes > 3 ||
       right_bytes < 1 || right_bytes > 3 ||
       left_bytes + right_bytes > 4 ||
       !TileRearrangementControlWordLegal(control) then
        return FALSE;
    end;
    for row = 0 to left.valid_rows - 1 looplimit 65536 do
        for word_index = 0 to words - 1 looplimit 65536 do
            let word_start = (word_index * 4) as integer {0..262143};
            if !_BundleExecutionMask.valid ||
               BundleExecutionMaskActiveAt(
                   left.layout, row as integer {0..65535},
                   word_index as integer {0..65535}) then
                if !TileCellRearrangementSelectedBytesDefined(
                    left, row as integer {0..65535}, word_start,
                    left_bytes as integer {0..4}) ||
                   !TileCellRearrangementSelectedBytesDefined(
                    right, row as integer {0..65535}, word_start,
                    right_bytes as integer {0..4}) then
                    return FALSE;
                end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileOperandsLegal_TUNPACK(
    destination: TileIndex, source: TileIndex, control: Word) => boolean
begin
    if !TileCellRearrangementDescriptorLegal(destination) ||
       !TileCellRearrangementDescriptorLegal(source) || destination == source then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let offset = UInt(control[7:0]);
    let count = UInt(control[15:8]);
    if source_tile.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementDataTypeLegal(source_tile.data_type) then
        return FALSE;
    end;
    let words = TileCellRearrangementWordsPerRow(source_tile);
    let destination_elements_per_word =
        if destination_tile.data_type == TileDataType_U8 then 4
        else if destination_tile.data_type == TileDataType_U16 then 2
        else if destination_tile.data_type == TileDataType_U32 then 1
        else 0;
    if destination_tile.storage_kind != TileStorage_Numeric ||
       source_tile.storage_kind != TileStorage_Numeric ||
       !TileCellRearrangementDataTypeLegal(source_tile.data_type) ||
       destination_elements_per_word == 0 ||
       destination_tile.layout != source_tile.layout ||
       destination_tile.valid_rows != source_tile.valid_rows ||
       destination_tile.valid_columns !=
           words * destination_elements_per_word ||
       offset > 3 || count < 1 || count > 4 || offset + count > 4 ||
       !TileRearrangementControlWordLegal(control) then
        return FALSE;
    end;
    let valid_bytes = TileCellRearrangementValidBytes(source_tile);
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for word_index = 0 to words - 1 looplimit 65536 do
            let word_start = (word_index * 4) as integer {0..262143};
            let word_valid = if valid_bytes > word_start then
                (if valid_bytes - word_start > 4 then 4
                 else valid_bytes - word_start)
            else 0;
            if offset + count > word_valid then
                return FALSE;
            end;
            if (!_BundleExecutionMask.valid ||
                BundleExecutionMaskActiveAt(
                    source_tile.layout, row as integer {0..65535},
                    word_index as integer {0..65535})) &&
               !TileCellRearrangementSelectedBytesDefined(
                   source_tile, row as integer {0..65535},
                   (word_start + offset) as integer {0..262143},
                   count as integer {0..4}) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
