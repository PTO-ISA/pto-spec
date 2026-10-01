<!-- GENERATED FROM: asl/tile/model/memory/gm-atom-red-execution.asl -->
# Gm Atom Red Execution

**Normative ASL source:** `asl/tile/model/memory/gm-atom-red-execution.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-EXECUTION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-execution-purpose role=purpose-scope -->
## 作用与范围

本单元对内存执行 GM atom/red 族。

- `GMRunAtomic` 是共享的 atom 执行体。`GM_ATOM_CAS` 与 `GM_ATOM_VALUE` 调用它。
- `GM_RED_VALUE` 以值 Tile 执行归约，没有目标。
- `GM_RED_POPC` 在每个索引地址上加 1。
- `GMReductionResult` 计算归约结果。
- `GMAtomicOperationFromFunction` 与 `GMReductionOperationFromFunction` 把 TLSU Function 编号映射为操作。

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-execution-concepts role=concepts-state -->
## 概念与可见状态

Function 映射如下：

| Function | 操作 |
| --- | --- |
| 8, 9, 10, 11, 12 | atom CAS, EXCH, MAX, MIN, ADD |
| 14, 15, 16, 17, 18 | atom INC, DEC, AND, OR, XOR |
| 19, 20, 21, 22, 23 | red MAX, MIN, ADD, INC, DEC |
| 24, 25, 26, 27 | red AND, OR, XOR, POPC |

Function 13 是 `GMOV`，不属于本族。atom 映射对未列出的 Function 返回 XOR，归约映射返回 POPC；块分派器只对列出的值调用它们。

通道是索引 Tile 的一个活动有效坐标（对 atom 形式也可以说是目标的坐标，二者有效形状相同）。每个通道恰好产生一个原子事件。

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-execution-rules role=rules-interactions -->
## 规则与交互

每个执行体都有相同的三个步骤。

- 预检：为每个活动通道计算 `base + displacement`，按读探测、按写探测，如果两次转换结果不同则产生 `Fault_DataPage`。快照该通道的值、期望值与替换值操作数。
- 仅 atom 形式：初始化目标。非活动的有效坐标得到 ExecutionMask 的零值或合并值；其他每个物理元素得到填充值。
- 提交：按 `ARBITRARY` 选择决定的顺序处理通道。每个通道加载旧值，计算新值，若执行写入则存储新值，把旧值写入 atom 目标，并记录一个原子事件。

设计要点：所有探测都在第一个事件或本地发布之前完成（NDF `PTO-ATOM-RED-ORDERING-001`）。故障使 GM 保持不变，也不记录事件。其结果是：重试一个发生故障的 atom 或 red 请求不会把更新应用两次。

设计要点：重复的有效地址按实现定义的顺序串行化，并且全部生效。同一地址上的两个 red ADD 通道都会相加，因此对整数 ADD 而言，最终和与顺序无关。

归约形式总是存储新值，并把 `write_performed` 记录为 TRUE。atom CAS 在比较失败时记录 FALSE，且不存储。

`GM_RED_POPC` 总是作用于 U32，没有值 Tile 也没有目标，每个通道恰好加 1。

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-execution-boundaries role=boundaries -->
## 架构边界

这些执行体假定操作数合法性已经通过；块分派器先调用 `TileOperandsLegal_GM_*` 谓词，否则以 `Fault_TileLegality` 报告故障。`PE_MASK=0000` 在 GM atom/red 分派器开头退出，早于其 schema、描述符、类型与内存检查。

每个通道自身是原子的。整个请求不是一个原子事务，其事件携带 `CurrentBundleMemoryOrder()`。排序规则由架构内存模型拥有。

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-execution-example role=example-usage -->
## 非规范阅读示例

`MSCATTER_POPC`（Function 27），基地址 `0x1000`，1 x 3 的 U64 索引 Tile 保存 `0, 4, 0`。GM 在 `0x1000` 处保存 U32 值 10，在 `0x1004` 处保存 20。

- 通道地址为 `0x1000`、`0x1004` 与 `0x1000`；全部 4 字节对齐。
- 两个通道在 `0x1000` 上加 1，无论顺序如何最终为 12。
- 一个通道在 `0x1004` 上加 1，最终为 21。
- 记录三个原子事件，每个的 `write_performed` 都为 TRUE。

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-execution-related role=related-owners-navigation -->
## 相关归属

- [GM atom/red](gm-atom-red.md) 拥有操作/类型矩阵与结果规则。
- [Atomics](atomics.md) 拥有 `MGATHER_CAS` 执行体。
- [Restart](restart.md) 解释先全部探测的重启模式。
- [Memory atomicity](../../../arch/memory-model/atomicity.md) 与 [ordering](../../../arch/memory-model/ordering.md) 拥有事件语义。
- [MSCATTER_POPC](../../memory-and-data-movement/irregular/MSCATTER_POPC.md) 是本族中的一个指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/gm-atom-red-execution.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-EXECUTION","surface":"tile","classification":["model","memory","gm-atom-red-execution"],"depends_on":["PTO-TILE-MODEL-MEMORY-GM-ATOM-RED","PTO-TILE-MODEL-MEMORY-GATHER-SCATTER","PTO-TILE-MODEL-EXECUTION-MASK-STATE"]}
func GMRunAtomic(destination: TileIndex, base_address: Word, indices: TileIndex,
                value: TileIndex, expected: TileIndex, replacement: TileIndex,
                data_type: TileDataType, operation: GMAtomicOperation,
                pad_value: TilePadValue)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    let value_tile = _Tiles[[value]];
    let expected_tile = _Tiles[[expected]];
    let replacement_tile = _Tiles[[replacement]];
    var translated_addresses: TilePayload;
    var write_translated_addresses: TilePayload;
    var original_addresses: TilePayload;
    var lane_order: ScatterLaneOrder;
    var values: TilePayload;
    var expecteds: TilePayload;
    var replacements: TilePayload;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    assert IndexedTLSUExecutionMaskContentsDefined(value);
    assert IndexedTLSUExecutionMaskContentsDefined(expected);
    assert IndexedTLSUExecutionMaskContentsDefined(replacement);
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   destination_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
            let element = TileStorageIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let index_element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryByteDisplacementAddress(base_address,
                index_tile.payload[[index_element]], index_tile.data_type);
            let read_probe = ProbeTileMemoryAccess(address, data_type, FALSE);
            if RaiseDataAccessFault(read_probe, address) then return; end;
            let write_probe = ProbeTileMemoryAccess(address, data_type, TRUE);
            if RaiseDataAccessFault(write_probe, address) then return; end;
            if read_probe.translated_address != write_probe.translated_address then
                SetFault(Fault_DataPage, address);
                return;
            end;
            original_addresses[[element]] = address;
            translated_addresses[[element]] = read_probe.translated_address;
            write_translated_addresses[[element]] = write_probe.translated_address;
            let value_element = TileStorageIndex(value_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let expected_element = TileStorageIndex(expected_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let replacement_element = TileStorageIndex(replacement_tile,
                row as integer {0..65535}, column as integer {0..65535});
            values[[element]] = value_tile.payload[[value_element]];
            expecteds[[element]] = expected_tile.payload[[expected_element]];
            replacements[[element]] = replacement_tile.payload[[replacement_element]];
            lane_order[[lane_count]] = NaturalToWord(element);
            lane_count = (lane_count + 1) as integer {0..PTO_MODEL_TILE_ELEMENTS};
            end;
        end;
    end;
    var result = destination_tile.payload;
    for row = 0 to destination_tile.rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.columns - 1 looplimit 65536 do
            let element = TileStorageIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            var inactive = FALSE;
            if row < destination_tile.valid_rows &&
               column < destination_tile.valid_columns then
                inactive = !BundleExecutionMaskActiveAt(
                    destination_tile.layout,
                    row as integer {0..65535},
                    column as integer {0..65535});
            end;
            result[[element]] = if inactive then
                BundleExecutionMaskDestinationValue(
                    destination_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN})
            else TilePadValueForDataType(pad_value, data_type);
        end;
    end;
    // Duplicate addresses are serialized in an implementation-defined order.
    for position = 0 to lane_count - 1 looplimit PTO_MODEL_TILE_ELEMENTS do
        var selected_position: integer {0..PTO_MODEL_TILE_ELEMENTS-1} =
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
        let element = UInt(lane_order[[position]]) as ModelTileElementIndex;
        let old_raw = LoadTranslatedUnsigned(translated_addresses[[element]],
            TileMemoryElementBytes(data_type));
        let old = DecodeTileMemoryElementRaw(old_raw, data_type, FALSE);
        let (new_value, write_performed) = GMAtomicResult(operation, data_type,
            old, values[[element]], expecteds[[element]], replacements[[element]]);
        if write_performed then
            - = StoreTileMemoryElement(original_addresses[[element]],
                write_translated_addresses[[element]], data_type, FALSE, new_value);
        end;
        result[[element]] = old;
        RecordAtomicEvent(write_translated_addresses[[element]],
            TileMemoryElementBytes(data_type), old_raw,
            NormalizeMemoryAccessValue(new_value, TileMemoryElementBytes(data_type)),
            CurrentBundleMemoryOrder(), write_performed);
    end;
    _Tiles[[destination]].payload = result;
    MarkTilePhysicalRegionDefined(destination);
end;

func GM_ATOM_CAS(operation: GMAtomicOperation, destination: TileIndex, base_address: Word, indices: TileIndex,
                 expected: TileIndex, replacement: TileIndex,
                 pad_value: TilePadValue)
begin
    GMRunAtomic(destination, base_address, indices, expected, expected,
        replacement, _Tiles[[destination]].data_type, operation, pad_value);
end;

func GM_ATOM_VALUE(operation: GMAtomicOperation, destination: TileIndex, base_address: Word, indices: TileIndex,
                   value: TileIndex, pad_value: TilePadValue)
begin
    GMRunAtomic(destination, base_address, indices, value, value, value,
        _Tiles[[destination]].data_type, operation, pad_value);
end;


readonly func GMReductionResult(operation: GMReductionOperation,
                            data_type: TileDataType, old: Word,
                            input: Word) => Word
begin
    case operation of
        when GMReduction_ADD =>
            if TileDataTypeIsFloating(data_type) then
                return GMFloatingAddPTX(data_type, old, input);
            end;
            return old + input;
        when GMReduction_INC => return GMIncValue(old, input);
        when GMReduction_DEC => return GMDecValue(old, input);
        when GMReduction_AND => return old AND input;
        when GMReduction_OR => return old OR input;
        when GMReduction_XOR => return old XOR input;
        when GMReduction_MAX =>
            if TileDataTypeIsSigned(data_type) then
                if SInt(old) > SInt(input) then return old; else return input; end;
            end;
            if UInt(old) > UInt(input) then return old; else return input; end;
        when GMReduction_MIN =>
            if TileDataTypeIsSigned(data_type) then
                if SInt(old) < SInt(input) then return old; else return input; end;
            end;
            if UInt(old) < UInt(input) then return old; else return input; end;
        otherwise => return old;
    end;
end;
func GM_RED_VALUE(operation: GMReductionOperation, base_address: Word,
                  indices: TileIndex, value: TileIndex, pad_value: TilePadValue)
begin
    let data_type = _Tiles[[value]].data_type;
    let value_tile = _Tiles[[value]];
    let index_tile = _Tiles[[indices]];
    var translated_addresses: TilePayload;
    var write_translated_addresses: TilePayload;
    var original_addresses: TilePayload;
    var lane_order: ScatterLaneOrder;
    var values: TilePayload;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    assert IndexedTLSUExecutionMaskContentsDefined(value);
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
            let element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryByteDisplacementAddress(base_address,
                index_tile.payload[[element]], index_tile.data_type);
            let read_probe = ProbeTileMemoryAccess(address, data_type, FALSE);
            if RaiseDataAccessFault(read_probe, address) then return; end;
            let write_probe = ProbeTileMemoryAccess(address, data_type, TRUE);
            if RaiseDataAccessFault(write_probe, address) then return; end;
            if read_probe.translated_address != write_probe.translated_address then
                SetFault(Fault_DataPage, address);
                return;
            end;
            original_addresses[[element]] = address;
            translated_addresses[[element]] = read_probe.translated_address;
            write_translated_addresses[[element]] = write_probe.translated_address;
            let value_element = TileStorageIndex(value_tile,
                row as integer {0..65535}, column as integer {0..65535});
            values[[element]] = value_tile.payload[[value_element]];
            lane_order[[lane_count]] = NaturalToWord(element);
            lane_count = (lane_count + 1) as integer {0..PTO_MODEL_TILE_ELEMENTS};
            end;
        end;
    end;
    for position = 0 to lane_count - 1 looplimit PTO_MODEL_TILE_ELEMENTS do
        var selected_position: integer {0..PTO_MODEL_TILE_ELEMENTS-1} =
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
        let element = UInt(lane_order[[position]]) as ModelTileElementIndex;
        let old_raw = LoadTranslatedUnsigned(translated_addresses[[element]],
            TileMemoryElementBytes(data_type));
        let old = DecodeTileMemoryElementRaw(old_raw, data_type, FALSE);
        let new_value = GMReductionResult(operation, data_type, old,
            values[[element]]);
        - = StoreTileMemoryElement(original_addresses[[element]],
            write_translated_addresses[[element]], data_type, FALSE, new_value);
        RecordAtomicEvent(write_translated_addresses[[element]],
            TileMemoryElementBytes(data_type), old_raw,
            NormalizeMemoryAccessValue(new_value, TileMemoryElementBytes(data_type)),
            CurrentBundleMemoryOrder(), TRUE);
    end;
end;

func GM_RED_POPC(operation: GMReductionOperation, base_address: Word, indices: TileIndex)
begin
    let data_type = TileDataType_U32;
    let index_tile = _Tiles[[indices]];
    var translated_addresses: TilePayload;
    var write_translated_addresses: TilePayload;
    var original_addresses: TilePayload;
    var lane_order: ScatterLaneOrder;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
            let element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryByteDisplacementAddress(base_address,
                index_tile.payload[[element]], index_tile.data_type);
            let read_probe = ProbeTileMemoryAccess(address, data_type, FALSE);
            if RaiseDataAccessFault(read_probe, address) then return; end;
            let write_probe = ProbeTileMemoryAccess(address, data_type, TRUE);
            if RaiseDataAccessFault(write_probe, address) then return; end;
            if read_probe.translated_address != write_probe.translated_address then
                SetFault(Fault_DataPage, address);
                return;
            end;
            original_addresses[[element]] = address;
            translated_addresses[[element]] = read_probe.translated_address;
            write_translated_addresses[[element]] = write_probe.translated_address;
            lane_order[[lane_count]] = NaturalToWord(element);
            lane_count = (lane_count + 1) as integer {0..PTO_MODEL_TILE_ELEMENTS};
            end;
        end;
    end;
    for position = 0 to lane_count - 1 looplimit PTO_MODEL_TILE_ELEMENTS do
        var selected_position: integer {0..PTO_MODEL_TILE_ELEMENTS-1} =
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
        let element = UInt(lane_order[[position]]) as ModelTileElementIndex;
        let old_raw = LoadTranslatedUnsigned(translated_addresses[[element]],
            TileMemoryElementBytes(data_type));
        let old = DecodeTileMemoryElementRaw(old_raw, data_type, FALSE);
        let new_value = old + Zeros{PTO_XLEN} + 1;
        - = StoreTileMemoryElement(original_addresses[[element]],
            write_translated_addresses[[element]], data_type, FALSE, new_value);
        RecordAtomicEvent(write_translated_addresses[[element]],
            TileMemoryElementBytes(data_type), old_raw,
            NormalizeMemoryAccessValue(new_value, TileMemoryElementBytes(data_type)),
            CurrentBundleMemoryOrder(), TRUE);
    end;
end;

pure func GMAtomicOperationFromFunction(function: integer {0..31})
    => GMAtomicOperation
begin
    case function of
        when 8 => return GMAtomic_CAS;
        when 9 => return GMAtomic_EXCH;
        when 10 => return GMAtomic_MAX;
        when 11 => return GMAtomic_MIN;
        when 12 => return GMAtomic_ADD;
        when 14 => return GMAtomic_INC;
        when 15 => return GMAtomic_DEC;
        when 16 => return GMAtomic_AND;
        when 17 => return GMAtomic_OR;
        otherwise => return GMAtomic_XOR;
    end;
end;

pure func GMReductionOperationFromFunction(function: integer {0..31})
    => GMReductionOperation
begin
    case function of
        when 19 => return GMReduction_MAX;
        when 20 => return GMReduction_MIN;
        when 21 => return GMReduction_ADD;
        when 22 => return GMReduction_INC;
        when 23 => return GMReduction_DEC;
        when 24 => return GMReduction_AND;
        when 25 => return GMReduction_OR;
        when 26 => return GMReduction_XOR;
        otherwise => return GMReduction_POPC;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
