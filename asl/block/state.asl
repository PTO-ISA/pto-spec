// PTO-REQ-BLOCK-STATE-001: architecture-visible block-control state.

type BlockScalarBinding of record {
    valid: boolean,
    destination: Reg5Selector,
    source0: Reg5Selector,
    source1: Reg5Selector,
    source2: Reg5Selector,
    source_count: integer {0..3}
};

type BlockTileBinding of record {
    valid: boolean,
    destination_valid: boolean,
    destination: TileIndex,
    destination_hand: bits(2),
    destination_allocated_by_block: boolean,
    destination_size: integer {0..15},
    source0_valid: boolean,
    source1_valid: boolean,
    source0: TileIndex,
    source1: TileIndex,
    source0_reuse: boolean,
    source1_reuse: boolean,
    last: boolean
};

type BlockTileOperationSelection of record {
    valid: boolean,
    // 0=TEPL, 1=TMA, 2=CUBE. The generated decoder owns the public enum;
    // block state stores the stable encoded identity without depending on it.
    family: bits(2),
    code: bits(12),
    data_type: bits(5)
};

type BlockControlAttributes of record {
    trap_enabled: boolean,
    atomic: boolean,
    acquire: boolean,
    release: boolean,
    far: boolean,
    direct_register: boolean
};

type BlockDataAttributes of record {
    data_type: bits(5),
    data_layout: bits(5),
    pad_value: bits(2),
    conversion_mode: bits(3),
    rounding_mode: bits(3),
    saturating: boolean,
    canonicalize: boolean
};

var _BlockKind : BlockKind;
var _BlockTransfer : BlockTransfer;
var _BlockCondition : boolean;
var _BlockTarget : Word;
var _BlockFallthrough : Word;
var _BlockReturnTarget : Word;
var _BlockBodyAddress : Word;
var _BlockArgument : Word;
var _BlockDimensions : array [[PTO_BLOCK_DIMENSION_COUNT]] of Word;
var _BlockScalarBindings : array [[PTO_BLOCK_SCALAR_BINDING_COUNT]]
    of BlockScalarBinding;
var _BlockTileBindings : array [[PTO_BLOCK_TILE_BINDING_COUNT]]
    of BlockTileBinding;
var _BlockControlAttributes : BlockControlAttributes;
var _BlockDataAttributes : BlockDataAttributes;
var _BlockTileOperation : BlockTileOperationSelection;
// Bit zero (NORM) is always enabled. Other accepted layout bits are set only
// by a profile/platform capability advertisement.
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

func ResetBlockControlState()
begin
    _BlockActive = FALSE;
    _BlockBodyActive = FALSE;
    _BlockKind = BlockKind_Standard;
    _BlockTransfer = BlockTransfer_Fallthrough;
    _BlockCondition = TRUE;
    _BlockTarget = Zeros{PTO_XLEN};
    _BlockFallthrough = Zeros{PTO_XLEN};
    _BlockReturnTarget = Zeros{PTO_XLEN};
    _BlockBodyAddress = Zeros{PTO_XLEN};
    _BlockArgument = Zeros{PTO_XLEN};
    for index = 0 to PTO_BLOCK_DIMENSION_COUNT - 1 do
        _BlockDimensions[[index]] = Zeros{PTO_XLEN};
    end;
    for index = 0 to PTO_BLOCK_SCALAR_BINDING_COUNT - 1 do
        _BlockScalarBindings[[index]].valid = FALSE;
        _BlockScalarBindings[[index]].destination = 0;
        _BlockScalarBindings[[index]].source0 = 0;
        _BlockScalarBindings[[index]].source1 = 0;
        _BlockScalarBindings[[index]].source2 = 0;
        _BlockScalarBindings[[index]].source_count = 0;
    end;
    for index = 0 to PTO_BLOCK_TILE_BINDING_COUNT - 1 do
        _BlockTileBindings[[index]].valid = FALSE;
        _BlockTileBindings[[index]].destination_valid = FALSE;
        _BlockTileBindings[[index]].destination = 0;
        _BlockTileBindings[[index]].destination_hand = Zeros{2};
        _BlockTileBindings[[index]].destination_allocated_by_block = FALSE;
        _BlockTileBindings[[index]].destination_size = 0;
        _BlockTileBindings[[index]].source0_valid = FALSE;
        _BlockTileBindings[[index]].source1_valid = FALSE;
        _BlockTileBindings[[index]].source0 = 0;
        _BlockTileBindings[[index]].source1 = 0;
        _BlockTileBindings[[index]].source0_reuse = FALSE;
        _BlockTileBindings[[index]].source1_reuse = FALSE;
        _BlockTileBindings[[index]].last = FALSE;
    end;
    _BlockControlAttributes.trap_enabled = FALSE;
    _BlockControlAttributes.atomic = FALSE;
    _BlockControlAttributes.acquire = FALSE;
    _BlockControlAttributes.release = FALSE;
    _BlockControlAttributes.far = FALSE;
    _BlockControlAttributes.direct_register = FALSE;
    _BlockDataAttributes.data_type = Zeros{5};
    _BlockDataAttributes.data_layout = Zeros{5};
    _BlockDataAttributes.pad_value = Zeros{2};
    _BlockDataAttributes.conversion_mode = Zeros{3};
    _BlockDataAttributes.rounding_mode = Zeros{3};
    _BlockDataAttributes.saturating = FALSE;
    _BlockDataAttributes.canonicalize = FALSE;
    _BlockTileOperation.valid = FALSE;
    _BlockTileOperation.family = Zeros{2};
    _BlockTileOperation.code = Zeros{12};
    _BlockTileOperation.data_type = Zeros{5};
    _TileDataLayoutCapabilities = Zeros{32};
    _TileDataLayoutCapabilities[0] = '1';
    for ring = 0 to PTO_ACR_COUNT - 1 do
        _TrapContexts[[ring]].valid = FALSE;
        _TrapContexts[[ring]].source_acr = 0;
        _TrapContexts[[ring]].tpc = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].bpc = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].core_state = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].block_argument = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].commit_argument = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].block_active = FALSE;
        _TrapContexts[[ring]].block_body_active = FALSE;
        for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
            _TrapContexts[[ring]].t_queue[[index]] = Zeros{PTO_XLEN};
            _TrapContexts[[ring]].u_queue[[index]] = Zeros{PTO_XLEN};
        end;
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
end;

readonly func BlockIsActive() => boolean
begin
    return _BlockActive;
end;

readonly func BlockBodyIsActive() => boolean
begin
    return _BlockBodyActive;
end;

func SetBlockDimension(index: BlockDimensionIndex, value: Word)
begin
    _BlockDimensions[[index]] = value;
end;

func SetBlockArgument(value: Word)
begin
    _BlockArgument = value;
    _CommitArgument = value;
end;

func SetBlockBodyAddress(address: Word)
begin
    if address[0] == '1' then
        SetFault(Fault_InstructionPC, address);
    else
        _BlockBodyAddress = address;
        WriteBPC(address);
    end;
end;

func SetBlockScalarBinding(index: BlockScalarBindingIndex,
                           destination: Reg5Selector,
                           source0: Reg5Selector,
                           source1: Reg5Selector,
                           source2: Reg5Selector,
                           source_count: integer {0..3})
begin
    _BlockScalarBindings[[index]].valid = TRUE;
    _BlockScalarBindings[[index]].destination = destination;
    _BlockScalarBindings[[index]].source0 = source0;
    _BlockScalarBindings[[index]].source1 = source1;
    _BlockScalarBindings[[index]].source2 = source2;
    _BlockScalarBindings[[index]].source_count = source_count;
end;

func SetBlockTileBinding(index: BlockTileBindingIndex,
                         destination_valid: boolean,
                         destination: TileIndex,
                         destination_size: integer {0..15},
                         source0_valid: boolean,
                         source1_valid: boolean,
                         source0: TileIndex,
                         source1: TileIndex,
                         source0_reuse: boolean,
                         source1_reuse: boolean,
                         last: boolean)
begin
    if destination_valid &&
       (destination > 3 || !TileSizeCodeIsLegal(destination_size)) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    _BlockTileBindings[[index]].valid = TRUE;
    _BlockTileBindings[[index]].destination_valid = destination_valid;
    _BlockTileBindings[[index]].destination = destination;
    _BlockTileBindings[[index]].destination_hand =
        Zeros{2} + (destination MOD 4);
    _BlockTileBindings[[index]].destination_allocated_by_block = FALSE;
    _BlockTileBindings[[index]].destination_size = destination_size;
    _BlockTileBindings[[index]].source0_valid = source0_valid;
    _BlockTileBindings[[index]].source1_valid = source1_valid;
    _BlockTileBindings[[index]].source0 = source0;
    _BlockTileBindings[[index]].source1 = source1;
    _BlockTileBindings[[index]].source0_reuse = source0_reuse;
    _BlockTileBindings[[index]].source1_reuse = source1_reuse;
    _BlockTileBindings[[index]].last = last;
end;

func AddBlockTileBinding(destination_valid: boolean,
                         destination: TileIndex,
                         destination_size: integer {0..15},
                         source0_valid: boolean,
                         source1_valid: boolean,
                         source0: TileIndex,
                         source1: TileIndex,
                         source0_reuse: boolean,
                         source1_reuse: boolean,
                         last: boolean)
begin
    var added = FALSE;
    for binding = 0 to PTO_BLOCK_TILE_BINDING_COUNT - 1 do
        if !added && !_BlockTileBindings[[binding]].valid then
            SetBlockTileBinding(binding as BlockTileBindingIndex,
                destination_valid, destination, destination_size,
                source0_valid, source1_valid, source0, source1,
                source0_reuse, source1_reuse, last);
            added = TRUE;
        end;
    end;
    if !added then SetFault(Fault_TileLegality, ReadTPC()); end;
end;

func SetBlockTileOperationSelection(family: bits(2), code: bits(12),
                                    data_type: bits(5))
begin
    _BlockTileOperation.valid = TRUE;
    _BlockTileOperation.family = family;
    _BlockTileOperation.code = code;
    _BlockTileOperation.data_type = data_type;
end;

readonly func BlockTileOperationSelected() => boolean
begin
    return _BlockTileOperation.valid;
end;

readonly func BlockTileDescriptorReady() => boolean
begin
    if _BlockScalarBindings[[0]].valid then return TRUE; end;
    for binding = 0 to PTO_BLOCK_TILE_BINDING_COUNT - 1 do
        if _BlockTileBindings[[binding]].valid then return TRUE; end;
    end;
    return FALSE;
end;

readonly func CurrentBlockTileOperationDataTypeCode() => bits(5)
begin
    assert _BlockTileOperation.valid;
    return _BlockTileOperation.data_type;
end;

func ClearBlockTileOperationSelection()
begin
    _BlockTileOperation.valid = FALSE;
    _BlockTileOperation.family = Zeros{2};
    _BlockTileOperation.code = Zeros{12};
    _BlockTileOperation.data_type = Zeros{5};
end;

readonly func BlockTileDestinationSizeLegal(
    binding: BlockTileBindingIndex) => boolean
begin
    if !_BlockTileBindings[[binding]].destination_valid then return TRUE; end;
    return TileSizeCodeIsLegal(_BlockTileBindings[[binding]].destination_size);
end;

readonly func BlockTileDestinationSizeBytes(
    binding: BlockTileBindingIndex) => integer {0,128,256,512,1024,2048,4096,8192}
begin
    if !_BlockTileBindings[[binding]].destination_valid then return 0; end;
    assert BlockTileDestinationSizeLegal(binding);
    return TileSizeCodeBytes(
        _BlockTileBindings[[binding]].destination_size as integer {3..9});
end;

// The generated/direct execution boundary invokes this only after an explicit
// successful commit. Faulted, retried, or squashed attempts never call it.
func CommitBlockTileSourceLifetime(binding: BlockTileBindingIndex)
begin
    if _BlockTileBindings[[binding]].source0_valid &&
       !_BlockTileBindings[[binding]].source0_reuse then
        ReleaseTile(_BlockTileBindings[[binding]].source0);
    end;
    if _BlockTileBindings[[binding]].source1_valid &&
       !_BlockTileBindings[[binding]].source1_reuse &&
       (!_BlockTileBindings[[binding]].source0_valid ||
        _BlockTileBindings[[binding]].source1 !=
            _BlockTileBindings[[binding]].source0) then
        ReleaseTile(_BlockTileBindings[[binding]].source1);
    end;
end;

func FinalizeBlockTileAttempt(status: TileExecutionStatus)
begin
    if status == TileExecution_Executed then
        for binding = 0 to PTO_BLOCK_TILE_BINDING_COUNT - 1 do
            if _BlockTileBindings[[binding]].valid then
                CommitBlockTileSourceLifetime(
                    binding as BlockTileBindingIndex);
            end;
        end;
    end;
end;

func SetBlockControlAttributeState(trap_enabled: boolean, atomic: boolean,
                                   acquire: boolean, release: boolean,
                                   far: boolean, direct_register: boolean)
begin
    _BlockControlAttributes.trap_enabled = trap_enabled;
    _BlockControlAttributes.atomic = atomic;
    _BlockControlAttributes.acquire = acquire;
    _BlockControlAttributes.release = release;
    _BlockControlAttributes.far = far;
    _BlockControlAttributes.direct_register = direct_register;
end;

readonly func CurrentBlockAtomic() => boolean
begin
    return _BlockControlAttributes.atomic;
end;

readonly func CurrentBlockMemoryOrder() => MemoryOrder
begin
    if _BlockControlAttributes.acquire &&
       _BlockControlAttributes.release then
        return MemoryOrder_AcquireRelease;
    elsif _BlockControlAttributes.acquire then
        return MemoryOrder_Acquire;
    elsif _BlockControlAttributes.release then
        return MemoryOrder_Release;
    else
        return MemoryOrder_Relaxed;
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

func AdvertiseTileDataLayout(data_layout: bits(5))
begin
    assert TileDataLayoutCodeAccepted(data_layout);
    _TileDataLayoutCapabilities[UInt(data_layout)] = '1';
end;

readonly func CurrentBlockPadValue() => TilePadValue
begin
    case UInt(_BlockDataAttributes.pad_value) of
        when 0 => return TilePad_Zero;
        when 1 => return TilePad_Max;
        when 2 => return TilePad_Min;
        when 3 => return TilePad_Null;
    end;
end;

readonly func CurrentBlockDataTypeCode() => bits(5)
begin
    return _BlockDataAttributes.data_type;
end;

readonly func CurrentBlockCanonicalize() => boolean
begin
    return _BlockDataAttributes.canonicalize;
end;

func SetBlockDataAttributeState0571(
    data_type: bits(5), data_layout: bits(5), pad_value: bits(2),
    conversion_mode: bits(3), rounding_mode: bits(3), saturating: boolean,
    canonicalize: boolean)
begin
    if !TileDataTypeEncodingValid(ZeroExtend{PTO_XLEN}(data_type)) ||
       !TileDataLayoutCodeSupported(data_layout) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    _BlockDataAttributes.data_type = data_type;
    _BlockDataAttributes.data_layout = data_layout;
    _BlockDataAttributes.pad_value = pad_value;
    _BlockDataAttributes.conversion_mode = conversion_mode;
    _BlockDataAttributes.rounding_mode = rounding_mode;
    _BlockDataAttributes.saturating = saturating;
    _BlockDataAttributes.canonicalize = canonicalize;
end;

func BeginBlock(kind: BlockKind, transfer: BlockTransfer, target: Word,
                fallthrough: Word, return_target: Word, condition: boolean)
begin
    if _BlockActive then
        SetFault(Fault_BlockControl, ReadTPC());
    elsif target[0] == '1' then
        SetFault(Fault_InstructionPC, target);
    elsif transfer == BlockTransfer_Conditional && !condition then
        _BlockActive = FALSE;
        _BlockBodyActive = FALSE;
        _BlockKind = kind;
        _BlockTransfer = transfer;
        _BlockCondition = FALSE;
        _BlockTarget = target;
        _BlockFallthrough = fallthrough;
        _BlockReturnTarget = return_target;
        WriteTPC(fallthrough);
    else
        _BlockActive = TRUE;
        _BlockBodyActive = FALSE;
        _BlockKind = kind;
        _BlockTransfer = transfer;
        _BlockCondition = condition;
        _BlockTarget = target;
        _BlockFallthrough = fallthrough;
        _BlockReturnTarget = return_target;
        WriteBPC(target);
        WriteTPC(target);
        if transfer == BlockTransfer_Call ||
           transfer == BlockTransfer_IndirectCall then
            _ReturnAddress = return_target;
            WriteGPR(10, return_target);
        end;
    end;
end;

func EnterBlockBody()
begin
    if !_BlockActive then
        SetFault(Fault_BlockControl, ReadTPC());
    else
        _BlockBodyActive = TRUE;
        WriteTPC(ReadBPC());
    end;
end;

func StopBlock()
begin
    if !_BlockActive then
        SetFault(Fault_BlockControl, ReadTPC());
    else
        _BlockActive = FALSE;
        _BlockBodyActive = FALSE;
        WriteTPC(_BlockFallthrough);
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
        SetFault(Fault_BlockControl, ReadTPC());
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
        WriteTPC(_BlockReturnTarget);
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
    let byte_count = UInt(length[5:0]) as integer {0..63};
    _LastMemoryCommandAddress = destination;
    _LastMemoryCommandSize = length;
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
end;

func ExecuteBoundedMemorySet(destination: Word, value: Word, length: Word)
begin
    let byte_count = UInt(length[5:0]) as integer {0..63};
    _LastMemoryCommandAddress = destination;
    _LastMemoryCommandSize = length;
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
end;

func ExecuteCrossBlockTransferState(acr_id: bits(10), block_id: bits(7))
begin
    _LastCrossBlockACR = acr_id;
    _LastCrossBlockID = block_id;
    _BlockTransfer = BlockTransfer_Indirect;
end;
