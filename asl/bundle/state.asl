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

func ResetBundleControlState()
begin
    _BundleActive = FALSE;
    _BundleBodyActive = FALSE;
    _BundleKind = BundleKind_Standard;
    _BundleTransfer = BundleTransfer_Fallthrough;
    _BundleCondition = TRUE;
    _BundleTarget = Zeros{PTO_XLEN};
    _BundleFallthrough = Zeros{PTO_XLEN};
    _BundleReturnTarget = Zeros{PTO_XLEN};
    _BundleBodyAddress = Zeros{PTO_XLEN};
    _BundleArgument = Zeros{PTO_XLEN};
    _BundleArgumentKind = Zeros{3};
    _BundleOperation.valid = FALSE;
    _BundleOperation.form_identity = Zeros{7};
    _BundleOperation.operation_class = BundleOperation_Control;
    _BundleOperation.selector_valid = FALSE;
    _BundleOperation.selector = Zeros{10};
    _BundleOperation.data_type_valid = FALSE;
    _BundleOperation.data_type = Zeros{5};
    _BundleOperation.mode_valid = FALSE;
    _BundleOperation.mode = Zeros{2};
    _BundleOperation.branch_type_valid = FALSE;
    _BundleOperation.branch_type = Zeros{3};
    for index = 0 to PTO_BUNDLE_DIMENSION_COUNT - 1 do
        _BundleDimensions[[index]] = Zeros{PTO_XLEN};
    end;
    for index = 0 to PTO_BUNDLE_SCALAR_BINDING_COUNT - 1 do
        _BundleScalarBindings[[index]].valid = FALSE;
        _BundleScalarBindings[[index]].destination = 0;
        _BundleScalarBindings[[index]].source0 = 0;
        _BundleScalarBindings[[index]].source1 = 0;
        _BundleScalarBindings[[index]].source2 = 0;
        _BundleScalarBindings[[index]].source_count = 0;
    end;
    for index = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        _BundleTileBindings[[index]].valid = FALSE;
        _BundleTileBindings[[index]].destination_valid = FALSE;
        _BundleTileBindings[[index]].destination = 0;
        _BundleTileBindings[[index]].destination_hand = Zeros{2};
        _BundleTileBindings[[index]].destination_allocated_by_bundle = FALSE;
        _BundleTileBindings[[index]].destination_size = 0;
        _BundleTileBindings[[index]].pe_mask = Zeros{4};
        _BundleTileBindings[[index]].source0_valid = FALSE;
        _BundleTileBindings[[index]].source1_valid = FALSE;
        _BundleTileBindings[[index]].source0 = 0;
        _BundleTileBindings[[index]].source1 = 0;
        _BundleTileBindings[[index]].last = FALSE;
    end;
    for index = 0 to 3 do
        _BundleSharedBindings[[index]].valid = FALSE;
        _BundleSharedBindings[[index]].shared_id = Zeros{8};
        _BundleSharedBindings[[index]].size_code = 0;
        _BundleSharedBindings[[index]].pe_mask = Zeros{4};
        _BundleSharedBindings[[index]].consumed = FALSE;
    end;
    _BundleControlAttributes.trap_enabled = FALSE;
    _BundleControlAttributes.atomic = FALSE;
    _BundleControlAttributes.acquire = FALSE;
    _BundleControlAttributes.release = FALSE;
    _BundleControlAttributes.far = FALSE;
    _BundleControlAttributes.direct_register = FALSE;
    _BundleDataAttributes.data_type = Zeros{5};
    _BundleDataAttributes.data_layout = Zeros{5};
    _BundleDataAttributes.pad_value = Zeros{2};
    _BundleDataAttributes.conversion_mode = Zeros{3};
    _BundleDataAttributes.rounding_mode = Zeros{3};
    _BundleDataAttributes.saturating = FALSE;
    _BundleDataAttributes.canonicalize = FALSE;
    _TileDataLayoutCapabilities = Zeros{32};
    _TileDataLayoutCapabilities[0] = '1';
    for ring = 0 to PTO_ACR_COUNT - 1 do
        _TrapContexts[[ring]].valid = FALSE;
        _TrapContexts[[ring]].source_acr = 0;
        _TrapContexts[[ring]].tpc = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].bpc = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].core_state = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].bundle_argument = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].commit_argument = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].bundle_active = FALSE;
        _TrapContexts[[ring]].bundle_body_active = FALSE;
        _TrapContexts[[ring]].bundle_kind = BundleKind_Standard;
        _TrapContexts[[ring]].bundle_transfer = BundleTransfer_Fallthrough;
        _TrapContexts[[ring]].bundle_condition = TRUE;
        _TrapContexts[[ring]].bundle_target = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].bundle_fallthrough = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].bundle_return_target = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].return_address = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].bundle_argument_kind = Zeros{3};
        _TrapContexts[[ring]].bundle_body_address = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].bundle_operation = _BundleOperation;
        _TrapContexts[[ring]].bundle_dimensions = _BundleDimensions;
        _TrapContexts[[ring]].bundle_scalar_bindings = _BundleScalarBindings;
        _TrapContexts[[ring]].bundle_tile_bindings = _BundleTileBindings;
        _TrapContexts[[ring]].bundle_shared_bindings = _BundleSharedBindings;
        _TrapContexts[[ring]].bundle_control_attributes =
            _BundleControlAttributes;
        _TrapContexts[[ring]].bundle_data_attributes = _BundleDataAttributes;
        _TrapContexts[[ring]].t_queue = _TQueue;
        _TrapContexts[[ring]].u_queue = _UQueue;
        _TrapContexts[[ring]].execution_mask = _ExecutionMask;
        _TrapContexts[[ring]].predicates = _PredicateRegisters;
    end;
    _FrameDepth = 0;
    _LastFrameBegin = 0;
    _LastFrameEnd = 0;
    _LastFrameSize = Zeros{PTO_XLEN};
    _LastQueueLeft = Zeros{PTO_XLEN};
    _LastQueueRight = Zeros{PTO_XLEN};
    _LastQueueFlags = Zeros{4};
    _LastMemoryCommandAddress = Zeros{PTO_XLEN};
    _LastMemoryCommandSize = Zeros{PTO_XLEN};
    _LastCrossBlockACR = Zeros{10};
    _LastCrossBlockID = Zeros{7};
    _LastBundleHintPayload = Zeros{PTO_XLEN};
end;

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

func SetBundleDataAttributeState0580(
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

func InstallBundleOperationDescriptor(descriptor: BundleOperationDescriptor)
begin
    _BundleOperation = descriptor;
end;

func ClearBundleHeaderState()
begin
    _BundleArgument = Zeros{PTO_XLEN};
    _BundleArgumentKind = Zeros{3};
    _BundleOperation.valid = FALSE;
    _BundleOperation.form_identity = Zeros{7};
    _BundleOperation.operation_class = BundleOperation_Control;
    _BundleOperation.selector_valid = FALSE;
    _BundleOperation.selector = Zeros{10};
    _BundleOperation.data_type_valid = FALSE;
    _BundleOperation.data_type = Zeros{5};
    _BundleOperation.mode_valid = FALSE;
    _BundleOperation.mode = Zeros{2};
    _BundleOperation.branch_type_valid = FALSE;
    _BundleOperation.branch_type = Zeros{3};
    for index = 0 to PTO_BUNDLE_DIMENSION_COUNT - 1 do
        _BundleDimensions[[index]] = Zeros{PTO_XLEN};
    end;
    for index = 0 to PTO_BUNDLE_SCALAR_BINDING_COUNT - 1 do
        _BundleScalarBindings[[index]].valid = FALSE;
        _BundleScalarBindings[[index]].source_count = 0;
    end;
    for index = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        _BundleTileBindings[[index]].valid = FALSE;
        _BundleTileBindings[[index]].destination_valid = FALSE;
        _BundleTileBindings[[index]].destination_allocated_by_bundle = FALSE;
        _BundleTileBindings[[index]].source0_valid = FALSE;
        _BundleTileBindings[[index]].source1_valid = FALSE;
        _BundleTileBindings[[index]].last = FALSE;
    end;
    for index = 0 to 3 do
        _BundleSharedBindings[[index]].valid = FALSE;
        _BundleSharedBindings[[index]].shared_id = Zeros{8};
        _BundleSharedBindings[[index]].size_code = 0;
        _BundleSharedBindings[[index]].pe_mask = Zeros{4};
        _BundleSharedBindings[[index]].consumed = FALSE;
    end;
    _BundleControlAttributes.trap_enabled = FALSE;
    _BundleControlAttributes.atomic = FALSE;
    _BundleControlAttributes.acquire = FALSE;
    _BundleControlAttributes.release = FALSE;
    _BundleControlAttributes.far = FALSE;
    _BundleControlAttributes.direct_register = FALSE;
    _BundleDataAttributes.data_type = Zeros{5};
    _BundleDataAttributes.data_layout = Zeros{5};
    _BundleDataAttributes.pad_value = Zeros{2};
    _BundleDataAttributes.conversion_mode = Zeros{3};
    _BundleDataAttributes.rounding_mode = Zeros{3};
    _BundleDataAttributes.saturating = FALSE;
    _BundleDataAttributes.canonicalize = FALSE;
end;

func SetBundleDimension(index: BundleDimensionIndex, value: Word)
begin
    _BundleDimensions[[index]] = value;
end;

func BindBundleSharedIO(shared_id: bits(8), size_code: integer {0..7},
                        pe_mask: bits(4))
begin
    for index = 0 to 3 do
        if _BundleSharedBindings[[index]].valid &&
           _BundleSharedBindings[[index]].shared_id == shared_id &&
           !_BundleSharedBindings[[index]].consumed then
            SetFault(Fault_TileLegality, ReadTPC());
            return;
        end;
    end;
    for index = 0 to 3 do
        if !_BundleSharedBindings[[index]].valid then
            _BundleSharedBindings[[index]].valid = TRUE;
            _BundleSharedBindings[[index]].shared_id = shared_id;
            _BundleSharedBindings[[index]].size_code = size_code;
            _BundleSharedBindings[[index]].pe_mask = pe_mask;
            _BundleSharedBindings[[index]].consumed = FALSE;
            return;
        end;
    end;
    SetFault(Fault_TileLegality, ReadTPC());
end;

readonly func BundleSharedBindingCount() => integer {0..4}
begin
    var count: integer {0..4} = 0;
    for index = 0 to 3 do
        if _BundleSharedBindings[[index]].valid then
            count = (count + 1) as integer {0..4};
        end;
    end;
    return count;
end;

readonly func BundleSharedBindingId(ordinal: integer {0..3}) => bits(8)
begin
    assert _BundleSharedBindings[[ordinal]].valid &&
           !_BundleSharedBindings[[ordinal]].consumed;
    return _BundleSharedBindings[[ordinal]].shared_id;
end;

readonly func BundleSharedBindingSize(ordinal: integer {0..3})
        => integer {0..7}
begin
    assert _BundleSharedBindings[[ordinal]].valid &&
           !_BundleSharedBindings[[ordinal]].consumed;
    return _BundleSharedBindings[[ordinal]].size_code;
end;

readonly func BundleSharedBindingMask(ordinal: integer {0..3}) => bits(4)
begin
    assert _BundleSharedBindings[[ordinal]].valid &&
           !_BundleSharedBindings[[ordinal]].consumed;
    return _BundleSharedBindings[[ordinal]].pe_mask;
end;

readonly func BundleSharedBindingIsDestination(
    ordinal: integer {0..3}) => boolean
begin
    return BundleSharedBindingSize(ordinal) != 0;
end;

func ConsumeBundleSharedBindings(count: integer {1..4})
begin
    assert BundleSharedBindingCount() == count;
    for index = 0 to count - 1 looplimit 4 do
        assert _BundleSharedBindings[[index]].valid &&
               !_BundleSharedBindings[[index]].consumed;
        _BundleSharedBindings[[index]].consumed = TRUE;
    end;
end;

readonly func BundleSharedBindingsUnconsumed() => boolean
begin
    for index = 0 to 3 do
        if _BundleSharedBindings[[index]].valid &&
           !_BundleSharedBindings[[index]].consumed then return TRUE; end;
    end;
    return FALSE;
end;

readonly func BundleTileMaskCanAppend(pe_mask: bits(4)) => boolean
begin
    if pe_mask == Zeros{4} then return FALSE; end;
    for index = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[index]].valid &&
           _BundleTileBindings[[index]].pe_mask != pe_mask then
            return FALSE;
        end;
    end;
    return TRUE;
end;

func SetBundleArgument(value: Word)
begin
    _BundleArgument = value;
    _BundleArgumentKind = '001';
    _CommitArgument = value;
end;

func SetBundleArgumentKind(kind: bits(3), value: Word)
begin
    _BundleArgumentKind = kind;
    _BundleArgument = value;
    _CommitArgument = value;
end;

func SetBundleBodyAddress(address: Word)
begin
    if address[0] == '1' then
        SetFault(Fault_InstructionPC, address);
    else
        _BundleBodyAddress = address;
        WriteBPC(address);
    end;
end;

func SetBundleScalarBinding(index: BundleScalarBindingIndex,
                           destination: Reg5Selector,
                           source0: Reg5Selector,
                           source1: Reg5Selector,
                           source2: Reg5Selector,
                           source_count: integer {0..3})
begin
    _BundleScalarBindings[[index]].valid = TRUE;
    _BundleScalarBindings[[index]].destination = destination;
    _BundleScalarBindings[[index]].source0 = source0;
    _BundleScalarBindings[[index]].source1 = source1;
    _BundleScalarBindings[[index]].source2 = source2;
    _BundleScalarBindings[[index]].source_count = source_count;
end;

func SetBundleTileBinding(index: BundleTileBindingIndex,
                         destination_valid: boolean,
                         destination: TileIndex,
                         destination_size: integer {0..15},
                         pe_mask: bits(4),
                         source0_valid: boolean,
                         source1_valid: boolean,
                         source0: TileIndex,
                         source1: TileIndex,
                         last: boolean)
begin
    if destination_valid &&
       (destination > 3 || !TileSizeCodeIsLegal(destination_size)) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    _BundleTileBindings[[index]].valid = TRUE;
    _BundleTileBindings[[index]].destination_valid = destination_valid;
    _BundleTileBindings[[index]].destination = destination;
    _BundleTileBindings[[index]].destination_hand =
        Zeros{2} + (destination MOD 4);
    _BundleTileBindings[[index]].destination_allocated_by_bundle = FALSE;
    _BundleTileBindings[[index]].destination_size = destination_size;
    _BundleTileBindings[[index]].pe_mask = pe_mask;
    _BundleTileBindings[[index]].source0_valid = source0_valid;
    _BundleTileBindings[[index]].source1_valid = source1_valid;
    _BundleTileBindings[[index]].source0 = source0;
    _BundleTileBindings[[index]].source1 = source1;
    _BundleTileBindings[[index]].last = last;
end;

func AddBundleTileBinding(destination_valid: boolean,
                          destination: TileIndex,
                          destination_size: integer {0..15},
                          pe_mask: bits(4),
                          source0_valid: boolean,
                          source1_valid: boolean,
                          source0: TileIndex,
                          source1: TileIndex,
                          last: boolean)
begin
    var added = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if !added && !_BundleTileBindings[[binding]].valid then
            SetBundleTileBinding(binding as BundleTileBindingIndex,
                destination_valid, destination, destination_size, pe_mask,
                source0_valid, source1_valid, source0, source1, last);
            added = TRUE;
        end;
    end;
    if !added then SetFault(Fault_TileLegality, ReadTPC()); end;
end;

readonly func BundleTileDestinationSizeLegal(
    binding: BundleTileBindingIndex) => boolean
begin
    if !_BundleTileBindings[[binding]].destination_valid then return TRUE; end;
    return TileSizeCodeIsLegal(
        _BundleTileBindings[[binding]].destination_size);
end;

readonly func BundleTileDestinationSizeBytes(
    binding: BundleTileBindingIndex)
    => integer {0,128,256,512,1024,2048,4096,8192}
begin
    if !_BundleTileBindings[[binding]].destination_valid then return 0; end;
    assert BundleTileDestinationSizeLegal(binding);
    return TileSizeCodeBytes(
        _BundleTileBindings[[binding]].destination_size as integer {1..7});
end;

readonly func BundleTileIsDestination(tile: TileIndex) => boolean
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           _BundleTileBindings[[binding]].destination == tile then
            return TRUE;
        end;
    end;
    return FALSE;
end;

func CommitBundleTileSourceLifetime(binding: BundleTileBindingIndex)
begin
    if _BundleTileBindings[[binding]].source0_valid &&
       !BundleTileIsDestination(_BundleTileBindings[[binding]].source0) then
        ReleaseTile(_BundleTileBindings[[binding]].source0);
    end;
    if _BundleTileBindings[[binding]].source1_valid &&
       !BundleTileIsDestination(_BundleTileBindings[[binding]].source1) &&
       (!_BundleTileBindings[[binding]].source0_valid ||
        _BundleTileBindings[[binding]].source1 !=
            _BundleTileBindings[[binding]].source0) then
        ReleaseTile(_BundleTileBindings[[binding]].source1);
    end;
end;

func FinalizeBundleTileAttempt(status: TileExecutionStatus)
begin
    if status == TileExecution_Executed then
        for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
            if _BundleTileBindings[[binding]].valid then
                CommitBundleTileSourceLifetime(
                    binding as BundleTileBindingIndex);
            end;
        end;
    end;
end;

func SetBundleControlAttributeState(trap_enabled: boolean, atomic: boolean,
                                   acquire: boolean, release: boolean,
                                   far: boolean, direct_register: boolean)
begin
    _BundleControlAttributes.trap_enabled = trap_enabled;
    _BundleControlAttributes.atomic = atomic;
    _BundleControlAttributes.acquire = acquire;
    _BundleControlAttributes.release = release;
    _BundleControlAttributes.far = far;
    _BundleControlAttributes.direct_register = direct_register;
end;

func SetBundleDataAttributeState(data_type: bits(5), data_layout: bits(5),
                                pad_value: bits(2), conversion_mode: bits(3),
                                rounding_mode: bits(3), saturating: boolean)
begin
    _BundleDataAttributes.data_type = data_type;
    _BundleDataAttributes.data_layout = data_layout;
    _BundleDataAttributes.pad_value = pad_value;
    _BundleDataAttributes.conversion_mode = conversion_mode;
    _BundleDataAttributes.rounding_mode = rounding_mode;
    _BundleDataAttributes.saturating = saturating;
    _BundleDataAttributes.canonicalize = FALSE;
end;

func BeginBundle(kind: BundleKind, transfer: BundleTransfer, target: Word,
                fallthrough: Word, return_target: Word, condition: boolean)
begin
    if _BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    elsif target[0] == '1' then
        SetFault(Fault_InstructionPC, target);
    else
        _BundleActive = TRUE;
        _BundleBodyActive = FALSE;
        _BundleKind = kind;
        _BundleTransfer = transfer;
        _BundleCondition = condition;
        _BundleTarget = target;
        _BundleFallthrough = fallthrough;
        _BundleReturnTarget = return_target;
        WriteBPC(target);
        // BSTART installs the transfer selected for the bundle commit. Header
        // commands remain sequential until BSTOP or the next BSTART commits it.
        WriteTPC(fallthrough);
        if transfer == BundleTransfer_Call ||
           transfer == BundleTransfer_IndirectCall then
            _ReturnAddress = return_target;
            WriteGPR(10, return_target);
        end;
    end;
end;

func EnterBundleBody()
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    else
        _BundleBodyActive = TRUE;
        // Only machine-parallel and machine-sequential bodies enter the
        // kernel EXEC domain. Other bundle kinds retain the stored mask and
        // continue to branch on CARG.
        if BundleKindUsesExecutionMask(_BundleKind) then
            WriteExecutionMask(Ones{PTO_XLEN});
        end;
        WriteTPC(ReadBPC());
    end;
end;

func StopBundle()
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    else
        _BundleActive = FALSE;
        _BundleBodyActive = FALSE;
        WriteTPC(_BundleFallthrough);
    end;
end;

func StopBundleAt(continuation: Word)
begin
    if !_BundleActive then
        SetFault(Fault_BundleControl, ReadTPC());
    elsif continuation[0] == '1' then
        SetFault(Fault_InstructionPC, continuation);
    else
        let take_target = _BundleTransfer == BundleTransfer_Direct ||
            _BundleTransfer == BundleTransfer_Call ||
            _BundleTransfer == BundleTransfer_Indirect ||
            _BundleTransfer == BundleTransfer_IndirectCall ||
            _BundleTransfer == BundleTransfer_Return ||
            (_BundleTransfer == BundleTransfer_Conditional && _BundleCondition);
        _BundleActive = FALSE;
        _BundleBodyActive = FALSE;
        if take_target then WriteTPC(_BundleTarget);
        else WriteTPC(continuation);
        end;
    end;
end;

func SaveExecutionContextState(base_address: Word, length_bytes: Word,
                               kind: Word)
begin
    let ring = CurrentACR();
    SaveTrapContext(ring, ring);
    _LastMemoryCommandAddress = base_address;
    _LastMemoryCommandSize = length_bytes;
    _ControlRequestOperand = kind;
end;

func RecoverExecutionContextState(base_address: Word, length_bytes: Word,
                                  kind: Word)
begin
    let ring = CurrentACR();
    if !RecoverTrapContext(ring) then
        SetFault(Fault_BundleControl, ReadTPC());
    else
        _LastMemoryCommandAddress = base_address;
        _LastMemoryCommandSize = length_bytes;
        _ControlRequestOperand = kind;
    end;
end;

func EnterFrame(begin_reg: Reg5Selector, end_reg: Reg5Selector, size: Word)
begin
    _LastFrameBegin = begin_reg;
    _LastFrameEnd = end_reg;
    _LastFrameSize = size;
    if _FrameDepth != PTO_MODEL_MEMORY_EVENTS then
        _FrameDepth = (_FrameDepth + 1) as integer {0..PTO_MODEL_MEMORY_EVENTS};
    end;
end;

func ExitFrame(begin_reg: Reg5Selector, end_reg: Reg5Selector, size: Word)
begin
    _LastFrameBegin = begin_reg;
    _LastFrameEnd = end_reg;
    _LastFrameSize = size;
    if _FrameDepth != 0 then
        _FrameDepth = (_FrameDepth - 1) as integer {0..PTO_MODEL_MEMORY_EVENTS};
    end;
end;

func ReturnFromFrame(begin_reg: Reg5Selector, end_reg: Reg5Selector,
                     size: Word, use_return_address: boolean)
begin
    ExitFrame(begin_reg, end_reg, size);
    if use_return_address then
        WriteTPC(_ReturnAddress);
    else
        WriteTPC(_BundleReturnTarget);
    end;
end;

func ExecuteQueueManagerMove(destination: Reg5Selector, left: Word,
                             right: Word, flags: bits(4))
begin
    _LastQueueLeft = left;
    _LastQueueRight = right;
    _LastQueueFlags = flags;
    WriteScalarDestination(destination, left);
end;

func ExecuteQueueManagerPop(destination0: Reg5Selector,
                            destination1: Reg5Selector,
                            left: Word, right: Word, flags: bits(4))
begin
    _LastQueueLeft = left;
    _LastQueueRight = right;
    _LastQueueFlags = flags;
    WriteScalarDestination(destination0, left);
    WriteScalarDestination(destination1, right);
end;

func ExecuteQueueManagerPush(destination: Reg5Selector, left: Word,
                             right: Word, flags: bits(4))
begin
    _LastQueueLeft = left;
    _LastQueueRight = right;
    _LastQueueFlags = flags;
    WriteScalarDestination(destination, left + right);
end;

func ExecuteBoundedMemoryCopy(destination: Word, source: Word, length: Word)
begin
    if UInt(length) > 63 then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;
    let byte_count = UInt(length) as integer {0..63};
    if byte_count != 0 then
        let access_size = byte_count as integer {1..262144};
        let read_probe = ProbeDataAccess(source, access_size, 1, FALSE);
        let write_probe = ProbeDataAccess(destination, access_size, 1, TRUE);
        if RaiseDataAccessFault(read_probe, source) then
            return;
        elsif RaiseDataAccessFault(write_probe, destination) then
            return;
        else
            let buffer = LoadTranslatedBytesBounded(
                read_probe.translated_address, byte_count);
            StoreTranslatedBytesBounded(destination,
                write_probe.translated_address, byte_count, buffer);
        end;
    end;
    if _LastFault == Fault_None then
        _LastMemoryCommandAddress = destination;
        _LastMemoryCommandSize = length;
    end;
end;

func ExecuteBoundedMemorySet(destination: Word, value: Word, length: Word)
begin
    if UInt(length) > 63 then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;
    let byte_count = UInt(length) as integer {0..63};
    if byte_count != 0 then
        let access_size = byte_count as integer {1..262144};
        let write_probe = ProbeDataAccess(destination, access_size, 1, TRUE);
        if RaiseDataAccessFault(write_probe, destination) then
            return;
        else
            StoreTranslatedFillBounded(destination, write_probe.translated_address,
                byte_count, value[7:0]);
        end;
    end;
    if _LastFault == Fault_None then
        _LastMemoryCommandAddress = destination;
        _LastMemoryCommandSize = length;
    end;
end;

func ExecuteCrossBlockTransferState(acr_id: bits(10), block_id: bits(7))
begin
    _LastCrossBlockACR = acr_id;
    _LastCrossBlockID = block_id;
    _BundleTransfer = BundleTransfer_Indirect;
end;
