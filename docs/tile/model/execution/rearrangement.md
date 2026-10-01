<!-- GENERATED FROM: asl/tile/model/execution/rearrangement.asl -->
# Rearrangement

**Normative ASL source:** `asl/tile/model/execution/rearrangement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-REARRANGEMENT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-rearrangement-purpose role=purpose-scope -->
## Purpose and scope

This unit defines four byte- and lane-level rearrangements of Local CUBE_M16 and CUBE_M32 Tiles. `TPERMUTE` builds each destination byte from a byte of one of two sources. `TSHUF` moves elements between rows (lanes) inside a CUBE cell. `TPACK` joins selected bytes of two sources into one 32-bit word. `TUNPACK` extracts selected bytes of each source word.

It also owns the byte accessors `TileInfoWithCellByte`, `TileReadCellWord`, and `TileInfoWithCellWord`. A cell word is 4 consecutive bytes of one row's valid data.

<!-- PTO-READER-BLOCK: tile-model-execution-rearrangement-concepts role=concepts-state -->
## Concepts and visible state

Row bytes are the byte width of one CUBE cell row: 8 for CUBE_M16 and 4 for CUBE_M32. The valid bytes of a row are `valid_columns x element bits`, rounded up to whole bytes. Words per row are the valid bytes divided by 4, rounded up.

Each of the four operations reads the source `TileInfo` records at entry and builds the result in a local copy, assigned to `_Tiles` once. Legality forbids the destination from naming a data source, and `TSHUF` also forbids it from naming the control Tile.

Each of the four operations ends with `TileWithValidRegionDefined` and `TileWithPadding` using `TilePad_Null`, so padding is zero and undefined.

<!-- PTO-READER-BLOCK: tile-model-execution-rearrangement-rules role=rules-interactions -->
## Rules and interactions

`TPERMUTE` reads one U8 index per destination byte. An index below row bytes selects that byte of source 0; an index from row bytes to twice row bytes selects source 1. The selected byte comes from the same cell-row chunk as the destination byte.

`TSHUF` takes mode, segment code, and boundary from control bits 7 to 0, 15 to 8, and 23 to 16. Segments are 2, 4, 8, 16, or 32 lanes; 32 requires CUBE_M32. Per element, a 5-bit value from the U32 control Tile shifts down (mode 0), shifts up (mode 1), XORs (mode 2), or selects lane `b` modulo the segment width (mode 3) within the segment. If the candidate lane is outside the segment or beyond the valid rows, boundary 0 keeps the element's own row and boundary 1 writes zero.

`TPACK` takes the byte count of source 0 from control bits 7 to 0 and of source 1 from bits 15 to 8. `TUNPACK` takes a byte offset and a byte count from the same fields.

Design point: `TileOperandsLegal_TPERMUTE` checks every active destination byte before any effect: its index must be defined and below twice row bytes, and the source byte it selects must be defined. An illegal index therefore rejects with Fault_TileLegality and leaves the destination unpublished; the handler repeats the range check as an assertion before building the result.

Design point: under an ExecutionMask, an inactive coordinate reads no index, control, or source byte, except that a `TPERMUTE` byte holding two 4-bit elements is read when either element is active. `TPERMUTE` and `TSHUF` use destination element coordinates; `TPACK` and `TUNPACK` use (source row, word index), and one bit gates the whole destination word group: 4 U8, 2 U16, or 1 U32 elements.

<!-- PTO-READER-BLOCK: tile-model-execution-rearrangement-boundaries role=boundaries -->
## Architectural boundaries

All four operations are CUBE_M16 or CUBE_M32 only. `TPACK` and `TUNPACK` destinations are U8, U16, or U32, with `valid_columns` equal to words per row times elements per word. 64-bit element types are excluded.

The inactive path of `TPERMUTE` and `TSHUF` calls `BundleExecutionMaskDestinationValue`. The inactive path of `TPACK` and `TUNPACK` reads `_BundleExecutionMask.merge_base` directly when ZERO is not selected. It does not assert `merge_base_valid`; dispatch establishes the merge base in `PrepareSelectedBundleExecutionMaskMerge`.

<!-- PTO-READER-BLOCK: tile-model-execution-rearrangement-example role=example-usage -->
## Non-normative reading example

`TPACK` uses CUBE_M16 U8 sources with 8 valid columns, so each row has 8 valid bytes and 2 words. The destination is U16 with 4 valid columns. The control word selects 2 bytes from each source. Row 0 of source 0 holds bytes `0x01` to `0x08`, and row 0 of source 1 holds `0x11` to `0x18`.

1. Word 0 packs source 0 bytes 0 and 1, then source 1 bytes 0 and 1: `0x01`, `0x02`, `0x11`, `0x12`.
2. The destination receives elements `0x0201` and `0x1211`.
3. Word 1 starts at byte 4 and gives `0x0605` and `0x1615`.

With no ExecutionMask, all 4 elements are written and become defined.

<!-- PTO-READER-BLOCK: tile-model-execution-rearrangement-related role=related-owners-navigation -->
## Related owners

- [Layout rearrangement legality](../legality/layout-rearrangement.md) owns row bytes, byte reads, and the operand checks.
- [Layout and rearrangement dispatch](../dispatch/layout-and-rearrangement.md) routes the instructions here.
- [TPERMUTE](../../layout-and-rearrangement/layout/TPERMUTE.md), [TSHUF](../../layout-and-rearrangement/layout/TSHUF.md), [TPACK](../../layout-and-rearrangement/layout/TPACK.md), and [TUNPACK](../../layout-and-rearrangement/layout/TUNPACK.md) own instruction contracts.
- [ExecutionMask schema](../../../block/model/dispatch/execution-mask-schema.md) prepares the mask and merge base.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/rearrangement.asl -->
```asl
// NDF-BEGIN: PTO-TILE-MODEL-EXECUTION-MASK-REARRANGEMENT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// For TPACK/TUNPACK, ExecutionMask coordinates are (source row, source CELL word index), with word_index below the source words-per-row. PredicateCell shape is source ValidRow by source words-per-row; GPR mapping uses word_index as the column. One bit gates the complete destination CELL word group (4 U8, 2 U16, or 1 U32 elements). Active groups perform the existing selected-byte reads and whole-word write; inactive groups do not read selected source bytes and apply the common MERGE/ZERO destination rule. Source/destination shape, type, control, word-count, capacity, and allocation checks remain in force for every mask value.
// For TPERMUTE and TSHUF, ExecutionMask coordinates are destination logical
// element coordinates. Inactive elements MUST NOT read index, control, or
// mapped source payload and MUST apply the common MERGE/ZERO destination rule;
// descriptor, shape, type, scalar-control, capacity, and allocation checks
// remain unconditional.
// NDF-END: PTO-TILE-MODEL-EXECUTION-MASK-REARRANGEMENT-001
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","surface":"tile","classification":["model","execution","rearrangement"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-NUMERIC-EXCEPTIONS","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"]}
// PTO-REQ-TEPL-REARRANGE-001: direct tile layout and indexing operations.

readonly func TileInfoWithCellByte(tile: TileInfo,
                                   row: integer {0..65535},
                                   byte_index: integer {0..262143},
                                   value: Byte) => TileInfo
begin
    let element_bits = TileElementBits(tile.data_type);
    if element_bits == 4 then
        assert byte_index <= 32767;
        let first_byte_index = byte_index as integer {0..32767};
        let first_nibble = (first_byte_index * 2) as integer {0..65535};
        let first_element = TileLogicalLinearIndex(tile, row,
            first_nibble as integer {0..65535});
        var first_word = TileReadLogicalElement(tile, first_element);
        first_word[3:0] = value[3:0];
        var result = TileInfoWithLogicalElement(tile, first_element,
            first_word);
        if first_nibble + 1 < tile.valid_columns then
            let second_element = TileLogicalLinearIndex(tile, row,
                (first_nibble + 1) as integer {0..65535});
            var second_word = TileReadLogicalElement(result, second_element);
            second_word[3:0] = value[7:4];
            result = TileInfoWithLogicalElement(result, second_element,
                second_word);
        end;
        return result;
    end;
    let element_bytes = TileElementBytes(tile.data_type);
    let element_column = (byte_index DIVRM element_bytes)
        as integer {0..65535};
    let byte_in_element = (byte_index MOD element_bytes) as integer {0..7};
    let element = TileLogicalLinearIndex(tile, row, element_column);
    var word = TileReadLogicalElement(tile, element);
    word[(byte_in_element * 8) +: 8] = value;
    return TileInfoWithLogicalElement(tile, element, word);
end;

readonly func TileReadCellWord(tile: TileInfo,
                               row: integer {0..65535},
                               word_index: integer {0..65535}) => Word
begin
    let valid_bytes = TileCellRearrangementValidBytes(tile);
    let byte_base = (word_index * 4) as integer {0..262143};
    var result = Zeros{PTO_XLEN};
    for byte_index = 0 to 3 looplimit 4 do
        if byte_base + byte_index < valid_bytes then
            result[(byte_index * 8) +: 8] = TileReadCellByte(tile, row,
                (byte_base + byte_index) as integer {0..262143});
        end;
    end;
    return result;
end;

readonly func TileInfoWithCellWord(tile: TileInfo,
                                   row: integer {0..65535},
                                   word_index: integer {0..65535},
                                   value: Word) => TileInfo
begin
    let valid_bytes = TileCellRearrangementValidBytes(tile);
    let byte_base = (word_index * 4) as integer {0..262143};
    var result = tile;
    for byte_index = 0 to 3 looplimit 4 do
        if byte_base + byte_index < valid_bytes then
            result = TileInfoWithCellByte(result, row,
                (byte_base + byte_index) as integer {0..262143},
                value[(byte_index * 8) +: 8]);
        end;
    end;
    return result;
end;

func TPERMUTE(destination: TileIndex, source0: TileIndex,
              source1: TileIndex, indices: TileIndex)
begin
    let destination_tile = _Tiles[[destination]];
    let source0_tile = _Tiles[[source0]];
    let source1_tile = _Tiles[[source1]];
    let index_tile = _Tiles[[indices]];
    assert TileOperandsLegal_TPERMUTE(
        destination, source0, source1, indices);
    let row_bytes = TileCellRearrangementRowBytes(destination_tile.layout);
    let valid_bytes = TileCellRearrangementValidBytes(destination_tile);
    var result = destination_tile;
    // Validate all indices before the first destination write.
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for byte_index = 0 to valid_bytes - 1 looplimit 65536 do
            if TileCellRearrangementByteHasActiveCoordinate(
                   destination_tile, row as integer {0..65535}, byte_index) then
                let index_value = UInt(TileReadCellByte(
                    index_tile, row as integer {0..65535}, byte_index));
                assert index_value < row_bytes * 2;
            end;
        end;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for byte_index = 0 to valid_bytes - 1 looplimit 65536 do
            if TileCellRearrangementByteHasActiveCoordinate(
                   destination_tile, row as integer {0..65535}, byte_index) then
                let index_value = UInt(TileReadCellByte(
                    index_tile, row as integer {0..65535}, byte_index));
                let selected_source = if index_value < row_bytes then
                    source0_tile else source1_tile;
                let cell_base = (byte_index DIVRM row_bytes) * row_bytes;
                let selected_byte = if index_value < row_bytes then
                    index_value else index_value - row_bytes;
                result = TileInfoWithCellByte(
                    result,
                    row as integer {0..65535},
                    byte_index,
                    TileReadCellByte(
                        selected_source,
                        row as integer {0..65535},
                        (cell_base + selected_byte)
                            as integer {0..262143}));
            end;
        end;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1
            looplimit 65536 do
            if !BundleExecutionMaskActiveAt(
                   destination_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(
                    result, row as integer {0..65535},
                    column as integer {0..65535});
                let value = BundleExecutionMaskDestinationValue(
                    destination_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
                result = TileInfoWithLogicalElement(result, element, value);
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;

func TSHUF(destination: TileIndex, source: TileIndex,
           controls: TileIndex, control: Word)
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let controls_tile = _Tiles[[controls]];
    assert TileOperandsLegal_TSHUF(destination, source, controls, control);
    let mode = UInt(control[7:0]);
    let segment_code = UInt(control[15:8]);
    let boundary = UInt(control[23:16]);
    let segment_width = if segment_code == 0 then 2
        else if segment_code == 1 then 4
        else if segment_code == 2 then 8
        else if segment_code == 3 then 16
        else 32;
    let cell_rows = if destination_tile.layout == TileLayout_CUBE_M32 then 32
        else 16;
    var result = destination_tile;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        let lane = (row MOD cell_rows) as integer {0..31};
        let segment_base = ((lane DIVRM segment_width) * segment_width)
            as integer {0..31};
        let local_lane = (lane - segment_base) as integer {0..31};
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            var value = Zeros{PTO_XLEN};
            if BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let word_index = TileCellRearrangementElementWordIndex(
                    source_tile.data_type,
                    column as integer {0..65535});
                let control_element = TileLogicalLinearIndex(
                    controls_tile, row as integer {0..65535}, word_index);
                let control_word = TileReadLogicalElement(
                    controls_tile, control_element);
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
                if candidate_valid && candidate_row < source_tile.valid_rows then
                    source_row = candidate_row as integer {0..65535};
                    source_required = TRUE;
                end;
                if source_required then
                    let source_element = TileLogicalLinearIndex(
                        source_tile, source_row,
                        column as integer {0..65535});
                    value = TileReadLogicalElement(source_tile, source_element);
                end;
            else
                value = BundleExecutionMaskDestinationValue(
                    destination_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            end;
            let destination_element = TileLogicalLinearIndex(
                result, row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElement(
                result, destination_element, value);
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;

func TPACK(destination: TileIndex, source0: TileIndex,
           source1: TileIndex, control: Word)
begin
    let destination_tile = _Tiles[[destination]];
    let source0_tile = _Tiles[[source0]];
    let source1_tile = _Tiles[[source1]];
    assert TileOperandsLegal_TPACK(destination, source0, source1, control);
    let source0_bytes = UInt(control[7:0]);
    let source1_bytes = UInt(control[15:8]);
    let words = TileCellRearrangementWordsPerRow(source0_tile);
    var result = destination_tile;
    for row = 0 to source0_tile.valid_rows - 1 looplimit 65536 do
        for word_index = 0 to words - 1 looplimit 65536 do
            let word_start = (word_index * 4) as integer {0..262143};
            if BundleExecutionMaskActiveAt(
                   source0_tile.layout, row as integer {0..65535},
                   word_index as integer {0..65535}) then
                var packed = Zeros{PTO_XLEN};
                for byte_index = 0 to source0_bytes - 1 looplimit 3 do
                    packed[(byte_index * 8) +: 8] = TileReadCellByte(
                        source0_tile, row as integer {0..65535},
                        (word_start + byte_index) as integer {0..262143});
                end;
                for byte_index = 0 to source1_bytes - 1 looplimit 3 do
                    packed[((source0_bytes + byte_index) * 8) +: 8] =
                        TileReadCellByte(source1_tile,
                            row as integer {0..65535},
                            (word_start + byte_index) as integer {0..262143});
                end;
                result = TileInfoWithCellWord(result,
                    row as integer {0..65535},
                    word_index as integer {0..65535}, packed);
            else
                let group_width = if destination_tile.data_type == TileDataType_U8 then 4
                    else if destination_tile.data_type == TileDataType_U16 then 2
                    else 1;
                for group_element = 0 to group_width - 1 looplimit 4 do
                    let column = (word_index * group_width + group_element)
                        as integer {0..65535};
                    let destination_element = TileLogicalLinearIndex(
                        result, row as integer {0..65535}, column);
                    var value = Zeros{PTO_XLEN};
                    if !_BundleExecutionMask.zero_inactive then
                        let base = _Tiles[[_BundleExecutionMask.merge_base]];
                        let base_element = TileLogicalLinearIndex(
                            base, row as integer {0..65535}, column);
                        value = TileReadLogicalElement(base, base_element);
                    end;
                    result = TileInfoWithLogicalElementAndDefined(
                        result, destination_element, value, TRUE);
                end;
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;

func TUNPACK(destination: TileIndex, source: TileIndex, control: Word)
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    assert TileOperandsLegal_TUNPACK(destination, source, control);
    let byte_offset = UInt(control[7:0]);
    let byte_count = UInt(control[15:8]);
    let words = TileCellRearrangementWordsPerRow(source_tile);
    var result = destination_tile;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for word_index = 0 to words - 1 looplimit 65536 do
            let word_start = (word_index * 4) as integer {0..262143};
            if BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   word_index as integer {0..65535}) then
                var unpacked = Zeros{PTO_XLEN};
                for byte_index = 0 to byte_count - 1 looplimit 4 do
                    unpacked[(byte_index * 8) +: 8] =
                        TileReadCellByte(source_tile,
                            row as integer {0..65535},
                            (word_start + byte_offset + byte_index)
                                as integer {0..262143});
                end;
                result = TileInfoWithCellWord(result,
                    row as integer {0..65535},
                    word_index as integer {0..65535}, unpacked);
            else
                let group_width = if destination_tile.data_type == TileDataType_U8 then 4
                    else if destination_tile.data_type == TileDataType_U16 then 2
                    else 1;
                for group_element = 0 to group_width - 1 looplimit 4 do
                    let column = (word_index * group_width + group_element)
                        as integer {0..65535};
                    let destination_element = TileLogicalLinearIndex(
                        result, row as integer {0..65535}, column);
                    var value = Zeros{PTO_XLEN};
                    if !_BundleExecutionMask.zero_inactive then
                        let base = _Tiles[[_BundleExecutionMask.merge_base]];
                        let base_element = TileLogicalLinearIndex(
                            base, row as integer {0..65535}, column);
                        value = TileReadLogicalElement(base, base_element);
                    end;
                    result = TileInfoWithLogicalElementAndDefined(
                        result, destination_element, value, TRUE);
                end;
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;
```
<!-- GENERATED-ASL-END: unit -->
