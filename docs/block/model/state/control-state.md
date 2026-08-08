<!-- GENERATED FROM: asl/block/model/state/control-state.asl -->
# Control State

**Normative ASL source:** `asl/block/model/state/control-state.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-STATE-CONTROL-STATE}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/state/control-state.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-CONTROL-STATE","surface":"block","classification":["model","state","control-state"],"depends_on":["PTO-BLOCK-MODEL-STATE-TYPES"]}
// PTO-REQ-BUNDLE-STATE-001: architecture-visible bundle-control state.

var _BundleKind : BundleKind;
var _BundleTransfer : BundleTransfer;
var _BundleCondition : boolean;
var _BundleTarget : Word;
var _BundleFallthrough : Word;
var _BundleReturnTarget : Word;
var _BundleBodyAddress : Word;
var _BundleArgument : Word;
var _BundleArgumentKind : bits(3);
var _BundleOperation : BundleOperationDescriptor;
var _BundleDimensions : BundleDimensionSnapshot;
var _BundleScalarBindings : BundleScalarBindingSnapshot;
var _BundleTileBindings : BundleTileBindingSnapshot;
var _BundleSharedBindings : BundleSharedBindingSnapshot;
var _BundleControlAttributes : BundleControlAttributes;
var _BundleDataAttributes : BundleDataAttributes;
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

pure func BundleKindUsesExecutionMask(kind: BundleKind) => boolean
begin
    return kind == BundleKind_MachineParallel ||
           kind == BundleKind_MachineSequential;
end;

readonly func ExecutionMaskIsActive() => boolean
begin
    return _BundleBodyActive && BundleKindUsesExecutionMask(_BundleKind);
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

readonly func CurrentBundlePadValue() => TilePadValue
begin
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
           code == 6 || code == 8 || code == 9 || code == 17 ||
           code == 18 || code == 20 || code == 27 || code == 28 ||
           code == 30;
end;

readonly func TileDataLayoutCodeSupported(data_layout: bits(5)) => boolean
begin
    if !TileDataLayoutCodeAccepted(data_layout) then return FALSE; end;
    return _TileDataLayoutCapabilities[UInt(data_layout)] == '1';
end;

readonly func CurrentBundleTileLayout() => TileLayout
begin
    if _BundleDataAttributes.data_layout == Zeros{5} then
        return TileLayout_RowMajor;
    else
        // PTO's generic model cannot interpret advertised target layouts.
        // The capability makes their descriptors legal, not generically
        // indexable.
        return TileLayout_ImplementationDefined;
    end;
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
    conversion_mode: bits(3), rounding_mode: bits(3), saturating: boolean,
    canonicalize: boolean)
begin
    if !TileDataTypeEncodingValid(ZeroExtend{PTO_XLEN}(data_type)) ||
       !TileDataLayoutCodeSupported(data_layout) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    _BundleDataAttributes.data_type = data_type;
    _BundleDataAttributes.data_layout = data_layout;
    _BundleDataAttributes.pad_value = pad_value;
    _BundleDataAttributes.conversion_mode = conversion_mode;
    _BundleDataAttributes.rounding_mode = rounding_mode;
    _BundleDataAttributes.saturating = saturating;
    _BundleDataAttributes.canonicalize = canonicalize;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
