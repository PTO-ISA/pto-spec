<!-- GENERATED FROM: asl/block/model/state/control-state.asl -->
# Control State

**Normative ASL source:** `asl/block/model/state/control-state.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-STATE-CONTROL-STATE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-state-control-state-purpose role=purpose-scope -->
## 用途与范围

本单元声明 `PTO-STATE-BLOCK-CONTROL`，即架构可见的指令束控制状态的封闭集合。其契约 `PTO-REQ-BUNDLE-STATE-001` 规定，指令束控制状态恰好就是这个集合。

它还定义了当前指令束的读取辅助函数，以及 `B.DATR` 数据属性写入者，包括布局码表。

<!-- PTO-READER-BLOCK: block-model-state-control-state-concepts role=concepts-state -->
## 概念与可见状态

这些成员分为以下几组：

- 延续：`_BARG`、`_BundleSequentialPC`、`_FrameStackReturnTarget`，以及标记 `_BundleCommitTargetSet`、`_BundleConditionSet` 和 `_SystemBlockTerminalPending`。
- 头部配置：`_BundleOperation`、`_BundleDimensions` 及其存在位、`_BundleControlAttributes`、`_BundleDataAttributes`、`_BundleHint`、`_BundleFixedPointAttributes`、`_BundleExecutionMask` 和 `_BundleArgument`。
- 绑定：标量、Tile 和 Shared 绑定数组、`_BundleRangeGroup` 以及 `_BundleZeroParticipationSeen`。
- 跨指令束记录：`_LocalGenerations`、`_SharedGenerations` 以及执行域令牌。
- 可重启模板：`_MemoryCopyTemplate` 和 `_FrameTemplate`。
- 最近命令记录，例如 `_LastQueueLeft` 和 `_LastMemoryCommandAddress`。

`_BundleActive` 和 `_BundleBodyActive` 在执行上下文单元中声明，而不在这里声明。

<!-- PTO-READER-BLOCK: block-model-state-control-state-rules role=rules-interactions -->
## 规则与交互

`CurrentBundleMemoryOrder` 从 `B.CATR` 推导内存序：acquire 加 release 得到 `AcquireRelease`，只有其中之一得到 `Acquire` 或 `Release`，两者都没有则得到 `Relaxed`。

当 `B.DATR` 缺失时，`CurrentBundlePadValue` 返回 `Null`。当它存在时，码 `00` 为 `Zero`，`01` 为 `Max`，`10` 为 `Min`，`11` 为 `Null`。

对于无效的数据类型字段或不在接受集合内的布局码，`SetBundleDataAttributeState` 引发 `Fault_TileLegality`，并且不写入任何内容。被接受的布局码是 0、1、3、4、6、8 到 11、17、18、20，以及 21 到 31。每个被接受的码都受支持；配置档不能撤回其中任何一个。

设计要点：`_BundleCommitTargetSet` 是一个独立的标记，而不是对 `BPCN` 的测试。ASL 注释解释说，`BSTART` 在任何设置者运行之前就已经初始化了 `BPCN`，因此仅凭该值无法表明压缩的 `C.SETC.TGT` 设置者是否已经写过它。

设计要点：`_SystemBlockTerminalPending` 在 SYS 块最后一条 `ACRC` 引发的陷阱之后仍然保留。注释说明了其目的：恢复时只能接受 `BSTOP` 或新的 `BSTART`，因此块的终止步骤之后不会再跟随其他块体指令。

设计要点：Local 代次位于每指令束头部之外，并且在显式 `LAST` 之前不受 `ClearBundleHeaderState` 影响而保留。因此一个 `B.ASSEMBLE` 目标可以由若干个连续的指令束填充。

<!-- PTO-READER-BLOCK: block-model-state-control-state-boundaries role=boundaries -->
## 架构边界

挂起的 Shared 代次是 Core 私有的。注释说明，在完整的集体发布之前，它们通过架构 `S` 寄存器堆始终不可见。

执行域令牌属于执行上下文，从不是编码的操作数。在参考模型中，下一个令牌计数器是无界的，实现可以使用任何不产生别名的内部表示。

<!-- PTO-READER-BLOCK: block-model-state-control-state-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

一个设置了 `B.CATR` acquire 和 release、且没有 `B.DATR` 的指令束，其内存序为 `AcquireRelease`，填充值为 `Null`。加入填充码为 `00` 的 `B.DATR` 后，填充值变为 `Zero`。

<!-- PTO-READER-BLOCK: block-model-state-control-state-related role=related-owners-navigation -->
## 相关所有者

- [状态类型](types.md)定义记录类型。
- [描述符状态](descriptor-state.md)和[复位](../lifecycle/reset.md)清除这些成员。
- [执行上下文](../../../arch/programming-model/execution-context.md)声明活动标志。
- [B.CATR](../../attributes/B.CATR.md) 和 [B.DATR](../../attributes/B.DATR.md) 写入属性记录。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/state/control-state.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-CONTROL-STATE","surface":"block","classification":["model","state","control-state"],"depends_on":["PTO-BLOCK-MODEL-STATE-TYPES"]}
// PTO-STATE: {"id":"PTO-STATE-BLOCK-CONTROL","classification":["block","control"],"scope":"core","owner":"PTO-BLOCK-MODEL-STATE-CONTROL-STATE","members":["_BARG","_BundleCommitTargetSet","_BundleConditionSet","_SystemBlockTerminalPending","_BundleSequentialPC","_FrameStackReturnTarget","_BundleArgument","_BundleArgumentKind","_BundleOperation","_BundleDimensions","_BundleDimensionPresent","_BundleScalarBindings","_BundleTileBindings","_BundleSharedBindings","_BundleRangeGroup","_BundleZeroParticipationSeen","_BundleControlAttributes","_BundleDataAttributes","_BundleDataAttributesPresent","_BundleExecutionMask","_BundleHint","_BundleFixedPointAttributes","_MemoryCopyTemplate","_FrameTemplate","_LocalGenerations","_SharedGenerations","_BundleExecutionDomainToken","_NextBundleExecutionDomainToken","_TileDataLayoutCapabilities","_FrameDepth","_LastFrameBegin","_LastFrameEnd","_LastFrameSize","_LastQueueLeft","_LastQueueRight","_LastQueueFlags","_LastMemoryCommandAddress","_LastMemoryCommandSize","_LastCrossBlockACR","_LastCrossBlockID","_LastBundleHintPayload"],"depends_on":[]}

// NDF-BEGIN: PTO-REQ-BUNDLE-STATE-001
// ndf: kind=contract level=L1 layer=block status=accepted
// Architecture-visible bundle-control state MUST be the state defined by
// [[PTO-STATE-BLOCK-CONTROL]].
// NDF-END: PTO-REQ-BUNDLE-STATE-001

var _BARG : BundleArgumentRegister;
// C.SETC.TGT owns one successful value snapshot per active block. This marker
// is separate from BARG.BPCN because BSTART initializes BPCN before any setter.
var _BundleCommitTargetSet : boolean;
// Exactly one SETC condition setter may publish BARG.TAKEN in one conditional
// block. The marker is trap-preserved and cleared with block state.
var _BundleConditionSet : boolean;
// ACRC is the final scalar operation of a SYS block.  This marker survives
// its service-request trap so recovery can accept only BSTOP or a new BSTART.
var _SystemBlockTerminalPending : boolean;
// These are not alternate continuation selectors. _BundleSequentialPC is the
// instruction following the current BSTART and is supplied to the commit
// boundary; _FrameStackReturnTarget belongs to FRET.STK frame state.
var _BundleSequentialPC : Word;
var _FrameStackReturnTarget : Word;
var _BundleArgument : Word;
var _BundleArgumentKind : bits(3);
var _BundleOperation : BundleOperationDescriptor;
var _BundleDimensions : BundleDimensionSnapshot;
var _BundleDimensionPresent : BundleDimensionPresenceSnapshot;
var _BundleScalarBindings : BundleScalarBindingSnapshot;
var _BundleTileBindings : BundleTileBindingSnapshot;
var _BundleSharedBindings : BundleSharedBindingSnapshot;
var _BundleRangeGroup : BundleRangeGroupState;
var _BundleZeroParticipationSeen : boolean;
var _BundleControlAttributes : BundleControlAttributes;
var _BundleDataAttributes : BundleDataAttributes;
var _BundleDataAttributesPresent : boolean;
var _BundleExecutionMask : BundleExecutionMaskBinding;
var _BundleHint : BundleHintAttributes;
var _BundleFixedPointAttributes : BundleFixedPointAttributes;
var _MemoryCopyTemplate : MemoryCopyTemplateState;
var _FrameTemplate : FrameTemplateState;
// Local B.ASSEMBLE generations intentionally live outside the per-block
// header and therefore survive ClearBundleHeaderState until explicit LAST.
var _LocalGenerations : LocalGenerationSnapshot;
// Pending Shared generations are Core-private and remain invisible through
// the architectural S register file until complete collective publication.
var _SharedGenerations : SharedGenerationSnapshot;
// Opaque portable execution-domain identity for dynamic writer speculation.
// It is execution context, never an encoded operand.
var _BundleExecutionDomainToken : integer;
// Mathematical dynamic-domain allocator for the reference model. Its
// unbounded identity is portable; implementations may use any non-aliasing
// internal representation.
var _NextBundleExecutionDomainToken : integer;
// NORM is mandatory. Other accepted layout bits require an advertised
// profile/platform capability.
var _TileDataLayoutCapabilities : bits(32);
var _FrameDepth : integer {0..PTO_MODEL_MEMORY_EVENTS};
var _LastFrameBegin : Reg5Selector;
var _LastFrameEnd : Reg5Selector;
var _LastFrameSize : Word;
var _LastQueueLeft : Word;
var _LastQueueRight : Word;
var _LastQueueFlags : bits(4);
var _LastMemoryCommandAddress : Word;
var _LastMemoryCommandSize : Word;
var _LastCrossBlockACR : bits(10);
var _LastCrossBlockID : bits(7);
var _LastBundleHintPayload : Word;

readonly func BundleIsActive() => boolean
begin
    return _BundleActive;
end;

readonly func BundleBodyIsActive() => boolean
begin
    return _BundleBodyActive;
end;

readonly func BundleTileOperationSelected() => boolean
begin
    return _BundleOperation.valid &&
           (_BundleOperation.operation_class == BundleOperation_TileElement ||
            _BundleOperation.operation_class == BundleOperation_TileMemory ||
            _BundleOperation.operation_class == BundleOperation_TileMatrix);
end;

readonly func CurrentBundleTileOperationDataTypeCode() => bits(5)
begin
    assert BundleTileOperationSelected() &&
           _BundleOperation.data_type_valid;
    return _BundleOperation.data_type;
end;

readonly func CurrentBundleMemoryOrder() => MemoryOrder
begin
    if _BundleControlAttributes.acquire &&
       _BundleControlAttributes.release then
        return MemoryOrder_AcquireRelease;
    elsif _BundleControlAttributes.acquire then
        return MemoryOrder_Acquire;
    elsif _BundleControlAttributes.release then
        return MemoryOrder_Release;
    else
        return MemoryOrder_Relaxed;
    end;
end;

readonly func CurrentBundleAtomic() => boolean
begin
    return _BundleControlAttributes.atomic;
end;

readonly func CurrentBundleDimensionReduction() => boolean
begin
    return _BundleControlAttributes.dimension_reduction;
end;

readonly func CurrentBundlePadValue() => TilePadValue
begin
    if !_BundleDataAttributesPresent then return TilePad_Null; end;
    case _BundleDataAttributes.pad_value[1:0] of
        when '00' => return TilePad_Zero;
        when '01' => return TilePad_Max;
        when '10' => return TilePad_Min;
        when '11' => return TilePad_Null;
    end;
end;

pure func TileDataLayoutCodeAccepted(data_layout: bits(5)) => boolean
begin
    let code = UInt(data_layout);
    return code == 0 || code == 1 || code == 3 || code == 4 ||
           code == 10 || code == 11 ||
           code == 6 || code == 8 || code == 9 || code == 17 ||
           code == 18 || code == 20 || (21 <= code && code <= 29) ||
           code == 30 || code == 31;
end;

pure func TileDataLayoutOfCode(data_layout: bits(5)) => TileDataLayout
begin
    assert TileDataLayoutCodeAccepted(data_layout);
    let code = UInt(data_layout);
    if code == 10 then return TileDataLayout_OHWI2NK;
    elsif code == 11 then return TileDataLayout_OIHW2NK;
    elsif code == 1 then return TileDataLayout_ND2DN;
    elsif code == 3 then return TileDataLayout_ND2ZN;
    elsif code == 4 then return TileDataLayout_ND2NZ;
    elsif code == 6 then return TileDataLayout_DN2ND;
    elsif code == 8 then return TileDataLayout_DN2ZN;
    elsif code == 9 then return TileDataLayout_DN2NZ;
    elsif code == 17 then return TileDataLayout_ZN2ND;
    elsif code == 18 then return TileDataLayout_ZN2DN;
    elsif code == 20 then return TileDataLayout_ZN2NZ;
    elsif code == 21 then return TileDataLayout_ND2M32;
    elsif code == 22 then return TileDataLayout_ND2M16;
    elsif code == 23 then return TileDataLayout_ND2N8;
    elsif code == 24 then return TileDataLayout_M322ND;
    elsif code == 25 then return TileDataLayout_M162ND;
    elsif code == 26 then return TileDataLayout_N82ND;
    elsif code == 27 then return TileDataLayout_NZ2ND;
    elsif code == 28 then return TileDataLayout_NZ2DN;
    elsif code == 29 then return TileDataLayout_CUBE_M32;
    elsif code == 30 then return TileDataLayout_NZ2ZN;
    elsif code == 31 then return TileDataLayout_CUBE_M16;
    else return TileDataLayout_NORM;
    end;
end;

pure func TileDataLayoutCodeOf(data_layout: TileDataLayout) => bits(5)
begin
    case data_layout of
        when TileDataLayout_NORM => return Zeros{5};
        when TileDataLayout_OHWI2NK => return Zeros{5} + 10;
        when TileDataLayout_OIHW2NK => return Zeros{5} + 11;
        when TileDataLayout_ND2DN => return Zeros{5} + 1;
        when TileDataLayout_ND2ZN => return Zeros{5} + 3;
        when TileDataLayout_ND2NZ => return Zeros{5} + 4;
        when TileDataLayout_DN2ND => return Zeros{5} + 6;
        when TileDataLayout_DN2ZN => return Zeros{5} + 8;
        when TileDataLayout_DN2NZ => return Zeros{5} + 9;
        when TileDataLayout_ZN2ND => return Zeros{5} + 17;
        when TileDataLayout_ZN2DN => return Zeros{5} + 18;
        when TileDataLayout_ZN2NZ => return Zeros{5} + 20;
        when TileDataLayout_ND2M32 => return Zeros{5} + 21;
        when TileDataLayout_ND2M16 => return Zeros{5} + 22;
        when TileDataLayout_ND2N8 => return Zeros{5} + 23;
        when TileDataLayout_M322ND => return Zeros{5} + 24;
        when TileDataLayout_M162ND => return Zeros{5} + 25;
        when TileDataLayout_N82ND => return Zeros{5} + 26;
        when TileDataLayout_NZ2ND => return Zeros{5} + 27;
        when TileDataLayout_NZ2DN => return Zeros{5} + 28;
        when TileDataLayout_CUBE_M32 => return Zeros{5} + 29;
        when TileDataLayout_NZ2ZN => return Zeros{5} + 30;
        when TileDataLayout_CUBE_M16 => return Zeros{5} + 31;
    end;
end;

pure func TileDataLayoutIsCubeConversion(data_layout: bits(5)) => boolean
begin
    let code = UInt(data_layout);
    return 21 <= code && code <= 26;
end;

pure func TileDataLayoutConversionIsLoad(data_layout: bits(5)) => boolean
begin
    let code = UInt(data_layout);
    return 21 <= code && code <= 23;
end;

pure func TileDataLayoutConversionIsStore(data_layout: bits(5)) => boolean
begin
    let code = UInt(data_layout);
    return 24 <= code && code <= 26;
end;

pure func TileDataLayoutCubeLayout(data_layout: bits(5)) => TileLayout
begin
    assert TileDataLayoutIsCubeConversion(data_layout);
    let code = UInt(data_layout);
    if code == 21 || code == 24 then
        return TileLayout_CUBE_M32;
    elsif code == 22 || code == 25 then
        return TileLayout_CUBE_M16;
    else
        return TileLayout_CUBE_N8;
    end;
end;

readonly func CurrentBundleDataLayout() => TileDataLayout
begin
    return TileDataLayoutOfCode(_BundleDataAttributes.data_layout);
end;

readonly func TileDataLayoutCodeSupported(data_layout: bits(5)) => boolean
begin
    // Every assigned PTO Layout code is architectural.  Profiles cannot
    // downgrade an assigned transform into an opaque implementation layout.
    return TileDataLayoutCodeAccepted(data_layout);
end;

pure func TileDataLayoutSourceLayout(data_layout: TileDataLayout) => TileLayout
begin
    case data_layout of
        when TileDataLayout_NORM => return TileLayout_RowMajor;
        when TileDataLayout_OHWI2NK,
             TileDataLayout_OIHW2NK => return TileLayout_ImplementationDefined;
        when TileDataLayout_ND2DN,
             TileDataLayout_ND2ZN,
             TileDataLayout_ND2NZ => return TileLayout_RowMajor;
        when TileDataLayout_DN2ND,
             TileDataLayout_DN2ZN,
             TileDataLayout_DN2NZ => return TileLayout_ColumnMajor;
        when TileDataLayout_ZN2ND,
             TileDataLayout_ZN2DN,
             TileDataLayout_ZN2NZ => return TileLayout_ZN;
        when TileDataLayout_NZ2ND,
             TileDataLayout_NZ2DN,
             TileDataLayout_NZ2ZN => return TileLayout_NZ;
        when TileDataLayout_ND2M32,
             TileDataLayout_ND2M16,
             TileDataLayout_ND2N8,
             TileDataLayout_M322ND,
             TileDataLayout_M162ND,
             TileDataLayout_N82ND => unreachable;
        when TileDataLayout_CUBE_M32 => return TileLayout_CUBE_M32;
        when TileDataLayout_CUBE_M16 => return TileLayout_CUBE_M16;
    end;
end;

pure func TileDataLayoutDestinationLayout(
    data_layout: TileDataLayout) => TileLayout
begin
    case data_layout of
        when TileDataLayout_NORM => return TileLayout_RowMajor;
        when TileDataLayout_OHWI2NK,
             TileDataLayout_OIHW2NK => return TileLayout_ImplementationDefined;
        when TileDataLayout_DN2ND,
             TileDataLayout_ZN2ND,
             TileDataLayout_NZ2ND => return TileLayout_RowMajor;
        when TileDataLayout_ND2DN,
             TileDataLayout_ZN2DN,
             TileDataLayout_NZ2DN => return TileLayout_ColumnMajor;
        when TileDataLayout_ND2ZN,
             TileDataLayout_DN2ZN,
             TileDataLayout_NZ2ZN => return TileLayout_ZN;
        when TileDataLayout_ND2NZ,
             TileDataLayout_DN2NZ,
             TileDataLayout_ZN2NZ => return TileLayout_NZ;
        when TileDataLayout_ND2M32,
             TileDataLayout_ND2M16,
             TileDataLayout_ND2N8,
             TileDataLayout_M322ND,
             TileDataLayout_M162ND,
             TileDataLayout_N82ND => unreachable;
        when TileDataLayout_CUBE_M32 => return TileLayout_CUBE_M32;
        when TileDataLayout_CUBE_M16 => return TileLayout_CUBE_M16;
    end;
end;

readonly func CurrentBundleTileSourceLayout() => TileLayout
begin
    return TileDataLayoutSourceLayout(CurrentBundleDataLayout());
end;

readonly func CurrentBundleTileLayout() => TileLayout
begin
    return TileDataLayoutDestinationLayout(CurrentBundleDataLayout());
end;

func AdvertiseTileDataLayout(data_layout: bits(5))
begin
    assert TileDataLayoutCodeAccepted(data_layout);
    _TileDataLayoutCapabilities[UInt(data_layout)] = '1';
end;

readonly func CurrentBundleDataTypeCode() => bits(5)
begin
    return _BundleDataAttributes.data_type;
end;

readonly func CurrentBundleCanonicalize() => boolean
begin
    return _BundleDataAttributes.canonicalize;
end;

func SetBundleDataAttributeState(
    data_type: bits(5), data_layout: bits(5), pad_value: bits(2),
    comparison_mode: bits(3), rounding_mode: bits(3), saturating: boolean,
    canonicalize: boolean)
begin
    if !BundleDataTypeFieldValid(data_type) ||
       !TileDataLayoutCodeSupported(data_layout) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    _BundleDataAttributes.data_type_present = TRUE;
    _BundleDataAttributes.data_type = data_type;
    _BundleDataAttributes.data_layout = data_layout;
    _BundleDataAttributes.pad_value = pad_value;
    _BundleDataAttributes.comparison_mode = comparison_mode;
    _BundleDataAttributes.rounding_mode = rounding_mode;
    _BundleDataAttributes.saturating = saturating;
    _BundleDataAttributes.canonicalize = canonicalize;
    _BundleDataAttributes.execution_mask_invert = FALSE;
    _BundleDataAttributes.execution_mask_zero = FALSE;
end;
```
<!-- GENERATED-ASL-END: unit -->
