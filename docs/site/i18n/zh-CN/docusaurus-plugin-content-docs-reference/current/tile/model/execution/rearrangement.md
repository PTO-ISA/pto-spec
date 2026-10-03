<!-- GENERATED FROM: asl/tile/model/execution/rearrangement.asl -->
# Rearrangement

**Normative ASL source:** `asl/tile/model/execution/rearrangement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-REARRANGEMENT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-rearrangement-purpose role=purpose-scope -->
## 用途与范围

本单元定义 Local CUBE_M16 和 CUBE_M32 Tile 的四种字节级和通道级重排。`TPERMUTE` 用两个源之一的某个字节构建每个目标字节。`TSHUF` 在 CUBE 单元内的行（通道）之间移动元素。`TPACK` 把两个源的选定字节拼接为一个 32 位字。`TUNPACK` 从每个源字中提取选定字节。

它还拥有字节访问函数 `TileInfoWithCellByte`、`TileReadCellWord` 和 `TileInfoWithCellWord`。单元字是某一行有效数据中连续的 4 个字节。

<!-- PTO-READER-BLOCK: tile-model-execution-rearrangement-concepts role=concepts-state -->
## 概念与可见状态

行字节数是一个 CUBE 单元行的字节宽度：CUBE_M16 为 8，CUBE_M32 为 4。一行的有效字节数为 `valid_columns x element bits`，向上取整到整字节。每行字数为有效字节数除以 4 并向上取整。

四个操作都在入口处读取源 `TileInfo` 记录，在局部副本中构建结果，并对 `_Tiles` 赋值一次。合法性规则禁止目标与数据源相同，`TSHUF` 还禁止目标与控制 Tile 相同。

四个操作都以 `TileWithValidRegionDefined` 和使用 `TilePad_Null` 的 `TileWithPadding` 结束，因此填充为零且未定义。

<!-- PTO-READER-BLOCK: tile-model-execution-rearrangement-rules role=rules-interactions -->
## 规则与交互

`TPERMUTE` 为每个目标字节读取一个 U8 索引。小于行字节数的索引选择源 0 的该字节；从行字节数到两倍行字节数之间的索引选择源 1。被选字节来自与目标字节相同的单元行分块。

`TSHUF` 从控制位 7 到 0、15 到 8 和 23 到 16 取得 mode、段代码和 boundary。段宽为 2、4、8、16 或 32 个通道；32 要求 CUBE_M32。对每个元素，来自 U32 控制 Tile 的 5 位值在段内执行下移（mode 0）、上移（mode 1）、异或（mode 2）或选择通道 `b` 对段宽取模（mode 3）。如果候选通道在段外或超出有效行，boundary 0 保留元素自身所在行，boundary 1 写入零。

`TPACK` 从控制位 7 到 0 取得源 0 的字节数，从位 15 到 8 取得源 1 的字节数。`TUNPACK` 从相同字段取得字节偏移和字节数。

设计要点：`TileOperandsLegal_TPERMUTE` 在任何效果之前检查每个活动目标字节：其索引必须已定义且小于两倍行字节数，其选中的源字节也必须已定义。因此非法索引以 Fault_TileLegality 拒绝，目标不会被发布；处理函数在构建结果之前以断言重复范围检查。

设计要点：在 ExecutionMask 下，非活动坐标不读取任何索引、控制或源字节；例外是 `TPERMUTE` 中容纳两个 4 位元素的字节只要其中一个元素活动就会被读取。普通 64 位 `TPERMUTE` 与 `TSHUF` 坐标对完整逻辑元素使用一个位。raw `TPACK` 与 `TUNPACK` 保留按 word 的例外：U64 结果的低、高 32 位 word 可分别受控后再合并。

<!-- PTO-READER-BLOCK: tile-model-execution-rearrangement-boundaries role=boundaries -->
## 架构边界

四个操作都仅适用于 CUBE_M16 或 CUBE_M32，但 64 位操作数与 `U64` pack/unpack 目标要求 `CUBE_M32`。U64 目标把每个偶数/奇数 raw-word pair 合成一个逻辑列；不完整 pair 在产生效果前拒绝。`CUBE_M16` 仍限于更窄元素。

`TPERMUTE` 和 `TSHUF` 的非活动路径调用 `BundleExecutionMaskDestinationValue`。`TPACK` 和 `TUNPACK` 的非活动路径在未选择 ZERO 时直接读取 `_BundleExecutionMask.merge_base`。它不断言 `merge_base_valid`；分派在 `PrepareSelectedBundleExecutionMaskMerge` 中建立合并基准。

<!-- PTO-READER-BLOCK: tile-model-execution-rearrangement-example role=example-usage -->
## 非规范阅读示例

`TPACK` 使用有 8 个有效列的 CUBE_M16 U8 源，因此每行有 8 个有效字节和 2 个字。目标为 U16，有 4 个有效列。控制字从每个源选择 2 个字节。源 0 第 0 行保存字节 `0x01` 到 `0x08`，源 1 第 0 行保存 `0x11` 到 `0x18`。

1. 字 0 依次打包源 0 的字节 0 和 1，然后是源 1 的字节 0 和 1：`0x01`、`0x02`、`0x11`、`0x12`。
2. 目标得到元素 `0x0201` 和 `0x1211`。
3. 字 1 从字节 4 开始，得到 `0x0605` 和 `0x1615`。

没有 ExecutionMask 时，全部 4 个元素都被写入并变为已定义。

<!-- PTO-READER-BLOCK: tile-model-execution-rearrangement-related role=related-owners-navigation -->
## 相关所有者

- [布局重排合法性](../legality/layout-rearrangement.md)拥有行字节数、字节读取和操作数检查。
- [布局与重排分派](../dispatch/layout-and-rearrangement.md)把这些指令路由到这里。
- [TPERMUTE](../../layout-and-rearrangement/layout/TPERMUTE.md)、[TSHUF](../../layout-and-rearrangement/layout/TSHUF.md)、[TPACK](../../layout-and-rearrangement/layout/TPACK.md)和[TUNPACK](../../layout-and-rearrangement/layout/TUNPACK.md)拥有指令契约。
- [ExecutionMask schema](../../../block/model/dispatch/execution-mask-schema.md)准备掩码和合并基准。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/rearrangement.asl -->
```asl
// NDF-BEGIN: PTO-TILE-MODEL-EXECUTION-MASK-REARRANGEMENT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// For TPACK/TUNPACK, ExecutionMask coordinates are (source row, source CELL word index), with word_index below the source words-per-row. PredicateCell shape is source ValidRow by source words-per-row; GPR mapping uses word_index as the column. One bit gates one 32-bit result word (4 U8, 2 U16, or 1 U32 elements); an M32 U64 destination joins each complete pair of independently gated result words and publishes the combined logical element once. Active groups perform the selected-byte reads; inactive groups do not read selected source bytes and apply the common MERGE/ZERO destination rule to their result plane. Source/destination shape, type, control, complete-pair, capacity, and allocation checks remain in force for every mask value.
// For TPERMUTE and TSHUF, ExecutionMask coordinates are destination logical
// element coordinates. Inactive elements MUST NOT read index, control, or
// mapped source payload and MUST apply the common MERGE/ZERO destination rule;
// descriptor, shape, type, scalar-control, capacity, and allocation checks
// remain unconditional.
// NDF-END: PTO-TILE-MODEL-EXECUTION-MASK-REARRANGEMENT-001
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","surface":"tile","classification":["model","execution","rearrangement"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-PACKED-BOUNDARY","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-NUMERIC-EXCEPTIONS","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT","PTO-TILE-MODEL-SHAPE-CUBE-DOUBLE-CELL"]}
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
    var result = destination_tile;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            var value = Zeros{PTO_XLEN};
            if BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let first_word = TileCellRearrangementElementWordIndex(
                    source_tile.data_type,
                    column as integer {0..65535});
                let raw_words = if TileElementBits(source_tile.data_type) == 64
                    then 2 else 1;
                for raw_word = 0 to raw_words - 1 looplimit 2 do
                    let word_index = (first_word + raw_word)
                        as integer {0..65535};
                    let control_element = TileLogicalLinearIndex(
                        controls_tile, row as integer {0..65535}, word_index);
                    let control_word = TileReadLogicalElement(
                        controls_tile, control_element);
                    let (source_required, source_row) = TileShuffleSelectedRow(
                        control_word, row as integer {0..65535},
                        source_tile.valid_rows as integer {1..65535},
                        source_tile.layout,
                        segment_width, mode as integer {0..3},
                        boundary as integer {0..1});
                    if source_required then
                        let source_element = TileLogicalLinearIndex(
                            source_tile, source_row,
                            column as integer {0..65535});
                        let source_value = TileReadLogicalElement(
                            source_tile, source_element);
                        if raw_words == 2 then
                            value = TileCubeM32B64WithRawPlaneWord(
                                value,
                                TileCubeM32B64RawPlaneWord(
                                    source_value, raw_word == 1),
                                raw_word == 1);
                        else value = source_value;
                        end;
                    end;
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
    if destination_tile.data_type == TileDataType_U64 then
        for row = 0 to source0_tile.valid_rows - 1 looplimit 65536 do
            for pair = 0 to (words DIVRM 2) - 1 looplimit 32768 do
                let column = pair as integer {0..65535};
                let destination_element = TileLogicalLinearIndex(
                    result, row as integer {0..65535}, column);
                var joined = Zeros{PTO_XLEN};
                if _BundleExecutionMask.valid &&
                   !_BundleExecutionMask.zero_inactive then
                    let base = _Tiles[[_BundleExecutionMask.merge_base]];
                    let base_element = TileLogicalLinearIndex(
                        base, row as integer {0..65535}, column);
                    joined = TileReadLogicalElement(base, base_element);
                end;
                for raw_word = 0 to 1 looplimit 2 do
                    let word_index = (pair * 2 + raw_word)
                        as integer {0..65535};
                    if BundleExecutionMaskActiveAt(
                           source0_tile.layout, row as integer {0..65535},
                           word_index) then
                        let word_start = (word_index * 4)
                            as integer {0..262143};
                        var packed = Zeros{32};
                        for byte_index = 0 to source0_bytes - 1 looplimit 3 do
                            packed[(byte_index * 8) +: 8] = TileReadCellByte(
                                source0_tile, row as integer {0..65535},
                                (word_start + byte_index)
                                    as integer {0..262143});
                        end;
                        for byte_index = 0 to source1_bytes - 1 looplimit 3 do
                            packed[((source0_bytes + byte_index) * 8) +: 8] =
                                TileReadCellByte(source1_tile,
                                    row as integer {0..65535},
                                    (word_start + byte_index)
                                        as integer {0..262143});
                        end;
                        joined = TileCubeM32B64WithRawPlaneWord(
                            joined, packed, raw_word == 1);
                    end;
                end;
                result = TileInfoWithLogicalElementAndDefined(
                    result, destination_element, joined, TRUE);
            end;
        end;
        result = TileWithValidRegionDefined(result);
        result = TileWithPadding(result, TilePad_Null);
        _Tiles[[destination]] = result;
        return;
    end;
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
    if destination_tile.data_type == TileDataType_U64 then
        for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
            for pair = 0 to (words DIVRM 2) - 1 looplimit 32768 do
                let column = pair as integer {0..65535};
                let destination_element = TileLogicalLinearIndex(
                    result, row as integer {0..65535}, column);
                var joined = Zeros{PTO_XLEN};
                if _BundleExecutionMask.valid &&
                   !_BundleExecutionMask.zero_inactive then
                    let base = _Tiles[[_BundleExecutionMask.merge_base]];
                    let base_element = TileLogicalLinearIndex(
                        base, row as integer {0..65535}, column);
                    joined = TileReadLogicalElement(base, base_element);
                end;
                for raw_word = 0 to 1 looplimit 2 do
                    let word_index = (pair * 2 + raw_word)
                        as integer {0..65535};
                    if BundleExecutionMaskActiveAt(
                           source_tile.layout, row as integer {0..65535},
                           word_index) then
                        let word_start = (word_index * 4)
                            as integer {0..262143};
                        var unpacked = Zeros{32};
                        for byte_index = 0 to byte_count - 1 looplimit 4 do
                            unpacked[(byte_index * 8) +: 8] =
                                TileReadCellByte(source_tile,
                                    row as integer {0..65535},
                                    (word_start + byte_offset + byte_index)
                                        as integer {0..262143});
                        end;
                        joined = TileCubeM32B64WithRawPlaneWord(
                            joined, unpacked, raw_word == 1);
                    end;
                end;
                result = TileInfoWithLogicalElementAndDefined(
                    result, destination_element, joined, TRUE);
            end;
        end;
        result = TileWithValidRegionDefined(result);
        result = TileWithPadding(result, TilePad_Null);
        _Tiles[[destination]] = result;
        return;
    end;
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
