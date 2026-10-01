<!-- GENERATED FROM: asl/tile/model/memory/load-store.asl -->
# Load Store

**Normative ASL source:** `asl/tile/model/memory/load-store.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-LOAD-STORE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-load-store-purpose role=purpose-scope -->
## 作用与范围

本单元拥有元素级 GM 访问辅助函数，以及 Local `TLOAD` 与 `TSTORE` 的执行体。

- `ProbeTileMemoryAccess` 在一次元素访问发生之前对其进行检查。
- `LoadTileMemoryElement` 与 `DecodeTileMemoryElementRaw` 读取并解码一个元素。
- `StoreTileMemoryElement` 写入一个元素。
- `TLOAD` 把一段带步长的 GM 区域复制到 Local Tile；`TSTORE` 把 Local Tile 复制到 GM。

<!-- PTO-READER-BLOCK: tile-model-memory-load-store-concepts role=concepts-state -->
## 概念与可见状态

探测结果（`DataAccessProbe`）返回一个故障码和一个转换后的地址。`ProbeTileMemoryAccess` 探测 `TileMemoryElementBytes(data_type)` 个字节，并以同一值作为对齐要求，因此每次元素访问都必须自然对齐。四位类型探测一个字节。

重放记录是来自架构内存模型的故障精确性状态。`TLOAD` 与 `TSTORE` 用 `BeginMemoryReplay` 打开它，用 `CommitMemoryReplayEffect` 标记每次已完成的访问，成功时用 `CompleteMemoryReplay` 关闭，故障时用 `FlushMemoryReplay` 关闭。

每个记录的加载与存储事件都携带 `CurrentBundleMemoryOrder()`，它由指令束的 acquire 与 release 属性导出。

<!-- PTO-READER-BLOCK: tile-model-memory-load-store-rules role=rules-interactions -->
## 规则与交互

解码：对四位类型，`DecodeTileMemoryElementRaw` 返回所选半字节的零扩展值，S4X2 也是如此。对其他类型，它对有符号整数类型（S8、S16、S32、S64）做符号扩展，其余情况保持原始位不变。

存储：对非四位类型，值被截断到元素宽度后写入。对四位类型，辅助函数读取所在字节，替换其中一个半字节，再写回该字节。

设计要点：四位存储是对字节的读-改-写。相邻半字节保留其原有内存值，因此相邻两列可以由不同的存储写入而互不破坏。

`TLOAD` 按行遍历有效区域。ExecutionMask 下的非活动坐标接收该掩码的零值或合并值，并且不产生访问。活动坐标被探测、加载、记录为加载事件并写入结果。遍历结束后，有效区域被标记为已定义。CUBE 布局随后在其物理尾部接收指令束的 `PadValue`。

`TSTORE` 要求源已分配且内容已定义；在 ExecutionMask 下，它只检查逐元素的源已定义性。它按行主序存储活动的有效坐标。

设计要点：两个执行体都在第一次探测失败时停止。故障之前完成的访问不会被撤销：`TSTORE` 的 GM 写入保持可见。`TLOAD` 执行体把部分结果写入目标，但随后指令束分派会释放由该指令束分配的目标。`FlushMemoryReplay` 只丢弃最后一次已提交效果之后的事件记录。故障精确性契约规定重试会重新执行整个逻辑请求，因此重启不会从内部元素游标继续。

`TLOAD` 为满足以下条件的四位 Tile 提供快速路径：不是 CUBE、尚无已定义的有效元素、无 ExecutionMask、无事件捕获、步长为零、有效区域完整、打包容量占满。它仍通过普通探测路径探测第 0 行的每一列，只有这些字节全部为零时才使用该捷径。

<!-- PTO-READER-BLOCK: tile-model-memory-load-store-boundaries role=boundaries -->
## 架构边界

在这些执行体运行之前，指令束分派已分配 `TLOAD` 目标，并解析了基地址、步长、`PE_MASK` 与维度。schema、描述符与已定义性失败都在那里被拒绝，早于任何访问。

除本循环的程序顺序之外，这些执行体不对 `TSTORE` 各拍之间排序，也不处理 PE 之间的重叠。排序属于架构内存模型。

Shared 形式的 `TLOAD` 与 `TSTORE` 由 shared-movement 单元定义。

<!-- PTO-READER-BLOCK: tile-model-memory-load-store-example role=example-usage -->
## 非规范阅读示例

U4X2 Tile 的 `TSTORE` 以值 `0x5` 写入元素 `(0, 1)`。地址为行基址加 1 / 2 = 0，第 1 列为奇数，因此选择高半字节。

- 该地址处的字节当前为 `0xA7`。
- 辅助函数保留低半字节 `0x7`，并把高半字节替换为 `0x5`。
- 它存储 `0x57`，并记录一个值为 `0x57` 的单字节存储事件。

对于地址以 `0x...1` 结尾的 S16 `TLOAD`，两字节对齐探测以 `Fault_DataAlignment` 失败，该元素的任何字节都不会被读取。

<!-- PTO-READER-BLOCK: tile-model-memory-load-store-related role=related-owners-navigation -->
## 相关归属

- [Stride](stride.md) 计算此处使用的带步长字节地址。
- [Restart](restart.md) 指向重启与精确故障的归属单元。
- [Fault precision](../../../arch/memory-model/fault-precision.md) 拥有重放记录。
- [Memory ordering](../../../arch/memory-model/ordering.md) 拥有已记录事件的顺序。
- [Scalar AGU memory](../../../scalar/model/agu/memory.md) 拥有 `ProbeDataAccess` 以及字节加载与存储原语。
- [Shared movement](shared-movement.md) 拥有 Shared 形式。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/load-store.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-LOAD-STORE","surface":"tile","classification":["model","memory","load-store"],"depends_on":["PTO-TILE-MODEL-MEMORY-STRIDE","PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION","PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA"]}
pure func DecodeTileMemoryElementRaw(raw: Word,
                                     data_type: TileDataType,
                                     high_nibble: boolean) => Word
begin
    let element_bytes = TileMemoryElementBytes(data_type);
    if TileDataTypeIsFourBit(data_type) then
        if high_nibble then
            return ZeroExtend{PTO_XLEN}(raw[7:4]);
        else
            return ZeroExtend{PTO_XLEN}(raw[3:0]);
        end;
    else
        return NormalizeLoadedValue(raw, element_bytes,
            TileDataTypeIsSigned(data_type));
    end;
end;

readonly func LoadTileMemoryElement(translated_address: Word,
                                    data_type: TileDataType,
                                    high_nibble: boolean) => Word
begin
    let element_bytes = TileMemoryElementBytes(data_type);
    let raw = LoadTranslatedUnsigned(translated_address, element_bytes);
    return DecodeTileMemoryElementRaw(raw, data_type, high_nibble);
end;

func StoreTileMemoryElement(original_address: Word,
                            translated_address: Word,
                            data_type: TileDataType,
                            high_nibble: boolean,
                            value: Word) => Word
begin
    let element_bytes = TileMemoryElementBytes(data_type);
    if TileDataTypeIsFourBit(data_type) then
        let old_byte = LoadTranslatedUnsigned(translated_address, 1);
        var stored_byte: Byte = old_byte[7:0];
        if high_nibble then stored_byte[7:4] = value[3:0];
        else stored_byte[3:0] = value[3:0];
        end;
        let stored_value = ZeroExtend{PTO_XLEN}(stored_byte);
        StoreTranslated(original_address, translated_address, 1, stored_value);
        return stored_value;
    else
        let stored_value = NormalizeMemoryAccessValue(value, element_bytes);
        StoreTranslated(original_address, translated_address, element_bytes,
            stored_value);
        return stored_value;
    end;
end;

func ProbeTileMemoryAccess(address: Word, data_type: TileDataType,
                           write: boolean) => DataAccessProbe
begin
    let element_bytes = TileMemoryElementBytes(data_type);
    return ProbeDataAccess(address, element_bytes, element_bytes, write);
end;

func TLOAD(destination: TileIndex, base_address: Word,
           row_stride_bytes: Word)
begin
    let tile = _Tiles[[destination]];
    assert tile.allocated;
    if TileLayoutIsCube(tile.layout) then
        assert TileCubeDescriptorLegal(tile);
    end;
    // Complete packed carriers make the maximum U4 shape representable, but
    // an interpreter-sized translated-address array is still only a carrier
    // cache.  The fast case is limited to ordinary reset-backed zero-stride
    // packed loads and retains the normal translated probe/fault path.
    var packed_zero_fast = PackedTileDataTypeIsFourBit(tile.data_type) &&
        !_BundleExecutionMask.valid &&
        !TileLayoutIsCube(tile.layout) &&
        !_MemoryEventCaptureEnabled &&
        tile.defined_valid_elements == 0 &&
        row_stride_bytes == Zeros{PTO_XLEN} &&
        tile.valid_rows == tile.rows &&
        tile.valid_columns == tile.columns &&
        tile.rows * tile.columns ==
            PackedTileLogicalCapacity(tile.capacity_bytes, tile.data_type);
    if packed_zero_fast then
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let address = TileMemoryStridedByteAddress(base_address,
                0, column as integer {0..65535}, row_stride_bytes,
                tile.data_type);
            let probe = ProbeTileMemoryAccess(address, tile.data_type, FALSE);
            if RaiseDataAccessFault(probe, address) then return; end;
            if LoadTranslatedUnsigned(probe.translated_address,
                   TileMemoryElementBytes(tile.data_type)) !=
                   Zeros{PTO_XLEN} then
                packed_zero_fast = FALSE;
            end;
        end;
    end;
    if packed_zero_fast then
        _Tiles[[destination]] = TileWithPackedZeroValidRegionDefined(tile);
        return;
    end;
    var result = tile;
    BeginMemoryReplay(ReadBPC());
    // First-fault-only execution retains effects completed before the first
    // failing access. The destination is not marked complete until success.
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            if !BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let inactive_value = BundleExecutionMaskDestinationValue(
                    tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
                result = TileInfoWithLogicalElementAndDefined(
                    result, element, inactive_value, TRUE);
            else
            let address = TileMemoryStridedByteAddress(base_address,
                row as integer {0..65535}, column as integer {0..65535},
                row_stride_bytes, tile.data_type);
            let probe = ProbeTileMemoryAccess(address, tile.data_type, FALSE);
            if RaiseDataAccessFault(probe, address) then
                _Tiles[[destination]] = result;
                FlushMemoryReplay();
                return;
            end;
            let translated = probe.translated_address;
            let high_nibble = TileMemoryStridedByteHighNibble(
                column as integer {0..65535}, tile.data_type);
            let raw = LoadTranslatedUnsigned(translated,
                TileMemoryElementBytes(tile.data_type));
            RecordLoadEvent(translated,
                TileMemoryElementBytes(tile.data_type), raw,
                CurrentBundleMemoryOrder());
            CommitMemoryReplayEffect();
            result = TileInfoWithLogicalElement(result, element,
                DecodeTileMemoryElementRaw(raw, tile.data_type, high_nibble));
            result.defined_valid_elements =
                (result.defined_valid_elements + 1) as integer {0..524288};
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    if TileLayoutIsCube(result.layout) then
        result = TileWithPadding(result, CurrentBundlePadValue());
    end;
    _Tiles[[destination]] = result;
    CompleteMemoryReplay();
end;

func TSTORE(base_address: Word, row_stride_bytes: Word, source: TileIndex)
begin
    let tile = _Tiles[[source]];
    var source_contents_defined = tile.contents_defined;
    if _BundleExecutionMask.valid then
        source_contents_defined =
            TileElementwiseSourceContentsDefined(source);
    end;
    assert tile.allocated && source_contents_defined;
    if TileLayoutIsCube(tile.layout) then
        assert TileCubeDescriptorLegal(tile);
    end;
    BeginMemoryReplay(ReadBPC());
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryStridedByteAddress(base_address,
                row as integer {0..65535}, column as integer {0..65535},
                row_stride_bytes, tile.data_type);
            let probe = ProbeTileMemoryAccess(address, tile.data_type, TRUE);
            if RaiseDataAccessFault(probe, address) then
                FlushMemoryReplay();
                return;
            end;
            let translated = probe.translated_address;
            let stored_value = StoreTileMemoryElement(
                address, translated, tile.data_type,
                TileMemoryStridedByteHighNibble(
                    column as integer {0..65535}, tile.data_type),
                TileReadLogicalElement(tile, element));
            RecordStoreEvent(translated,
                TileMemoryElementBytes(tile.data_type), stored_value,
                CurrentBundleMemoryOrder());
            CommitMemoryReplayEffect();
            end;
        end;
    end;
    CompleteMemoryReplay();
end;
```
<!-- GENERATED-ASL-END: unit -->
