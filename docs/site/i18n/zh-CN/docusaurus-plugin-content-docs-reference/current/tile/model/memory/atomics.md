<!-- GENERATED FROM: asl/tile/model/memory/atomics.asl -->
# Atomics

**Normative ASL source:** `asl/tile/model/memory/atomics.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-ATOMICS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-atomics-purpose role=purpose-scope -->
## 作用与范围

本单元拥有 `MGATHER_CAS`，即索引式原子比较并交换聚集。对每个活动通道，它读取一个 GM 元素，与期望值比较，相等时写入替换值，并把观察到的值返回到目标 Tile。

另一个没有 `pad_value` 参数的重载以 `TilePad_Null` 调用前者。

<!-- PTO-READER-BLOCK: tile-model-memory-atomics-concepts role=concepts-state -->
## 概念与可见状态

`MGATHER_CAS` 接收四个 Tile、一个基地址和一个填充值：

- `indices` 为每个通道保存一个字节位移（S32、U32、S64 或 U64）。
- `expected` 与 `replacement` 为每个通道保存比较值与新值。
- `destination` 接收每个通道观察到的旧值。

原子事件是对一个地址的一次读-改-写。`RecordAtomicEvent` 记录旧的原始值、将要写入的值、指令束内存顺序，以及是否发生了写入。

Function 8 的块分派器只接受 U16、U32 与 U64 转移类型。本执行体中的断言更弱：`IndexedTLSUTransferDataTypeLegal` 只排除四位类型。

<!-- PTO-READER-BLOCK: tile-model-memory-atomics-rules role=rules-interactions -->
## 规则与交互

阶段 1，预检：对每个活动通道，执行体计算 `base + displacement`，先按读、再按写探测，如果两次转换结果不同则以 `Fault_DataPage` 报告故障。它记录地址，并快照期望值与替换值。

阶段 2，初始化：每个物理目标元素接收填充值，但非活动的有效坐标接收 ExecutionMask 的零值或合并值。

阶段 3，原子更新：通道按 `ARBITRARY` 选择决定的顺序处理。每个通道加载旧值，把它存入目标，在元素宽度上与 `expected` 比较，仅在匹配时存储 `replacement`，并记录一个原子事件。最后整个物理区域被标记为已定义。

设计要点：所有读与写探测都在第一个原子效果之前完成（NDF `PTO-MGATHER-CAS-PUBLICATION-001`）。因此故障使 GM 保持不变，也不产生原子事件。随后指令束分派释放它所分配的目标。

设计要点：期望值与替换值在阶段 1 被快照。如果其中某个 Tile 同时是目标，阶段 2 与阶段 3 的写入不会改变参与比较的值。

设计要点：重复地址按实现定义的顺序串行化，行主序不是架构行为（NDF `PTO-MGATHER-CAS-ATOMIC-001`）。每个通道仍是一次完整的原子读-改-写，因此每个通道观察到的是在它之前运行的那个通道留下的值。

<!-- PTO-READER-BLOCK: tile-model-memory-atomics-boundaries role=boundaries -->
## 架构边界

原子性是逐通道的。执行体不会使整个请求成为原子操作，除了以 `CurrentBundleMemoryOrder()` 标记的逐通道事件之外，也不增加排序。这些事件规则由内存模型的 atomicity 与 ordering 单元拥有。

通用 GM atom/red 族有自己的 CAS 路径 `GM_ATOM_CAS`。在当前块分派器中，Function 8 先被 `MGATHER_CAS` 选择器识别，并到达本单元的执行体。

<!-- PTO-READER-BLOCK: tile-model-memory-atomics-example role=example-usage -->
## 非规范阅读示例

U32 `MGATHER_CAS`，基地址 `0x8000`，1 x 2 的索引 Tile 保存 `0, 0`。GM 在 `0x8000` 处保存 5。通道 0 的期望值为 5、替换值为 9；通道 1 的期望值为 5、替换值为 3。

两个通道都指向 `0x8000`，因此 ASL 允许任一顺序。

- 通道 0 先执行：它观察到 5，匹配并写入 9。通道 1 观察到 9，失败，不写入。目标为 `5, 9`，GM 最终为 9。
- 通道 1 先执行：它观察到 5 并写入 3。通道 0 观察到 3 并失败。目标为 `3, 5`，GM 最终为 3。

两种结果都记录两个原子事件，一个执行了写入，一个没有。

<!-- PTO-READER-BLOCK: tile-model-memory-atomics-related role=related-owners-navigation -->
## 相关归属

- [GM atom/red](gm-atom-red.md) 与 [GM atom/red execution](gm-atom-red-execution.md) 拥有其他原子操作。
- [Gather and scatter](gather-scatter.md) 拥有非原子的索引转移。
- [Memory atomicity](../../../arch/memory-model/atomicity.md) 拥有原子事件。
- [Memory ordering](../../../arch/memory-model/ordering.md) 拥有原子排序点。
- [MGATHER_CAS](../../memory-and-data-movement/irregular/MGATHER_CAS.md) 是指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/atomics.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-ATOMICS","surface":"tile","classification":["model","memory","atomics"],"depends_on":["PTO-TILE-MODEL-MEMORY-GATHER-SCATTER","PTO-ARCH-MEMORY-MODEL-ATOMICITY","PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA","PTO-TILE-MODEL-EXECUTION-MASK-STATE"]}
func MGATHER_CAS(destination: TileIndex, base_address: Word,
                 indices: TileIndex,
                 expected: TileIndex, replacement: TileIndex,
                 pad_value: TilePadValue)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    let expected_payload = _Tiles[[expected]].payload;
    let replacement_payload = _Tiles[[replacement]].payload;
    assert IndexedTLSUNumericDescriptorLegal(destination);
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    assert IndexedTLSUExecutionMaskContentsDefined(expected);
    assert IndexedTLSUExecutionMaskContentsDefined(replacement);
    assert destination_tile.valid_rows == index_tile.valid_rows;
    assert destination_tile.valid_columns == index_tile.valid_columns;
    assert IndexedTLSUMemoryIndexDataTypeLegal(index_tile.data_type);
    assert IndexedTLSUTransferDataTypeLegal(destination_tile.data_type);
    let index_payload = index_tile.payload;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    var write_translated_addresses: TilePayload;
    var expected_values: TilePayload;
    var replacement_values: TilePayload;
    var lane_order: ScatterLaneOrder;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    var result = destination_tile;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   destination_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
            let destination_element = TileStorageIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let index_element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let expected_element = TileStorageIndex(_Tiles[[expected]],
                row as integer {0..65535}, column as integer {0..65535});
            let replacement_element = TileStorageIndex(_Tiles[[replacement]],
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryByteDisplacementAddress(base_address,
                index_payload[[index_element]], index_tile.data_type);
            let read_probe = ProbeTileMemoryAccess(address,
                destination_tile.data_type, FALSE);
            if RaiseDataAccessFault(read_probe, address) then return; end;
            let write_probe = ProbeTileMemoryAccess(address,
                destination_tile.data_type, TRUE);
            if RaiseDataAccessFault(write_probe, address) then return; end;
            if read_probe.translated_address != write_probe.translated_address then
                SetFault(Fault_DataPage, address);
                return;
            end;
            original_addresses[[destination_element]] = address;
            translated_addresses[[destination_element]] =
                read_probe.translated_address;
            write_translated_addresses[[destination_element]] =
                write_probe.translated_address;
            expected_values[[destination_element]] =
                expected_payload[[expected_element]];
            replacement_values[[destination_element]] =
                replacement_payload[[replacement_element]];
            lane_order[[lane_count]] = NaturalToWord(destination_element);
            lane_count = (lane_count + 1) as
                integer {0..PTO_MODEL_TILE_ELEMENTS};
            end;
        end;
    end;
    for row = 0 to destination_tile.rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            var inactive = FALSE;
            if row < destination_tile.valid_rows &&
               column < destination_tile.valid_columns then
                inactive = !BundleExecutionMaskActiveAt(
                    destination_tile.layout,
                    row as integer {0..65535},
                    column as integer {0..65535});
            end;
            let initial_value = if inactive then
                BundleExecutionMaskDestinationValue(
                    destination_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN})
            else TilePadValueForDataType(
                pad_value, destination_tile.data_type);
            result = TileInfoWithLogicalElementAndDefined(
                result, element, initial_value, TRUE);
        end;
    end;
    // Duplicate addresses are serialized in an implementation-defined order.
    // Each selected lane remains one atomic read-modify-write, but neither
    // row-major order nor another fixed order becomes architectural.
    for position = 0 to lane_count - 1 looplimit PTO_MODEL_TILE_ELEMENTS do
            var selected_position:
                integer {0..PTO_MODEL_TILE_ELEMENTS-1} =
                    position as integer {0..PTO_MODEL_TILE_ELEMENTS-1};
            var selected = FALSE;
            for candidate_position = position to lane_count - 1
                looplimit PTO_MODEL_TILE_ELEMENTS do
                if !selected && ARBITRARY: boolean then
                    selected_position = candidate_position as
                        integer {0..PTO_MODEL_TILE_ELEMENTS-1};
                    selected = TRUE;
                end;
            end;
            let selected_element = lane_order[[selected_position]];
            lane_order[[selected_position]] = lane_order[[position]];
            lane_order[[position]] = selected_element;
            let element = UInt(lane_order[[position]]) as
                ModelTileElementIndex;
            let old_raw = LoadTranslatedUnsigned(
                translated_addresses[[element]],
                TileMemoryElementBytes(destination_tile.data_type));
            let old_value = DecodeTileMemoryElementRaw(
                old_raw, destination_tile.data_type, FALSE);
            result = TileInfoWithLogicalElementAndDefined(result,
                element as PackedTileElementIndex, old_value, TRUE);
            let succeeds = NormalizeMemoryAccessValue(old_value,
                TileMemoryElementBytes(destination_tile.data_type)) ==
                NormalizeMemoryAccessValue(expected_values[[element]],
                    TileMemoryElementBytes(destination_tile.data_type));
            let write_value = NormalizeMemoryAccessValue(
                replacement_values[[element]],
                TileMemoryElementBytes(destination_tile.data_type));
            if succeeds then
                - = StoreTileMemoryElement(original_addresses[[element]],
                    write_translated_addresses[[element]],
                    destination_tile.data_type, FALSE,
                    replacement_values[[element]]);
            end;
            RecordAtomicEvent(write_translated_addresses[[element]],
                TileMemoryElementBytes(destination_tile.data_type), old_raw,
                write_value, CurrentBundleMemoryOrder(), succeeds);
    end;
    _Tiles[[destination]] = result;
    MarkTilePhysicalRegionDefined(destination);
end;

func MGATHER_CAS(destination: TileIndex, base_address: Word,
                 indices: TileIndex,
                 expected: TileIndex,
                 replacement: TileIndex)
begin
    MGATHER_CAS(destination, base_address, indices, expected, replacement,
        TilePad_Null);
end;
```
<!-- GENERATED-ASL-END: unit -->
