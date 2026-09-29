<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-gm-atom-red.asl -->
# TLSU Gm Atom Red

**Normative ASL source:** `asl/block/model/dispatch/tlsu-gm-atom-red.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-GM-ATOM-RED}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gm-atom-red-purpose role=purpose-scope -->
## 用途与范围

本单元是按索引的全局内存原子操作与归约的指令束级处理程序。原子操作（`MGATHER.<op>` 形式）更新每个被寻址的元素，并在新的 Local Tile 中返回旧值。归约（`MSCATTER.<op>` 形式）更新内存而不返回任何值。

`BundleGMAtomRedSelected` 识别有效的 `TileMemory` 描述符，其选择器功能号位于 `8..12` 或 `14..27`。功能号 `13` 是 `GMOV`，被排除在外。`ExecuteBundleGMAtomRedOperation` 校验指令束，并调用 `GM_ATOM_CAS`、`GM_ATOM_VALUE`、`GM_RED_VALUE` 或 `GM_RED_POPC` 之一。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gm-atom-red-concepts role=concepts-state -->
## 概念与可见状态

功能号确定操作及其合法数据类型。

| 功能号 | 种类 | 操作与数据类型 |
| --- | --- | --- |
| `8` | 原子 | CAS：U16、U32、U64 |
| `9`、`10`、`11`、`12` | 原子 | EXCH：U32、U64；MAX 与 MIN：S32、S64、U32、U64；ADD：FP16、BF16、FP32、FP64、S32、U32、U64 |
| `14` 至 `18` | 原子 | INC 与 DEC：U32；AND、OR、XOR：U32、U64 |
| `19` 至 `26` | 归约 | MAX、MIN、ADD、INC、DEC、AND、OR、XOR，类型集合与原子操作相同 |
| `27` | 归约 | POPC：U32 |

每种形式都需要一条 `B.IOR` 记录，其 `source0` 为当前内存代理给出基地址。第一个 `B.IOT` 在 `source0` 中携带索引 Tile。除 POPC 外，它在 `source1` 中携带值 Tile，值 Tile 必须具有操作数据类型。索引 Tile 和值 Tile 必须具有 `B.DIM` 的有效行数和有效列数以及指令束布局，且索引 Tile 为 S32、U32、S64 或 U64。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gm-atom-red-rules role=rules-interactions -->
## 规则与交互

当 `SelectedBundleTileMaskIsZero` 成立时，处理程序首先无效果地返回成功。ASL 注释把这一步放在所有 schema、描述符、类型或内存检查之前。

未知的 TLSU 操作码引发 `Fault_IllegalInstruction`。缺失或非法的 `B.IOR`、Shared 绑定、不一致的 PE 掩码，以及被 `BundleMGATHERDimensionsLegal` 拒绝的维度，引发 `Fault_TileLegality`。

预期的 `B.IOT` 绑定数：CAS 为 2，POPC 为 1，其余为 1，在谓词 Tile 执行掩码下为 2。数目错误引发 `Fault_BundleControl`。绑定形状、数据类型或源形状错误引发 `Fault_TileLegality`。

对于无执行掩码的非 CAS 原子操作，唯一的绑定携带目标和 `last`。在谓词 Tile 执行掩码下，第一个绑定没有目标也没有 `last`，第二个绑定携带一个源、目标和 `last`。除 POPC 外的归约遵循相同模式，但没有目标。POPC 始终使用一个在 `source0` 中携带索引 Tile 的绑定；本处理程序不检查其 `last` 标志，只有在没有执行掩码时才检查它没有目标。

对于原子操作，处理程序检查物理形状、解析目标、校验 Local 生成写者，并检查操作数合法性。解析之后的失败或内存故障会调用 `RollBackBundleTileDestinations`。归约不解析任何目标，因此故障无需回滚。成功时调用 `FinalizeBundleTileAttempt`。

设计要点：只有 `B.IOT` 绑定数错误才引发 `Fault_BundleControl`。缺少 `B.IOR`、存在 Shared 绑定，以及在数目正确的 schema 中操作数错误，都引发 `Fault_TileLegality`。程序可以通过故障种类区分命令流格式错误和操作数错误。

设计要点：处理程序包含功能号 `8` 的 CAS 路径，其注释描述了两命令的 CAS schema。然而 `ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` 先测试 `BundleMGATHERCASSelected`，因此未被更早选择器（例如 CUBE 传输）认领的功能号 `8` 指令束会到达专用 CAS 处理器，本处理程序中的 CAS 路径不会从该分派器到达。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gm-atom-red-boundaries role=boundaries -->
## 架构边界

只有当 TIMG2COL、权重加载、矩阵、CUBE 布局转换、`GMOV` 和 `MGATHER.CAS` 选择器都未匹配时，才会到达本单元。之后由调用者提交或中止 Local 生成。

每种更新的运算，例如 INC 的回绕规则和浮点 ADD，属于 Tile GM 原子与归约所有者。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gm-atom-red-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

假设指令束选择功能号 `21`（归约 ADD），数据类型为 FP32，无执行掩码，`B.DIM` 把 `LB0` 设为 16、`LB1` 设为 1、`LB2` 设为 16。一个 `B.IOT` 携带 U32 索引 Tile 和 FP32 值 Tile，二者都是 1 乘 16，无目标并带 `last`。处理程序调用 `GM_RED_VALUE`，把 16 个值加到内存中，不写任何 Tile。

如果同一指令束选择功能号 `12`（原子 ADD），唯一的绑定还必须携带目标，目标接收 16 个旧值。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gm-atom-red-related role=related-owners-navigation -->
## 相关所有者

- [MGATHER.CAS 分派](tlsu-mgather-cas.md) 是功能号 `8` 实际到达的处理程序。
- [GM 原子与归约类型](../../../tile/model/memory/gm-atom-red.md) 定义数据类型集合。
- [GM 原子与归约执行](../../../tile/model/memory/gm-atom-red-execution.md) 定义内存效果。
- [BSTART.MGATHER.ADD](../../execution/BSTART.MGATHER.ADD.md) 和 [BSTART.MSCATTER.ADD](../../execution/BSTART.MSCATTER.ADD.md) 是示例指令页。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-gm-atom-red.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-GM-ATOM-RED","surface":"block","classification":["model","dispatch","tlsu-gm-atom-red"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS","PTO-TILE-MODEL-MEMORY-GM-ATOM-RED","PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-EXECUTION"]}

readonly func BundleGMAtomRedSelected() => boolean
begin
    if !_BundleOperation.valid ||
       _BundleOperation.operation_class != BundleOperation_TileMemory ||
       !_BundleOperation.selector_valid then return FALSE; end;
    let function = UInt(_BundleOperation.selector[4:0]);
    return (function >= 8 && function <= 12) ||
           (function >= 14 && function <= 27);
end;

readonly func BundleGMAtomRedDataTypeLegal(function: integer {0..31},
                                           data_type: TileDataType) => boolean
begin
    if function <= 18 then
        return GMAtomicOperationDataTypeLegal(
            GMAtomicOperationFromFunction(function), data_type);
    end;
    return GMReductionOperationDataTypeLegal(
        GMReductionOperationFromFunction(function), data_type);
end;

func ExecuteBundleGMAtomRedOperation() => boolean
begin
    // PE_MASK=0000 exits before every schema, descriptor, type, or memory check.
    if SelectedBundleTileMaskIsZero() then return TRUE; end;
    let function = UInt(_BundleOperation.selector[4:0]) as integer {0..31};
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if BundleSharedBindingCount() != 0 ||
       !_BundleScalarBindings[[0]].valid ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !SelectedBundleTileMasksLegal() ||
       !BundleMGATHERDimensionsLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    let atom = function <= 18;
    let cas = function == 8;
    let popc = function == 27;
    var expected_binding_count: integer {1..2} = 1;
    if cas then expected_binding_count = 2; end;
    if execution_mask_tile && !popc && !cas then
        expected_binding_count = 2;
    end;
    if atom && BundleTileBindingCount() != expected_binding_count then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if !atom && BundleTileBindingCount() != expected_binding_count then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    // mgather.cas and the legacy MGATHER.CAS alias use the two-command schema:
    // the first B.IOT carries indices and expected values, while the second
    // carries replacement and the destination.  Other atom forms carry all
    // operands in one destination-bearing B.IOT.
    if !binding.valid || !binding.source0_valid ||
       ((!cas && !popc &&
         (binding.last == execution_mask_tile)) || (cas && binding.last)) ||
       (cas && (binding.destination_valid || !binding.source1_valid)) ||
       (cas && execution_mask_tile &&
        (_BundleTileBindings[[1]].source1_valid == FALSE)) ||
       (!cas && !execution_mask_tile &&
        binding.destination_valid != atom) ||
       (execution_mask_tile && atom && !cas &&
        binding.destination_valid) ||
       (!popc && !cas && !binding.source1_valid) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if execution_mask_tile && !cas && !popc then
        let final_binding = _BundleTileBindings[[1]];
        if !final_binding.valid || !final_binding.source0_valid ||
           final_binding.source1_valid || !final_binding.last ||
           (final_binding.destination_valid != atom) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
    end;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !BundleGMAtomRedDataTypeLegal(function, data_type) ||
       !IndexedTLSUExecutionMaskContentsDefined(binding.source0) ||
       (!popc && (!IndexedTLSUExecutionMaskContentsDefined(binding.source1) ||
           _Tiles[[binding.source1]].data_type != data_type)) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    if _Tiles[[binding.source0]].valid_rows != valid_rows ||
       _Tiles[[binding.source0]].valid_columns != valid_columns ||
       _Tiles[[binding.source0]].layout != CurrentBundleTileLayout() ||
       !IndexedTLSUMemoryIndexDataTypeLegal(
           _Tiles[[binding.source0]].data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !popc && (_Tiles[[binding.source1]].valid_rows != valid_rows ||
       _Tiles[[binding.source1]].valid_columns != valid_columns ||
       _Tiles[[binding.source1]].layout != CurrentBundleTileLayout()) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let base_address = ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source0);
    if atom then
        var destination: TileIndex = if execution_mask_tile && !cas then
            _BundleTileBindings[[1]].destination else binding.destination;
        if cas then
            let second = _BundleTileBindings[[1]];
            if !second.destination_valid || !second.source0_valid ||
               (second.source1_valid != execution_mask_tile) || !second.last ||
               !IndexedTLSUExecutionMaskContentsDefined(second.source0) ||
               _Tiles[[second.source0]].layout !=
                   CurrentBundleTileLayout() then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            destination = second.destination;
        end;
        if !IndexedTLSUPhysicalShapeLegal(CurrentBundleTileLayout(), data_type,
               valid_rows, valid_columns, columns) ||
           !ResolveBundleTileDestinationsWithShapeAndType(TRUE, valid_rows,
               valid_columns, columns, TRUE, data_type) then return FALSE; end;
        if !ValidateBundleLocalGenerationWriters() then
            RollBackBundleTileDestinations(); return FALSE;
        end;
        destination = if cas || execution_mask_tile then
            _BundleTileBindings[[1]].destination
            else _BundleTileBindings[[0]].destination;
        if cas then
            let second = _BundleTileBindings[[1]];
            if !TileOperandsLegal_GM_ATOM_CAS(GMAtomic_CAS, destination, base_address,
                   binding.source0, binding.source1, second.source0,
                   CurrentBundlePadValue()) then
                RollBackBundleTileDestinations();
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            GM_ATOM_CAS(GMAtomic_CAS, destination, base_address,
                binding.source0, binding.source1, second.source0,
                CurrentBundlePadValue());
        else
            if !TileOperandsLegal_GM_ATOM_VALUE(
                   GMAtomicOperationFromFunction(function), destination,
                   base_address, binding.source0, binding.source1,
                   CurrentBundlePadValue()) then
                RollBackBundleTileDestinations();
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            GM_ATOM_VALUE(GMAtomicOperationFromFunction(function), destination,
                base_address, binding.source0, binding.source1,
                CurrentBundlePadValue());
        end;
    elsif popc then
        if !TileOperandsLegal_GM_RED_POPC(GMReduction_POPC, base_address,
               binding.source0) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        GM_RED_POPC(GMReduction_POPC, base_address, binding.source0);
    else
        if !TileOperandsLegal_GM_RED_VALUE(
               GMReductionOperationFromFunction(function), base_address,
               binding.source0, binding.source1, CurrentBundlePadValue()) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        GM_RED_VALUE(GMReductionOperationFromFunction(function), base_address,
            binding.source0, binding.source1, CurrentBundlePadValue());
    end;
    if _LastFault != Fault_None then
        if atom then RollBackBundleTileDestinations(); end;
        return FALSE;
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
