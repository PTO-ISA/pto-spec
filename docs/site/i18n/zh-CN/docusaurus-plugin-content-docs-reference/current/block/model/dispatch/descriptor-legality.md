<!-- GENERATED FROM: asl/block/model/dispatch/descriptor-legality.asl -->
# Descriptor Legality

**Normative ASL source:** `asl/block/model/dispatch/descriptor-legality.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-descriptor-legality-purpose role=purpose-scope -->
## 用途与范围

本单元决定从 `BSTART` 形式解码得到的操作描述符能否被安装，以及后续分派如何读取它。操作描述符是记录 `operation_class`、`selector`、`data_type`、`mode` 和 `branch_type` 的记录，用来指定指令束的操作。

它还拥有执行期间使用的三个指令束范围检查：有效数据类型、assemble 输出结构，以及操作数计数检查 `BundleOperationBindingsComplete`。

<!-- PTO-READER-BLOCK: block-model-dispatch-descriptor-legality-concepts role=concepts-state -->
## 概念与可见状态

本单元不写入任何状态。它读取已安装的描述符 `_BundleOperation`、`B.DATR` 状态 `_BundleDataAttributes`、Tile 与 Shared 绑定、`_BundleExecutionMask` 以及 `_BundleFixedPointAttributes`。

- 具体数据类型编码为 0 到 21 或 24 到 28。编码 31 是 `DTYPE_NONE`，它是字段级哨兵值，没有元素宽度。`BundleDataTypeFieldValid` 接受具体编码或 `DTYPE_NONE`。
- `BundleSelectorCode` 构成 12 位解码码。若 `mode` 有效，mode 填入位 6 到 5，选择子的位 4 到 0 填入位 4 到 0。否则 10 位选择子填入位 9 到 0。
- `BundleTileDecodeFamily` 把 Tile 元素、Tile 内存和 Tile 矩阵类映射到 `TEPL`、`TLSU` 和 `CUBE` 解码族。
- 合法的分支类型是 `001`、`101`、`110` 或 `111`，分别表示顺序执行、间接、间接调用和返回。

<!-- PTO-READER-BLOCK: block-model-dispatch-descriptor-legality-rules role=rules-interactions -->
## 规则与交互

`BundleOperationDescriptorLegal` 按以下顺序应用规则。

1. 具有 `BSTART.TIMG2COL` 形式身份（形式 94）的描述符，只有作为精确的 `TIMG2COL` 描述符时才合法：Tile 内存类、选择子 28、带数据类型、无 mode、无分支类型，且数据类型编码属于受支持的 `TIMG2COL` 集合。
2. 若存在分支类型，它必须合法。
3. Tile 类描述符需要选择子和有效的数据类型字段，且其解码码必须在其解码族中指定某个操作。随后数据类型必须是具体类型，除非描述符选择 `TMOV`（Tile 内存编码 2）。
4. 定点类描述符总是非法。其他类合法。

`ExecuteDecodedBundleStart` 在提交前驱指令束之前调用此检查，然后调用配置档的适用性规则。任一失败都会在该 `BSTART` 处引发 `Fault_IllegalInstruction`。

设计要点：该检查在前驱提交之前运行。因此描述符非法的 `BSTART` 会直接故障，而不会先提交它之前的指令束。

设计要点：只有 `TMOV` 接受 `DTYPE_NONE`。对该操作，`ResolveBundleEffectiveDataType` 可以从第一个描述符已配置的已绑定 Local 源推断类型，或从描述符合法且未被消费的 Shared 源绑定推断类型。其他操作在 `ResolveBundleEffectiveDataType` 中没有源推断，因此描述符检查要求它们在 `BSTART` 处给出具体类型。

`ResolveBundleEffectiveDataType` 返回以下来源中的第一个：具体的 `B.DATR` 类型、具体的描述符类型、`TMOV` 推断。若都不适用，它返回假。ASL 注释说明此时附带的 FP64 值不可观察，也不是 `DTYPE_NONE` 的含义。

`BundleOperationBindingsComplete` 比较已绑定的 Tile 操作数数量与操作期望的数量。对于矩阵操作，`B.FPATR` 会增加 RowMax、GroupMax、CScale 和参数操作数。谓词 Tile 执行掩码会增加一个源。`TCMP`、`TCMPS`、`TSEL` 和 `TSELS` 拥有各自的 schema，`TGPR2T` 具有固定形状。矩阵目标的 Tile ID 必须互不相同。对任何操作，Local 源加父引用都不得超过 8 个；矩阵操作还不得超过 9 个源或 3 个目标，因此对源起约束作用的是 8 这一上限。

<!-- PTO-READER-BLOCK: block-model-dispatch-descriptor-legality-boundaries role=boundaries -->
## 架构边界

本单元不解码字段；描述符由解码单元构建。它本身也不引发故障。调用者选择故障：开始路径使用 `Fault_IllegalInstruction`，而当 `BundleAssembleOutputStructureLegal` 或 `BundleOperationBindingsComplete` 失败时，Tile 执行路径引发 `Fault_BundleControl`。若干专用处理程序，例如 `GMOV` 和 `MGATHER`，也会调用 `BundleOperationBindingsComplete`。

<!-- PTO-READER-BLOCK: block-model-dispatch-descriptor-legality-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

`DataType` 为 31 的 `BSTART.TMOV` 解码为选择子 2、数据类型为 `DTYPE_NONE` 的 Tile 内存描述符。规则 3 识别出 `TMOV`，因此该描述符合法。如果唯一的 `B.IOT` 源是类型为 `FP16` 的已配置 Tile，且没有 `B.DATR` 提供具体类型，则有效类型为 `FP16`。

同样的编码 31 出现在选择 `TADD` 的 `BSTART.VEC` 形式上时根本不会到达此检查：`BSTART.VEC` 背后的 `BSTART.TEPL` 编码只接受具体的 `DataType` 编码，因此 `CommandFormOperandsLegal` 先拒绝它，该 `BSTART` 引发 `Fault_IllegalInstruction`。规则 3 是同一限制在描述符层面的防护。

<!-- PTO-READER-BLOCK: block-model-dispatch-descriptor-legality-related role=related-owners-navigation -->
## 相关所有者

- [解码](decode.md) 构建本单元检查的描述符。
- [指令束开始分派](start.md) 在提交前驱之前调用描述符检查。
- [Tile 执行分派](tile-execution.md) 调用结构检查和操作数计数检查。
- [TMOV](../../../tile/layout-and-rearrangement/layout/TMOV.md) 是可以携带 `DTYPE_NONE` 的操作。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/descriptor-legality.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","surface":"block","classification":["model","dispatch","descriptor-legality"],"depends_on":["PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES","PTO-BLOCK-MODEL-DISPATCH-DECODE"]}
pure func BundleBranchTypeLegal(branch_type: bits(3)) => boolean
begin
    return branch_type == '001' || branch_type == '101' ||
           branch_type == '110' || branch_type == '111';
end;

pure func BundleTransferOfBranchType(branch_type: bits(3)) => BundleTransfer
begin
    case branch_type of
        when '001' => return BundleTransfer_Fallthrough;
        when '101' => return BundleTransfer_Indirect;
        when '110' => return BundleTransfer_IndirectCall;
        when '111' => return BundleTransfer_Return;
        otherwise => unreachable;
    end;
end;

pure func BundleDataTypeSupported(data_type: bits(5)) => boolean
begin
    return BundleDataTypeConcrete(data_type);
end;

pure func BundleDataTypeConcrete(data_type: bits(5)) => boolean
begin
    let code = UInt(data_type);
    return code <= 21 || (24 <= code && code <= 28);
end;

pure func BundleDataTypeFieldValid(data_type: bits(5)) => boolean
begin
    return BundleDataTypeConcrete(data_type) || data_type == DTYPE_NONE;
end;

readonly func BundleDATRDataTypeApplicabilityCode() => bits(5)
begin
    if !_BundleDataAttributesPresent ||
       _BundleDataAttributes.data_type == DTYPE_NONE then
        return Zeros{5};
    end;
    return _BundleDataAttributes.data_type;
end;

pure func BundleTileDataType(data_type: bits(5)) => TileDataType
begin
    return TileDataTypeFromEncoding(data_type as TileDataTypeEncoding);
end;

pure func BundleDescriptorSelectsTMOV(
    descriptor: BundleOperationDescriptor) => boolean
begin
    if descriptor.operation_class != BundleOperation_TileMemory ||
       !descriptor.selector_valid then return FALSE; end;
    return BundleOperationDecodeCode(descriptor) == Zeros{12} + 2;
end;

readonly func BundleTMOVSelected() => boolean
begin
    return _BundleOperation.valid &&
           BundleDescriptorSelectsTMOV(_BundleOperation);
end;

readonly func ResolveBundleEffectiveDataType() => (boolean, TileDataType)
begin
    if _BundleDataAttributes.data_type_present &&
       BundleDataTypeConcrete(_BundleDataAttributes.data_type) then
        return (TRUE, BundleTileDataType(_BundleDataAttributes.data_type));
    end;
    if _BundleOperation.data_type_valid &&
       BundleDataTypeConcrete(_BundleOperation.data_type) then
        return (TRUE, BundleTileDataType(_BundleOperation.data_type));
    end;
    if BundleTMOVSelected() then
        for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
            if _BundleTileBindings[[binding]].valid then
                if _BundleTileBindings[[binding]].source0_valid &&
                   TileDescriptorConfigured(
                       _BundleTileBindings[[binding]].source0) then
                    return (TRUE, _Tiles[[
                        _BundleTileBindings[[binding]].source0]].data_type);
                elsif _BundleTileBindings[[binding]].source1_valid &&
                      TileDescriptorConfigured(
                          _BundleTileBindings[[binding]].source1) then
                    return (TRUE, _Tiles[[
                        _BundleTileBindings[[binding]].source1]].data_type);
                end;
            end;
        end;
        for binding = 0 to 3 do
            if _BundleSharedBindings[[binding]].valid &&
               !_BundleSharedBindings[[binding]].consumed &&
               !BundleSharedBindingIsReusedDestination(binding) &&
               !BundleSharedBindingIsDestination(binding) then
                let shared_tile_id = BundleSharedBindingId(binding);
                if SharedTileDescriptorLegal(shared_tile_id) then
                    return (TRUE, SharedTileRecord(shared_tile_id).tile.data_type);
                end;
            end;
        end;
    end;
    // This value is unobservable when the valid member is FALSE. FP64 is a
    // total ASL return value, never a default interpretation of DTYPE_NONE.
    return (FALSE, TileDataType_FP64);
end;

pure func BundleTileDecodeFamily(operation_class: BundleOperationClass)
        => TileDecodeFamily
begin
    case operation_class of
        when BundleOperation_TileElement => return TileDecode_TEPL;
        when BundleOperation_TileMemory => return TileDecode_TLSU;
        when BundleOperation_TileMatrix => return TileDecode_CUBE;
        otherwise => unreachable;
    end;
end;

pure func BundleSelectorCode(descriptor: BundleOperationDescriptor) => bits(12)
begin
    var code = Zeros{12};
    if descriptor.mode_valid then
        code[6:5] = descriptor.mode;
        code[4:0] = descriptor.selector[4:0];
    else
        code[9:0] = descriptor.selector;
    end;
    return code;
end;

pure func BundleOperationDecodeCode(
    descriptor: BundleOperationDescriptor) => bits(12)
begin
    return BundleSelectorCode(descriptor);
end;

pure func BundleDescriptorHasTIMG2COLFormIdentity(
    descriptor: BundleOperationDescriptor) => boolean
begin
    // BSTART.TIMG2COL is the final command form in the current frozen catalog.
    // Check its exact form as well as Function 28 so no other TLSU carrier can
    // acquire the command-only semantics.
    return descriptor.form_identity == Zeros{7} + 94;
end;

pure func BundleDescriptorSelectsTIMG2COL(
    descriptor: BundleOperationDescriptor) => boolean
begin
    return descriptor.valid &&
           BundleDescriptorHasTIMG2COLFormIdentity(descriptor) &&
           descriptor.operation_class == BundleOperation_TileMemory &&
           descriptor.selector_valid && descriptor.selector == Zeros{10} + 28 &&
           descriptor.data_type_valid && !descriptor.mode_valid &&
           !descriptor.branch_type_valid;
end;

pure func BundleDescriptorTIMG2COLDataTypeSupported(
    data_type: bits(5)) => boolean
begin
    let code = UInt(data_type);
    return code == 1 || code == 2 || code == 3 || code == 4 || code == 5 ||
           code == 6 || code == 7 || code == 8 || code == 13 ||
           code == 17 || code == 18 || code == 19 || code == 25 ||
           code == 26 || code == 27;
end;

pure func BundleOperationDescriptorLegal(
    descriptor: BundleOperationDescriptor) => boolean
begin
    if BundleDescriptorHasTIMG2COLFormIdentity(descriptor) then
        return BundleDescriptorSelectsTIMG2COL(descriptor) &&
               BundleDescriptorTIMG2COLDataTypeSupported(
                   descriptor.data_type);
    end;
    if descriptor.branch_type_valid &&
       !BundleBranchTypeLegal(descriptor.branch_type) then
        return FALSE;
    end;
    case descriptor.operation_class of
        when BundleOperation_TileElement,
             BundleOperation_TileMemory,
             BundleOperation_TileMatrix =>
            if !descriptor.selector_valid || !descriptor.data_type_valid ||
               !BundleDataTypeFieldValid(descriptor.data_type) then
                return FALSE;
            end;
            let operation = DecodeTileOperation(
                BundleTileDecodeFamily(descriptor.operation_class),
                BundleOperationDecodeCode(descriptor));
            if operation == PTO_TILE_OPERATION_COUNT then return FALSE; end;
            return BundleDataTypeConcrete(descriptor.data_type) ||
                   BundleDescriptorSelectsTMOV(descriptor);
        when BundleOperation_FixedPoint =>
            // PTO v0 has no direct FIXP selector family. The accepted spelling
            // remains decodable but cannot install an executable descriptor.
            return FALSE;
        otherwise => return TRUE;
    end;
end;

pure func BundleOperationDescriptorRejectedByAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet,
    descriptor: BundleOperationDescriptor) => boolean
begin
    case descriptor.operation_class of
        when BundleOperation_TileElement,
             BundleOperation_TileMemory,
             BundleOperation_TileMatrix =>
            if !descriptor.selector_valid then return FALSE; end;
            let decoded = DecodeTileOperation(
                BundleTileDecodeFamily(descriptor.operation_class),
                BundleOperationDecodeCode(descriptor));
            if decoded == PTO_TILE_OPERATION_COUNT then return FALSE; end;
            let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
            return TileOperationRejectedByAcceptedApplicabilityRules(
                rules, operation);
        otherwise => return FALSE;
    end;
end;

readonly func BundleAssembleOutputStructureLegal() => boolean
begin
    var destination_count: integer = 0;
    var source_count: integer = 0;
    var local_continuations: integer = 0;
    var shared_continuations: integer = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].destination_valid &&
               !_BundleTileBindings[[binding]].destination_reused_by_generation then
                destination_count = destination_count + 1;
            end;
            if _BundleTileBindings[[binding]].source0_valid then
                source_count = source_count + 1;
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                source_count = source_count + 1;
            end;
            if _BundleTileBindings[[binding]].destination_assemble.valid &&
               !_BundleTileBindings[[binding]].destination_assemble.init then
                local_continuations = local_continuations + 1;
            end;
        end;
    end;
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].destination_assemble.valid &&
           !_BundleSharedBindings[[binding]].destination_assemble.init then
            shared_continuations = shared_continuations + 1;
        end;
    end;
    let local_parent_refs = BundleLocalTileParentRefCount();
    let shared_destinations = BundleSharedPhysicalDestinationCount();
    let shared_reused_destinations = BundleSharedReusedDestinationCount();
    if local_parent_refs > 1 then return FALSE; end;
    if local_continuations != 0 && local_parent_refs != 1 then
        return FALSE;
    end;
    if shared_continuations != 0 then
        if shared_reused_destinations != 1 ||
           !BundleSharedReusedDestinationIsFinal() ||
           BundleSharedBindingCount() > 3 || local_parent_refs != 0 then
            return FALSE;
        end;
    end;
    if local_parent_refs == 1 then
        if !BundleLocalTileParentRefIsFinal() || destination_count != 0 ||
           source_count > 7 || shared_destinations != 0 then
            return FALSE;
        end;
    end;
    if shared_reused_destinations != 0 && shared_continuations == 0 then
        return FALSE;
    end;
    if shared_reused_destinations > 1 then return FALSE; end;
    if shared_reused_destinations == 1 then
        if destination_count != 0 || shared_destinations != 0 ||
           local_parent_refs != 0 then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func BundleOperationBindingsComplete(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded_operation = TileOperationOfIndex(operation);
    if decoded_operation == TileOperation_TCMP ||
       decoded_operation == TileOperation_TCMPS ||
       decoded_operation == TileOperation_TSEL ||
       decoded_operation == TileOperation_TSELS then
        // Comparison/select carriers own their complete mutually-exclusive
        // binding schemas; the generic tile operand arity is not applicable.
        if _BundleExecutionMask.valid &&
           _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile then
            return BundleLocalTileSourceCount() ==
                _BundleExecutionMask.predicate_source_ordinal + 1;
        end;
        return TRUE;
    end;
    if decoded_operation == TileOperation_TGPR2T then
        if _BundleExecutionMask.valid &&
           _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile then
            return BundleTileBindingCount() == 1 &&
                   _BundleTileBindings[[0]].valid &&
                   _BundleTileBindings[[0]].destination_valid &&
                   _BundleTileBindings[[0]].source0_valid &&
                   !_BundleTileBindings[[0]].source1_valid &&
                   _BundleTileBindings[[0]].last &&
                   BundleLocalTileSourceCount() == 1;
        end;
        if BundleTileBindingCount() != 1 ||
           !_BundleTileBindings[[0]].valid ||
           !_BundleTileBindings[[0]].destination_valid ||
           _BundleTileBindings[[0]].source0_valid ||
           _BundleTileBindings[[0]].source1_valid ||
           !_BundleTileBindings[[0]].last then
            return FALSE;
        end;
        return TRUE;
    end;
    var destination_count: integer = 0;
    var source_count: integer = 0;
    var binding_count: integer = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            binding_count = binding_count + 1;
            if _BundleTileBindings[[binding]].destination_valid &&
               !_BundleTileBindings[[binding]].destination_reused_by_generation then
                destination_count = destination_count + 1;
            end;
            if _BundleTileBindings[[binding]].source0_valid then
                source_count = source_count + 1;
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                source_count = source_count + 1;
            end;
        end;
    end;
    if !BundleAssembleOutputStructureLegal() then return FALSE; end;
    let local_parent_refs = BundleLocalTileParentRefCount();
    let matrix = _BundleOperation.valid &&
        _BundleOperation.operation_class == BundleOperation_TileMatrix;
    let expected_destinations =
        (if TileOperandPresent(operation, TileOperand_destination0)
         then 1 else 0) +
        (if matrix && _BundleFixedPointAttributes.row_max_en
         then 1 else 0) +
        (if matrix && _BundleFixedPointAttributes.group_max_en
         then 1 else 0);
    var expected_sources =
        (if TileOperandPresent(operation, TileOperand_source0)
         then 1 else 0) +
        (if TileOperandPresent(operation, TileOperand_source1)
         then 1 else 0) +
        (if TileOperandPresent(operation, TileOperand_source2)
         then 1 else 0) +
        (if TileOperandPresent(operation, TileOperand_source3)
         then 1 else 0) +
        (if TileOperandPresent(operation, TileOperand_source4)
         then 1 else 0) +
        (if matrix && _BundleFixedPointAttributes.c_scale_en
         then 1 else 0) +
        (if matrix && _BundleFixedPointAttributes.row_max_en &&
            _BundleFixedPointAttributes.row_max_init
         then 1 else 0) +
        (if matrix && BundleFPATRModeUsesVectorParameter(
               _BundleFixedPointAttributes.pre_quant_mode)
         then 1 else 0) +
        (if matrix && BundleFPATRReluModeUsesVectorParameter(
               _BundleFixedPointAttributes.relu_mode)
         then 1 else 0);
    if _BundleExecutionMask.valid &&
       _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile then
        expected_sources = (expected_sources + 1) as integer {0..9};
    end;
    // Matrix post-processing is a complete-bundle schema contribution.  The
    // static catalog carries mathematical operands; B.FPATR contributes
    // optional RowMax/parameter streams and compact auxiliary destinations.
    if matrix then
        if !_BundleFixedPointAttributes.valid then return FALSE; end;
    elsif _BundleFixedPointAttributes.valid then
        return FALSE;
    end;
    if matrix && destination_count > 1 then
        // D, RowMaxOut and GroupMaxOut are one atomic output group.  Their
        // architectural Tile IDs must be distinct; source/destination alias
        // checks remain operation-specific (RowMaxIn may equal RowMaxOut).
        for first = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
            if _BundleTileBindings[[first]].valid &&
               _BundleTileBindings[[first]].destination_valid then
                for second = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
                    if first != second &&
                       _BundleTileBindings[[second]].valid &&
                       _BundleTileBindings[[second]].destination_valid &&
                       _BundleTileBindings[[first]].destination ==
                       _BundleTileBindings[[second]].destination then
                        return FALSE;
                    end;
                end;
            end;
        end;
    end;
    // The complete-bundle B.FPATR carrier has nine compact Local source
    // ordinals and three compact destination ordinals. Reject surplus
    // streams before descriptor allocation or operand consumption.
    if (source_count + local_parent_refs > 8) ||
       (matrix && (source_count > 9 || destination_count > 3)) then
        return FALSE;
    end;
    let effective_destination_count = destination_count + local_parent_refs +
        BundleSharedPhysicalDestinationCount() +
        BundleSharedReusedDestinationCount();
    if effective_destination_count != expected_destinations ||
       source_count != expected_sources then return FALSE; end;
    if binding_count > 0 && !BundleTileBindingStreamTerminated() then
        return FALSE;
    end;
    if !BundleOperationScalarBindingSchemaLegal(operation) then return FALSE; end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
