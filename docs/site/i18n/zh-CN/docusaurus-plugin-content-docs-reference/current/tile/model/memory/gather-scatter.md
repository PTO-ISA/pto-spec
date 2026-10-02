<!-- GENERATED FROM: asl/tile/model/memory/gather-scatter.asl -->
# Gather Scatter

**Normative ASL source:** `asl/tile/model/memory/gather-scatter.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-GATHER-SCATTER}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-gather-scatter-purpose role=purpose-scope -->
## 作用与范围

本单元拥有索引式 GM 转移以及预取执行体。

- `MGATHER` 按每个索引加载一个元素到目标 Tile。
- `MSCATTER` 按每个索引把一个源元素存储到 GM。
- `MGATHER_MASK` 与 `MSCATTER_MASK` 增加一个谓词 Tile，用于关闭单个通道。
- `TPREFETCHCore` 为全部四个 PE 探测并读取一段带步长区域，不产生 Tile。

索引 Tile 为每个通道保存一个 GM 字节位移。通道是索引 Tile 的一个有效坐标。

<!-- PTO-READER-BLOCK: tile-model-memory-gather-scatter-concepts role=concepts-state -->
## 概念与可见状态

通道地址为 `base + displacement`，由 `TileMemoryByteDisplacementAddress` 计算。索引 Tile 必须是 S32、U32、S64 或 U64；有符号索引做符号扩展。位移不按元素大小缩放。

数据类型由 `IndexedTLSUOrdinaryTransferDataTypeLegal` 检查，它接受普通的非打包类型，也接受四位类型。对四位数据类型，一个索引寻址一个保存两个相邻数据列的字节，因此数据 Tile 的有效列数恰为索引 Tile 的两倍。

当 ExecutionMask（若存在）把某通道标记为活动，并且对 MASK 形式而言谓词元素的位 0 为 1 时，该通道为活动通道。

<!-- PTO-READER-BLOCK: tile-model-memory-gather-scatter-rules role=rules-interactions -->
## 规则与交互

四个索引执行体都先以断言检查操作数：内容已定义、有效形状匹配（四位数据为索引列数的两倍）、布局相等，以及索引与数据类型。两个聚集执行体还断言目标描述符合法性。

设计要点：每个执行体都在第一次内存访问或事件之前探测全部活动通道。只要有一次探测失败，执行体就返回，GM、内存事件与目标 Tile 都保持不变。其结果是：与密集 `TSTORE` 不同，发生故障的索引请求没有部分内存效果。

`MGATHER` 随后填充每个物理目标元素：非活动的有效坐标接收 ExecutionMask 的零值或合并值，其他每个坐标接收该数据类型的 `PadValue`。然后它用加载值覆盖每个活动通道，记录一个加载事件，并把整个物理区域标记为已定义。

设计要点：目标在发布之前已被完整写入，因此即使 `PadValue` 为 Null，`MarkTilePhysicalRegionDefined` 也是正确的。`TilePadValueForDataType` 对 Null 给出零位，因此此处 Null 填充发布的是已定义的零位，而不是未定义元素。

`MSCATTER` 在探测阶段捕获每个活动通道的地址与值，然后通过 `CommitIndexedScatterTransactions` 提交存储。对四位数据，两个相邻源半字节被合并为一个字节，并存储整个字节。

设计要点：提交顺序由 `ARBITRARY` 选择决定，因此不保证行主序。两个通道指向同一地址时，最终保留哪个值由实现定义。需要确定结果的软件必须避免重复的散射地址，或使用原子形式。

`TPREFETCHCore` 用元素行步长和 `TileMemoryIndexedAddress` 计算地址。它在记录任何加载事件之前探测全部四个 PE 的每个元素，并且不写入任何 Tile 状态。

<!-- PTO-READER-BLOCK: tile-model-memory-gather-scatter-boundaries role=boundaries -->
## 架构边界

指令束分派拒绝格式错误的 schema，分配聚集目标，并在之后发生故障时释放它。`B.CATR` atomic 使整个块不可交错，但如 ASL 注释所述，它不选择通道顺序，也不选择重复地址的胜者。

索引聚集与散射不是原子读-改-写操作。原子形式位于 atomics 与 GM atom/red 单元。

<!-- PTO-READER-BLOCK: tile-model-memory-gather-scatter-example role=example-usage -->
## 非规范阅读示例

FP32 的 `MGATHER`，基地址 `0x4000`，1 x 4 的 S32 索引 Tile 保存 `0, 8, -4, 8`：

- 通道地址为 `0x4000`、`0x4008`、`0x3FFC` 与 `0x4008`。四个地址都是 4 的倍数，因此 4 字节对齐探测通过。
- 位于 `0x4008` 的两个通道各自读取同一个值；重复的聚集地址没有害处。

使用同一索引 Tile、源值为 `1.0, 2.0, 3.0, 4.0` 的 FP32 `MSCATTER` 执行四次存储。位置 `0x4000` 与 `0x3FFC` 接收 `1.0` 与 `3.0`。位置 `0x4008` 最终为 `2.0` 或 `4.0`；ASL 不固定是哪一个。

<!-- PTO-READER-BLOCK: tile-model-memory-gather-scatter-related role=related-owners-navigation -->
## 相关归属

- [Addressing](addressing.md) 拥有字节位移与索引地址运算。
- [Indexed layout legality](../legality/indexed-layout.md) 拥有索引与数据类型规则。
- [Atomics](atomics.md) 拥有原子比较并交换聚集。
- [Execution mask state](../execution/execution-mask-state.md) 拥有活动通道与非活动值。
- [Memory atomicity](../../../arch/memory-model/atomicity.md) 与 [ordering](../../../arch/memory-model/ordering.md) 拥有事件语义。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/gather-scatter.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-GATHER-SCATTER","surface":"tile","classification":["model","memory","gather-scatter"],"depends_on":["PTO-TILE-MODEL-MEMORY-LOAD-STORE","PTO-TILE-MODEL-EXECUTION-MASK-STATE"]}
readonly func IndexedGatherInactiveDestinationValue(
    row: integer {0..65535}, column: integer {0..65535}) => Word
begin
    if _BundleExecutionMask.zero_inactive then
        return Zeros{PTO_XLEN};
    end;
    assert _BundleExecutionMask.merge_base_valid;
    let base = _Tiles[[_BundleExecutionMask.merge_base]];
    let element = TileLogicalLinearIndex(base, row, column);
    return TileReadLogicalElement(base, element);
end;

func MGATHER(destination: TileIndex, base_address: Word,
             indices: TileIndex, pad_value: TilePadValue)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    assert IndexedTLSUNumericDescriptorLegal(destination);
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    assert IndexedTLSUDataShapeMatchesIndex(
        destination_tile.valid_rows, destination_tile.valid_columns,
        index_tile.valid_rows, index_tile.valid_columns,
        destination_tile.data_type);
    assert destination_tile.layout == index_tile.layout;
    assert IndexedTLSUMemoryIndexDataTypeLegal(index_tile.data_type);
    assert IndexedTLSUOrdinaryTransferDataTypeLegal(destination_tile.data_type);
    var translated_addresses: TilePayload;
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let index_element = TileStorageIndex(index_tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                let address = TileMemoryByteDisplacementAddress(base_address,
                    index_tile.payload[[index_element]], index_tile.data_type,
                    destination_tile.data_type);
                let probe = ProbeTileMemoryAccess(address,
                    destination_tile.data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then return; end;
                translated_addresses[[index_element]] =
                    probe.translated_address;
            end;
        end;
    end;
    var result = destination_tile;
    for row = 0 to destination_tile.rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            var inactive = FALSE;
            if row < destination_tile.valid_rows &&
               column < destination_tile.valid_columns then
                let transfer_column = if TileDataTypeIsFourBit(
                    destination_tile.data_type) then column DIVRM 2 else column;
                inactive = !BundleExecutionMaskActiveAt(
                    destination_tile.layout,
                    row as integer {0..65535},
                    transfer_column as integer {0..65535});
            end;
            let value = if inactive then
                IndexedGatherInactiveDestinationValue(
                    row as integer {0..65535},
                    column as integer {0..65535})
            else TilePadValueForDataType(
                pad_value, destination_tile.data_type);
            result = TileInfoWithLogicalElementAndDefined(
                result, element, value, TRUE);
        end;
    end;
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
            let index_element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let raw = LoadTranslatedUnsigned(
                translated_addresses[[index_element]],
                TileMemoryElementBytes(destination_tile.data_type));
            RecordLoadEvent(translated_addresses[[index_element]],
                TileMemoryElementBytes(destination_tile.data_type), raw,
                CurrentBundleMemoryOrder());
            let first_column = if TileDataTypeIsFourBit(
                destination_tile.data_type) then 2 * column else column;
            let first = TileLogicalLinearIndex(result,
                row as integer {0..65535},
                first_column as integer {0..65535});
            result = TileInfoWithLogicalElementAndDefined(result, first,
                DecodeTileMemoryElementRaw(
                    raw, destination_tile.data_type, FALSE), TRUE);
            if TileDataTypeIsFourBit(destination_tile.data_type) then
                let second = TileLogicalLinearIndex(result,
                    row as integer {0..65535},
                    (first_column + 1) as integer {0..65535});
                result = TileInfoWithLogicalElementAndDefined(result, second,
                    DecodeTileMemoryElementRaw(
                        raw, destination_tile.data_type, TRUE), TRUE);
            end;
            end;
        end;
    end;
    _Tiles[[destination]] = result;
    MarkTilePhysicalRegionDefined(destination);
end;

func MGATHER(destination: TileIndex, base_address: Word, indices: TileIndex)
begin
    MGATHER(destination, base_address, indices, TilePad_Null);
end;

func CommitIndexedScatterTransactions(
    data_type: TileDataType, lane_order: ScatterLaneOrder,
    lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS},
    original_addresses: TilePayload,
    translated_addresses: TilePayload, values: TilePayload)
begin
    // Duplicate-address lanes have an implementation-defined winner.  B.CATR
    // atomic makes the whole block non-interleavable, but does not select an
    // internal lane order or a duplicate-address winner.
    var commit_order = lane_order;
    if lane_count > 0 then
        for position = 0 to lane_count - 1
            looplimit PTO_MODEL_TILE_ELEMENTS do
            var selected_position:
                integer {0..PTO_MODEL_TILE_ELEMENTS-1} =
                    position as integer {0..PTO_MODEL_TILE_ELEMENTS-1};
            var selected = FALSE;
            for candidate_position = position to lane_count - 1
                looplimit PTO_MODEL_TILE_ELEMENTS do
                if !selected then
                    if ARBITRARY: boolean then
                        selected_position = candidate_position as
                            integer {0..PTO_MODEL_TILE_ELEMENTS-1};
                        selected = TRUE;
                    end;
                end;
            end;
            let selected_element = commit_order[[selected_position]];
            commit_order[[selected_position]] = commit_order[[position]];
            commit_order[[position]] = selected_element;
            let element = UInt(commit_order[[position]]) as
                ModelTileElementIndex;
            var stored_value = values[[element]];
            if TileDataTypeIsFourBit(data_type) then
                StoreTranslated(original_addresses[[element]],
                    translated_addresses[[element]], 1, stored_value);
            else
                stored_value = StoreTileMemoryElement(
                    original_addresses[[element]],
                    translated_addresses[[element]], data_type, FALSE,
                    values[[element]]);
            end;
            RecordStoreEvent(translated_addresses[[element]],
                TileMemoryElementBytes(data_type), stored_value,
                CurrentBundleMemoryOrder());
        end;
    end;
end;

func MSCATTER(base_address: Word, source: TileIndex, indices: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    assert IndexedTLSUExecutionMaskContentsDefined(source);
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    assert IndexedTLSUDataShapeMatchesIndex(
        source_tile.valid_rows, source_tile.valid_columns,
        index_tile.valid_rows, index_tile.valid_columns,
        source_tile.data_type);
    assert source_tile.layout == index_tile.layout;
    assert IndexedTLSUMemoryIndexDataTypeLegal(index_tile.data_type);
    assert IndexedTLSUOrdinaryTransferDataTypeLegal(source_tile.data_type);
    var lane_order: ScatterLaneOrder;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    var values: TilePayload;
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
            let index_element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryByteDisplacementAddress(base_address,
                index_tile.payload[[index_element]], index_tile.data_type,
                source_tile.data_type);
            let probe = ProbeTileMemoryAccess(address,
                source_tile.data_type, TRUE);
            if RaiseDataAccessFault(probe, address) then return; end;
            original_addresses[[index_element]] = address;
            translated_addresses[[index_element]] = probe.translated_address;
            let first_column = if TileDataTypeIsFourBit(source_tile.data_type)
                then 2 * column else column;
            let first = TileLogicalLinearIndex(source_tile,
                row as integer {0..65535},
                first_column as integer {0..65535});
            values[[index_element]] = TileReadLogicalElement(
                source_tile, first);
            if TileDataTypeIsFourBit(source_tile.data_type) then
                let second = TileLogicalLinearIndex(source_tile,
                    row as integer {0..65535},
                    (first_column + 1) as integer {0..65535});
                values[[index_element]][7:4] =
                    TileReadLogicalElement(source_tile, second)[3:0];
            end;
            lane_order[[lane_count]] = NaturalToWord(index_element);
            lane_count = (lane_count + 1) as
                integer {0..PTO_MODEL_TILE_ELEMENTS};
            end;
        end;
    end;
    CommitIndexedScatterTransactions(source_tile.data_type, lane_order,
        lane_count, original_addresses, translated_addresses, values);
end;

type CorePEPrefetchAddresses of array [[PTO_MODEL_MEMORY_AGENTS]] of TilePayload;

func TPREFETCHCore(base_addresses: CorePEWords,
                   row_stride_elements: CorePEWords,
                   valid_columns: integer {1..65535},
                   valid_rows: integer {1..65535},
                   columns: integer {1..65535},
                   data_type: TileDataType)
begin
    assert valid_columns <= columns;
    assert IsNonzeroPowerOfTwo(columns);
    assert valid_rows * valid_columns <= PTO_MODEL_TILE_ELEMENTS;
    var translated_addresses: CorePEPrefetchAddresses;
    // TPREFETCH is one four-PE block attempt.  Probe every typed element of
    // every PE before recording the first event so a fault cannot expose a
    // partial request or event prefix from an earlier PE.
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        for row = 0 to valid_rows - 1 looplimit 65536 do
            for column = 0 to valid_columns - 1 looplimit 65536 do
                let element = (row * valid_columns + column) as
                    ModelTileElementIndex;
                let memory_index = TileMemoryStridedIndex(
                    row as integer {0..65535},
                    column as integer {0..65535},
                    row_stride_elements[[agent]]);
                let address = TileMemoryIndexedAddress(
                    base_addresses[[agent]], memory_index, data_type);
                let probe = ProbeTileMemoryAccess(address, data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then return; end;
                translated_addresses[[agent]][[element]] =
                    probe.translated_address;
            end;
        end;
    end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        for row = 0 to valid_rows - 1 looplimit 65536 do
            for column = 0 to valid_columns - 1 looplimit 65536 do
                let element = (row * valid_columns + column) as
                    ModelTileElementIndex;
                let translated_address =
                    translated_addresses[[agent]][[element]];
                let value = LoadTranslatedUnsigned(translated_address,
                    TileMemoryElementBytes(data_type));
                RecordLoadEventForAgent(agent, translated_address,
                    TileMemoryElementBytes(data_type), value,
                    CurrentBundleMemoryOrder());
            end;
        end;
    end;
end;

// The generated direct-operation dispatcher carries one decoded base and
// stride value.  Its wrapper applies those values to all four PEs; complete
// architectural bundles use ExecuteBundleTPREFETCHOperation below to read the
// same selectors independently from each PE-private GPR file.
func TPREFETCHAllPEs(base_address: Word, row_stride_elements: Word,
                     valid_columns: integer {1..65535},
                     valid_rows: integer {1..65535},
                     columns: integer {1..65535},
                     data_type: TileDataType)
begin
    var base_addresses: CorePEWords;
    var row_strides: CorePEWords;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        base_addresses[[agent]] = base_address;
        row_strides[[agent]] = row_stride_elements;
    end;
    TPREFETCHCore(base_addresses, row_strides, valid_columns, valid_rows,
        columns, data_type);
end;

func TPREFETCH(base_address: Word, row_stride_elements: Word,
               valid_columns: integer {1..65535},
               valid_rows: integer {1..65535},
               columns: integer {1..65535})
begin
    TPREFETCHAllPEs(base_address, row_stride_elements, valid_columns,
        valid_rows, columns, TileDataTypeFromEncoding(
            CurrentBundleTileOperationDataTypeCode()
                as TileDataTypeEncoding));
end;

func MGATHER_MASK(destination: TileIndex, base_address: Word,
                  indices: TileIndex, mask: TileIndex,
                  pad_value: TilePadValue)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    let mask_tile = _Tiles[[mask]];
    assert IndexedTLSUNumericDescriptorLegal(destination);
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    assert IndexedTLSUPredicateValuesLegal(mask);
    assert IndexedTLSUDataShapeMatchesIndex(
        destination_tile.valid_rows, destination_tile.valid_columns,
        index_tile.valid_rows, index_tile.valid_columns,
        destination_tile.data_type);
    assert index_tile.valid_rows == mask_tile.valid_rows;
    assert index_tile.valid_columns == mask_tile.valid_columns;
    assert destination_tile.layout == index_tile.layout;
    assert destination_tile.layout == mask_tile.layout;
    assert IndexedTLSUMemoryIndexDataTypeLegal(index_tile.data_type);
    assert IndexedTLSUOrdinaryTransferDataTypeLegal(destination_tile.data_type);
    var translated_addresses: TilePayload;
    var active_lanes: bits(PTO_MODEL_TILE_ELEMENTS) =
        Zeros{PTO_MODEL_TILE_ELEMENTS};
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            let index_element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) &&
               ReadIndexedTLSUPredicate(mask,
                row as integer {0..65535},
                column as integer {0..65535}) then
                let address = TileMemoryByteDisplacementAddress(base_address,
                    index_tile.payload[[index_element]], index_tile.data_type,
                    destination_tile.data_type);
                let probe = ProbeTileMemoryAccess(address,
                    destination_tile.data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then return; end;
                translated_addresses[[index_element]] = probe.translated_address;
                active_lanes[index_element] = '1';
            end;
        end;
    end;
    var result = destination_tile;
    for row = 0 to destination_tile.rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            var inactive = FALSE;
            if row < destination_tile.valid_rows &&
               column < destination_tile.valid_columns then
                let transfer_column = if TileDataTypeIsFourBit(
                    destination_tile.data_type) then column DIVRM 2 else column;
                inactive = !BundleExecutionMaskActiveAt(
                    destination_tile.layout,
                    row as integer {0..65535},
                    transfer_column as integer {0..65535});
            end;
            let value = if inactive then
                IndexedGatherInactiveDestinationValue(
                    row as integer {0..65535},
                    column as integer {0..65535})
            else TilePadValueForDataType(
                pad_value, destination_tile.data_type);
            result = TileInfoWithLogicalElementAndDefined(
                result, element, value, TRUE);
        end;
    end;
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            let index_element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if active_lanes[index_element] == '1' then
                let raw = LoadTranslatedUnsigned(
                    translated_addresses[[index_element]],
                    TileMemoryElementBytes(destination_tile.data_type));
                RecordLoadEvent(translated_addresses[[index_element]],
                    TileMemoryElementBytes(destination_tile.data_type), raw,
                    CurrentBundleMemoryOrder());
                let first_column = if TileDataTypeIsFourBit(
                    destination_tile.data_type) then 2 * column else column;
                let first = TileLogicalLinearIndex(result,
                    row as integer {0..65535},
                    first_column as integer {0..65535});
                result = TileInfoWithLogicalElementAndDefined(result, first,
                    DecodeTileMemoryElementRaw(
                        raw, destination_tile.data_type, FALSE), TRUE);
                if TileDataTypeIsFourBit(destination_tile.data_type) then
                    let second = TileLogicalLinearIndex(result,
                        row as integer {0..65535},
                        (first_column + 1) as integer {0..65535});
                    result = TileInfoWithLogicalElementAndDefined(result, second,
                        DecodeTileMemoryElementRaw(
                            raw, destination_tile.data_type, TRUE), TRUE);
                end;
            end;
        end;
    end;
    _Tiles[[destination]] = result;
    MarkTilePhysicalRegionDefined(destination);
end;

func MSCATTER_MASK(base_address: Word, source: TileIndex,
                   indices: TileIndex, mask: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    let mask_tile = _Tiles[[mask]];
    assert IndexedTLSUExecutionMaskContentsDefined(source);
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    assert IndexedTLSUPredicateValuesLegal(mask);
    assert IndexedTLSUDataShapeMatchesIndex(
        source_tile.valid_rows, source_tile.valid_columns,
        index_tile.valid_rows, index_tile.valid_columns,
        source_tile.data_type);
    assert index_tile.valid_rows == mask_tile.valid_rows;
    assert index_tile.valid_columns == mask_tile.valid_columns;
    assert source_tile.layout == index_tile.layout;
    assert source_tile.layout == mask_tile.layout;
    assert IndexedTLSUMemoryIndexDataTypeLegal(index_tile.data_type);
    assert IndexedTLSUOrdinaryTransferDataTypeLegal(source_tile.data_type);
    var lane_order: ScatterLaneOrder;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    var values: TilePayload;
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            let index_element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) &&
               ReadIndexedTLSUPredicate(mask,
                row as integer {0..65535},
                column as integer {0..65535}) then
            let address = TileMemoryByteDisplacementAddress(base_address,
                index_tile.payload[[index_element]], index_tile.data_type,
                source_tile.data_type);
                let probe = ProbeTileMemoryAccess(address,
                    source_tile.data_type, TRUE);
                if RaiseDataAccessFault(probe, address) then return; end;
                original_addresses[[index_element]] = address;
                translated_addresses[[index_element]] = probe.translated_address;
                let first_column = if TileDataTypeIsFourBit(
                    source_tile.data_type) then 2 * column else column;
                let first = TileLogicalLinearIndex(source_tile,
                    row as integer {0..65535},
                    first_column as integer {0..65535});
                values[[index_element]] = TileReadLogicalElement(
                    source_tile, first);
                if TileDataTypeIsFourBit(source_tile.data_type) then
                    let second = TileLogicalLinearIndex(source_tile,
                        row as integer {0..65535},
                        (first_column + 1) as integer {0..65535});
                    values[[index_element]][7:4] =
                        TileReadLogicalElement(source_tile, second)[3:0];
                end;
                lane_order[[lane_count]] = NaturalToWord(index_element);
                lane_count = (lane_count + 1) as
                    integer {0..PTO_MODEL_TILE_ELEMENTS};
            end;
        end;
    end;
    CommitIndexedScatterTransactions(source_tile.data_type, lane_order,
        lane_count, original_addresses, translated_addresses, values);
end;
```
<!-- GENERATED-ASL-END: unit -->
