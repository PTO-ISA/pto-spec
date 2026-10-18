<!-- GENERATED FROM: asl/arch/state/pe-execution-context.asl -->
# PE Execution Context

**Normative ASL source:** `asl/arch/state/pe-execution-context.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-PE-EXECUTION-CONTEXT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-pe-context-purpose role=purpose-scope -->
## Purpose and scope

This unit lets the model switch among PE0 through PE3 and among modeled Cores without treating one global ASL working set as shared private state. A switch saves the current private execution context and restores the selected context; Core-local state is banked separately.

The separation matters whenever one PE parks, faults, or retries while a peer continues. Selecting the peer must expose that peer's PC, Block state, queues, Local Tiles, and trap state without rewinding shared progress.

<!-- PTO-READER-BLOCK: arch-pe-context-concepts role=concepts-state -->
## What is banked

`PEExecutionContext` contains the instruction counters, encoded instruction state, Local Tile descriptors and payload generations, temporary queues, Block bindings and execution-domain state, fault and trap state, reservations, numeric status, and other PE-private fields. `CoreExecutionContext` contains the Core-local access-control, timer, interrupt, and related system-register state.

The active globals are the working copy used by existing helpers. `_PEExecutionContexts` and `_CoreExecutionContexts` are the backing banks, with validity bits and default contexts for entries that have not yet been saved.

<!-- PTO-READER-BLOCK: arch-pe-context-rules role=rules-interactions -->
## Selection rules

`SelectExecutionContext` saves the current valid PE and Core working sets before loading a different selection. Selecting another PE in the same Core changes only the PE working set; selecting another Core also changes the Core-local working set. A first selection loads the corresponding default context.

The snapshot deliberately includes Local Tile and Block progress because retry must resume the same PE-private operation. Shared GM state, memory-event history, synchronization records, and Shared Tile state are not restored from a PE snapshot, so peer progress and committed effects remain current.

<!-- PTO-READER-BLOCK: arch-pe-context-boundaries role=boundaries -->
## Boundaries

A saved context is not a checkpoint of the whole machine. Restoring PE0 cannot roll back a Shared publication made by PE1, remove a memory event, or undo a completed Core collective. Those objects have their own Core-wide or system-wide owners.

The context switch also does not decide whether a trapped operation may retry. Trap recovery, GM-obligation identity, source lifetimes, and generation owners enforce those conditions around the saved private fields.

<!-- PTO-READER-BLOCK: arch-pe-context-example role=example-usage -->
## Reading example

PE0 may stop with a Block active and a Local Tile generation open. After `SelectExecutionContext(core, PE1)`, PE1 sees its own PC, queues, Block bindings, and Local Tiles. If PE1 publishes Shared data and the model selects PE0 again, PE0 resumes its saved local Block state while the Shared publication remains visible because it was never part of PE0's snapshot.

<!-- PTO-READER-BLOCK: arch-pe-context-related role=related-owners-navigation -->
## Related owners

- [Kernel lifecycle](kernel-lifecycle.md) initializes all PE contexts at launch.
- [Local payload generation](local-payload-generation.md) reads and consumes generation state in the selected or banked PE context.
- [Core synchronization](core-synchronization.md) keeps shared rendezvous records outside PE snapshots.
- [GM obligations](../memory-model/gm-obligations.md) retains request identity across context switches and recovery.
- [Trap context](trap-context.md) owns the save-and-restore protocol used for faults and returns.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/pe-execution-context.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-PE-EXECUTION-CONTEXT","surface":"arch","classification":["state","pe-execution-context"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT","PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING","PTO-ARCH-STATE-TRAP-CONTEXT","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-STATE-LOCAL-REGISTERS","PTO-TILE-MODEL-STATE-FEATURE-MAP-DESCRIPTORS"]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-PE-EXECUTION-CONTEXT","classification":["architecture","pe-execution-context"],"scope":"pe","owner":"PTO-ARCH-STATE-PE-EXECUTION-CONTEXT","members":["_PEExecutionContexts","_CurrentPEContextValid","_PEContextBankValid","_DefaultPEExecutionContext"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-CORE-LOCAL-CONTEXT","classification":["architecture","core-local-context"],"scope":"core","owner":"PTO-ARCH-STATE-PE-EXECUTION-CONTEXT","members":["_CoreExecutionContexts","_CurrentCoreContextValid","_CoreContextBankValid","_DefaultCoreExecutionContext"],"depends_on":[]}

// NDF-BEGIN: PTO-ARCH-PE-EXECUTION-CONTEXT-001
// ndf: kind=contract level=L1 layer=state status=accepted
// Each modeled Core MUST keep independent PE0..PE3 contexts. PE selection
// MUST save/restore private instruction, Block, queue, fault/trap, reservation,
// and Local Tile state; Core selection MUST keep Core-local state distinct.
// PE snapshots MUST NOT restore shared GM, event history, synchronization, or
// Shared Tile state, and MUST NOT rewind peer progress or committed effects.
// NDF-END: PTO-ARCH-PE-EXECUTION-CONTEXT-001

// The active globals remain the compatibility working set used by existing
// ASL helpers. Every explicit PE selection first saves that complete PE-local
// set and restores the selected PE's saved set. System GM and event history do
// not appear in this snapshot.
type PEExecutionContext of record {
    pc: Word,
    bpc: Word,
    current_encoded_instruction: bits(64),
    bundle_start_encoded_instruction: bits(64),
    tiles: array [[PTO_TILE_REGISTER_COUNT]] of TileInfo,
    tile_allocation_masks: array [[PTO_TILE_REGISTER_COUNT]] of bits(4),
    tile_payload_live_masks: array [[PTO_TILE_REGISTER_COUNT]] of bits(4),
    tile_payload_generations: array [[PTO_TILE_REGISTER_COUNT]] of integer,
    tile_relative_order: RelativeTileSnapshot,
    tile_relative_valid: RelativeTileValiditySnapshot,
    tile_feature_map_descriptors: TileFeatureMapDescriptorSnapshot,
    thread_ptr: Word,
    global_ptr: Word,
    core_state: Word,
    t_queue: TemporaryQueueSnapshot,
    t_queue_valid: TemporaryQueueValiditySnapshot,
    u_queue: TemporaryQueueSnapshot,
    u_queue_valid: TemporaryQueueValiditySnapshot,
    bundle_active: boolean,
    bundle_body_active: boolean,
    barg: BundleArgumentRegister,
    bundle_commit_target_set: boolean,
    bundle_condition_set: boolean,
    system_block_terminal_pending: boolean,
    bundle_sequential_pc: Word,
    frame_stack_return_target: Word,
    bundle_argument: Word,
    bundle_argument_kind: bits(3),
    bundle_operation: BundleOperationDescriptor,
    bundle_dimensions: BundleDimensionSnapshot,
    bundle_dimension_present: BundleDimensionPresenceSnapshot,
    bundle_scalar_bindings: BundleScalarBindingSnapshot,
    bundle_tile_bindings: BundleTileBindingSnapshot,
    bundle_shared_bindings: BundleSharedBindingSnapshot,
    bundle_range_group: BundleRangeGroupState,
    bundle_zero_participation_seen: boolean,
    bundle_control_attributes: BundleControlAttributes,
    bundle_data_attributes: BundleDataAttributes,
    bundle_data_attributes_present: boolean,
    bundle_execution_mask: BundleExecutionMaskBinding,
    bundle_hint: BundleHintAttributes,
    bundle_fixed_point_attributes: BundleFixedPointAttributes,
    memory_copy_template: MemoryCopyTemplateState,
    frame_template: FrameTemplateState,
    bundle_execution_domain_token: integer,
    frame_depth: integer {0..PTO_MODEL_MEMORY_EVENTS},
    last_frame_begin: Reg5Selector,
    last_frame_end: Reg5Selector,
    last_frame_size: Word,
    last_queue_left: Word,
    last_queue_right: Word,
    last_queue_flags: bits(4),
    last_memory_command_address: Word,
    last_memory_command_size: Word,
    last_cross_block_acr: bits(10),
    last_cross_block_id: bits(7),
    last_bundle_hint_payload: Word,
    return_address: Word,
    commit_argument: Word,
    predicates: PredicateSnapshot,
    last_fault: FaultCode,
    fault_address: Word,
    reservation_valid: boolean,
    reservation_address: Word,
    reservation_size: integer {1,2,4,8},
    last_fence_predecessor: bits(4),
    last_fence_successor: bits(4),
    memory_replay_state: MemoryReplayState,
    extended_system_registers: array [[65536]] of Word,
    acr_trap_asynchronous: array [[PTO_ACR_COUNT]] of boolean,
    acr_trap_argument_valid: array [[PTO_ACR_COUNT]] of boolean,
    acr_trap_cause: array [[PTO_ACR_COUNT]] of bits(24),
    acr_trap_number: array [[PTO_ACR_COUNT]] of TrapNumber,
    acr_trap_argument0: array [[PTO_ACR_COUNT]] of Word,
    trap_contexts: array [[PTO_ACR_COUNT]] of TrapContext,
    current_acr: AccessControlRing,
    memory_origin: MemoryEventOrigin,
    program_order: integer,
    scalar_execution_blocked: boolean
};

type CoreExecutionContext of record {
    system_registers: BaseSystemRegisterState,
    shared_tiles: SharedTileSnapshot,
    local_generations: LocalGenerationSnapshot,
    shared_generations: SharedGenerationSnapshot,
    tile_data_layout_capabilities: bits(32),
    data_cache_epoch: integer,
    instruction_cache_epoch: integer,
    bundle_cache_epoch: integer,
    tlb_epoch: integer,
    last_maintenance_operation: MaintenanceOperation,
    last_maintenance_operand: Word,
    bundle_hint_epoch: integer,
    architecture_request_epoch: integer,
    last_control_request: ExecutionControlRequest,
    control_request_operand: Word
};

type CoreExecutionContextBank of array [[PTO_MODEL_CORE_INSTANCES]]
    of CoreExecutionContext;
type PEExecutionContextBank of array [[PTO_MODEL_CORE_INSTANCES]]
    of array [[PTO_MODEL_MEMORY_AGENTS]] of PEExecutionContext;
type PEContextValidityBank of array [[PTO_MODEL_CORE_INSTANCES]]
    of bits(PTO_MODEL_MEMORY_AGENTS);

var _PEExecutionContexts : PEExecutionContextBank;
var _CoreExecutionContexts : CoreExecutionContextBank;
var _PEContextBankValid : PEContextValidityBank;
var _CoreContextBankValid : bits(PTO_MODEL_CORE_INSTANCES);
var _CurrentPEContextValid : boolean;
var _CurrentCoreContextValid : boolean;
var _DefaultPEExecutionContext : PEExecutionContext;
var _DefaultCoreExecutionContext : CoreExecutionContext;

func SaveSelectedPEExecutionContext()
begin
    let core = _CurrentModelCore;
    let pe = _CurrentMemoryAgent;
    _PEExecutionContexts[[core]][[pe]] = PEExecutionContext {
        pc = _PC,
        bpc = _BPC,
        current_encoded_instruction = _CurrentEncodedInstruction,
        bundle_start_encoded_instruction = _BundleStartEncodedInstruction,
        tiles = _Tiles,
        tile_allocation_masks = _TileAllocationMasks,
        tile_payload_live_masks = _TilePayloadLiveMasks,
        tile_payload_generations = _TilePayloadGenerations,
        tile_relative_order = _TileRelativeOrder,
        tile_relative_valid = _TileRelativeValid,
        tile_feature_map_descriptors = _TileFeatureMapDescriptors,
        thread_ptr = _SystemRegisters.thread_ptr,
        global_ptr = _SystemRegisters.global_ptr,
        core_state = _SystemRegisters.core_state,
        t_queue = _TQueue, t_queue_valid = _TQueueValid,
        u_queue = _UQueue,
        u_queue_valid = _UQueueValid,
        bundle_active = _BundleActive,
        bundle_body_active = _BundleBodyActive,
        barg = _BARG,
        bundle_commit_target_set = _BundleCommitTargetSet,
        bundle_condition_set = _BundleConditionSet,
        system_block_terminal_pending = _SystemBlockTerminalPending,
        bundle_sequential_pc = _BundleSequentialPC,
        frame_stack_return_target = _FrameStackReturnTarget,
        bundle_argument = _BundleArgument,
        bundle_argument_kind = _BundleArgumentKind,
        bundle_operation = _BundleOperation,
        bundle_dimensions = _BundleDimensions,
        bundle_dimension_present = _BundleDimensionPresent,
        bundle_scalar_bindings = _BundleScalarBindings,
        bundle_tile_bindings = _BundleTileBindings,
        bundle_shared_bindings = _BundleSharedBindings,
        bundle_range_group = _BundleRangeGroup,
        bundle_zero_participation_seen = _BundleZeroParticipationSeen,
        bundle_control_attributes = _BundleControlAttributes,
        bundle_data_attributes = _BundleDataAttributes,
        bundle_data_attributes_present = _BundleDataAttributesPresent,
        bundle_execution_mask = _BundleExecutionMask,
        bundle_hint = _BundleHint,
        bundle_fixed_point_attributes = _BundleFixedPointAttributes,
        memory_copy_template = _MemoryCopyTemplate,
        frame_template = _FrameTemplate,
        bundle_execution_domain_token = _BundleExecutionDomainToken,
        frame_depth = _FrameDepth,
        last_frame_begin = _LastFrameBegin,
        last_frame_end = _LastFrameEnd,
        last_frame_size = _LastFrameSize,
        last_queue_left = _LastQueueLeft,
        last_queue_right = _LastQueueRight,
        last_queue_flags = _LastQueueFlags,
        last_memory_command_address = _LastMemoryCommandAddress,
        last_memory_command_size = _LastMemoryCommandSize,
        last_cross_block_acr = _LastCrossBlockACR,
        last_cross_block_id = _LastCrossBlockID,
        last_bundle_hint_payload = _LastBundleHintPayload,
        return_address = _ReturnAddress,
        commit_argument = _CommitArgument,
        predicates = _PredicateRegisters,
        last_fault = _LastFault,
        fault_address = _FaultAddress,
        reservation_valid = _ReservationValid,
        reservation_address = _ReservationAddress,
        reservation_size = _ReservationSize,
        last_fence_predecessor = _LastFencePredecessor,
        last_fence_successor = _LastFenceSuccessor,
        memory_replay_state = _MemoryReplayState,
        extended_system_registers = _ExtendedSystemRegisters,
        acr_trap_asynchronous = _ACRTrapAsynchronous,
        acr_trap_argument_valid = _ACRTrapArgumentValid,
        acr_trap_cause = _ACRTrapCause,
        acr_trap_number = _ACRTrapNumber,
        acr_trap_argument0 = _ACRTrapArgument0,
        trap_contexts = _TrapContexts,
        current_acr = _CurrentACR,
        memory_origin = _CurrentMemoryOrigin,
        program_order = _CurrentProgramOrder,
        scalar_execution_blocked = _ScalarExecutionBlocked
    };
    _PEContextBankValid[[core]][pe] = '1';
    _CurrentPEContextValid = TRUE;
end;

func LoadPEExecutionContext(context: PEExecutionContext)
begin
    _PC = context.pc;
    _BPC = context.bpc;
    _CurrentEncodedInstruction = context.current_encoded_instruction;
    _BundleStartEncodedInstruction = context.bundle_start_encoded_instruction;
    _Tiles = context.tiles;
    _TileAllocationMasks = context.tile_allocation_masks;
    _TilePayloadLiveMasks = context.tile_payload_live_masks;
    _TilePayloadGenerations = context.tile_payload_generations;
    _TileRelativeOrder = context.tile_relative_order;
    _TileRelativeValid = context.tile_relative_valid;
    _TileFeatureMapDescriptors = context.tile_feature_map_descriptors;
    _SystemRegisters.thread_ptr = context.thread_ptr;
    _SystemRegisters.global_ptr = context.global_ptr;
    _SystemRegisters.core_state = context.core_state;
    _TQueue = context.t_queue;
    _TQueueValid = context.t_queue_valid;
    _UQueue = context.u_queue;
    _UQueueValid = context.u_queue_valid;
    _BundleActive = context.bundle_active;
    _BundleBodyActive = context.bundle_body_active;
    _BARG = context.barg;
    _BundleCommitTargetSet = context.bundle_commit_target_set;
    _BundleConditionSet = context.bundle_condition_set;
    _SystemBlockTerminalPending = context.system_block_terminal_pending;
    _BundleSequentialPC = context.bundle_sequential_pc;
    _FrameStackReturnTarget = context.frame_stack_return_target;
    _BundleArgument = context.bundle_argument;
    _BundleArgumentKind = context.bundle_argument_kind;
    _BundleOperation = context.bundle_operation;
    _BundleDimensions = context.bundle_dimensions;
    _BundleDimensionPresent = context.bundle_dimension_present;
    _BundleScalarBindings = context.bundle_scalar_bindings;
    _BundleTileBindings = context.bundle_tile_bindings;
    _BundleSharedBindings = context.bundle_shared_bindings;
    _BundleRangeGroup = context.bundle_range_group;
    _BundleZeroParticipationSeen = context.bundle_zero_participation_seen;
    _BundleControlAttributes = context.bundle_control_attributes;
    _BundleDataAttributes = context.bundle_data_attributes;
    _BundleDataAttributesPresent = context.bundle_data_attributes_present;
    _BundleExecutionMask = context.bundle_execution_mask;
    _BundleHint = context.bundle_hint;
    _BundleFixedPointAttributes = context.bundle_fixed_point_attributes;
    _MemoryCopyTemplate = context.memory_copy_template;
    _FrameTemplate = context.frame_template;
    _BundleExecutionDomainToken = context.bundle_execution_domain_token;
    _FrameDepth = context.frame_depth;
    _LastFrameBegin = context.last_frame_begin;
    _LastFrameEnd = context.last_frame_end;
    _LastFrameSize = context.last_frame_size;
    _LastQueueLeft = context.last_queue_left;
    _LastQueueRight = context.last_queue_right;
    _LastQueueFlags = context.last_queue_flags;
    _LastMemoryCommandAddress = context.last_memory_command_address;
    _LastMemoryCommandSize = context.last_memory_command_size;
    _LastCrossBlockACR = context.last_cross_block_acr;
    _LastCrossBlockID = context.last_cross_block_id;
    _LastBundleHintPayload = context.last_bundle_hint_payload;
    _ReturnAddress = context.return_address;
    _CommitArgument = context.commit_argument;
    _PredicateRegisters = context.predicates;
    _LastFault = context.last_fault;
    _FaultAddress = context.fault_address;
    _ReservationValid = context.reservation_valid;
    _ReservationAddress = context.reservation_address;
    _ReservationSize = context.reservation_size;
    _LastFencePredecessor = context.last_fence_predecessor;
    _LastFenceSuccessor = context.last_fence_successor;
    _MemoryReplayState = context.memory_replay_state;
    _SystemRegisters.thread_ptr = context.thread_ptr;
    _SystemRegisters.global_ptr = context.global_ptr;
    _SystemRegisters.core_state = context.core_state;
    _ExtendedSystemRegisters = context.extended_system_registers;
    _ACRTrapAsynchronous = context.acr_trap_asynchronous;
    _ACRTrapArgumentValid = context.acr_trap_argument_valid;
    _ACRTrapCause = context.acr_trap_cause;
    _ACRTrapNumber = context.acr_trap_number;
    _ACRTrapArgument0 = context.acr_trap_argument0;
    _TrapContexts = context.trap_contexts;
    _CurrentACR = context.current_acr;
    _CurrentMemoryOrigin = context.memory_origin;
    _CurrentProgramOrder = context.program_order;
    _ScalarExecutionBlocked = context.scalar_execution_blocked;
end;

func SaveSelectedCoreExecutionContext()
begin
    let core = _CurrentModelCore;
    _CoreExecutionContexts[[core]] = CoreExecutionContext {
        system_registers = _SystemRegisters,
        shared_tiles = _SharedTiles,
        local_generations = _LocalGenerations,
        shared_generations = _SharedGenerations,
        tile_data_layout_capabilities = _TileDataLayoutCapabilities,
        data_cache_epoch = _DataCacheEpoch,
        instruction_cache_epoch = _InstructionCacheEpoch,
        bundle_cache_epoch = _BundleCacheEpoch,
        tlb_epoch = _TLBEpoch,
        last_maintenance_operation = _LastMaintenanceOperation,
        last_maintenance_operand = _LastMaintenanceOperand,
        bundle_hint_epoch = _BundleHintEpoch,
        architecture_request_epoch = _ArchitectureRequestEpoch,
        last_control_request = _LastControlRequest,
        control_request_operand = _ControlRequestOperand
    };
    _CoreContextBankValid[core] = '1';
    _CurrentCoreContextValid = TRUE;
end;

func LoadCoreExecutionContext(context: CoreExecutionContext)
begin
    _SystemRegisters = context.system_registers;
    _SharedTiles = context.shared_tiles;
    _LocalGenerations = context.local_generations;
    _SharedGenerations = context.shared_generations;
    _TileDataLayoutCapabilities = context.tile_data_layout_capabilities;
    _DataCacheEpoch = context.data_cache_epoch;
    _InstructionCacheEpoch = context.instruction_cache_epoch;
    _BundleCacheEpoch = context.bundle_cache_epoch;
    _TLBEpoch = context.tlb_epoch;
    _LastMaintenanceOperation = context.last_maintenance_operation;
    _LastMaintenanceOperand = context.last_maintenance_operand;
    _BundleHintEpoch = context.bundle_hint_epoch;
    _ArchitectureRequestEpoch = context.architecture_request_epoch;
    _LastControlRequest = context.last_control_request;
    _ControlRequestOperand = context.control_request_operand;
end;

func SelectExecutionContext(core: PTOModelCoreIdentity, pe: MemoryAgentId)
begin
    if !_CurrentCoreContextValid then
        _DefaultCoreExecutionContext = CoreExecutionContext {
            system_registers = _SystemRegisters,
            shared_tiles = _SharedTiles,
            local_generations = _LocalGenerations,
            shared_generations = _SharedGenerations,
            tile_data_layout_capabilities = _TileDataLayoutCapabilities,
            data_cache_epoch = _DataCacheEpoch,
            instruction_cache_epoch = _InstructionCacheEpoch,
            bundle_cache_epoch = _BundleCacheEpoch,
            tlb_epoch = _TLBEpoch,
            last_maintenance_operation = _LastMaintenanceOperation,
            last_maintenance_operand = _LastMaintenanceOperand,
            bundle_hint_epoch = _BundleHintEpoch,
            architecture_request_epoch = _ArchitectureRequestEpoch,
            last_control_request = _LastControlRequest,
            control_request_operand = _ControlRequestOperand
        };
        _CurrentCoreContextValid = TRUE;
    end;
    if !_CurrentPEContextValid then
        _DefaultPEExecutionContext = PEExecutionContext {
            pc = _PC, bpc = _BPC,
            current_encoded_instruction = _CurrentEncodedInstruction,
            bundle_start_encoded_instruction = _BundleStartEncodedInstruction,
            tiles = _Tiles,
            tile_allocation_masks = _TileAllocationMasks,
            tile_payload_live_masks = _TilePayloadLiveMasks,
            tile_payload_generations = _TilePayloadGenerations,
            tile_relative_order = _TileRelativeOrder,
            tile_relative_valid = _TileRelativeValid,
            tile_feature_map_descriptors = _TileFeatureMapDescriptors,
            thread_ptr = _SystemRegisters.thread_ptr,
            global_ptr = _SystemRegisters.global_ptr,
            core_state = _SystemRegisters.core_state,
            t_queue = _TQueue, t_queue_valid = _TQueueValid,
            u_queue = _UQueue, u_queue_valid = _UQueueValid,
            bundle_active = _BundleActive,
            bundle_body_active = _BundleBodyActive, barg = _BARG,
            bundle_commit_target_set = _BundleCommitTargetSet,
            bundle_condition_set = _BundleConditionSet,
            system_block_terminal_pending = _SystemBlockTerminalPending,
            bundle_sequential_pc = _BundleSequentialPC,
            frame_stack_return_target = _FrameStackReturnTarget,
            bundle_argument = _BundleArgument,
            bundle_argument_kind = _BundleArgumentKind,
            bundle_operation = _BundleOperation,
            bundle_dimensions = _BundleDimensions,
            bundle_dimension_present = _BundleDimensionPresent,
            bundle_scalar_bindings = _BundleScalarBindings,
            bundle_tile_bindings = _BundleTileBindings,
            bundle_shared_bindings = _BundleSharedBindings,
            bundle_range_group = _BundleRangeGroup,
            bundle_zero_participation_seen = _BundleZeroParticipationSeen,
            bundle_control_attributes = _BundleControlAttributes,
            bundle_data_attributes = _BundleDataAttributes,
            bundle_data_attributes_present = _BundleDataAttributesPresent,
            bundle_execution_mask = _BundleExecutionMask,
            bundle_hint = _BundleHint,
            bundle_fixed_point_attributes = _BundleFixedPointAttributes,
            memory_copy_template = _MemoryCopyTemplate,
            frame_template = _FrameTemplate,
            bundle_execution_domain_token = _BundleExecutionDomainToken,
            frame_depth = _FrameDepth,
            last_frame_begin = _LastFrameBegin,
            last_frame_end = _LastFrameEnd,
            last_frame_size = _LastFrameSize,
            last_queue_left = _LastQueueLeft,
            last_queue_right = _LastQueueRight,
            last_queue_flags = _LastQueueFlags,
            last_memory_command_address = _LastMemoryCommandAddress,
            last_memory_command_size = _LastMemoryCommandSize,
            last_cross_block_acr = _LastCrossBlockACR,
            last_cross_block_id = _LastCrossBlockID,
            last_bundle_hint_payload = _LastBundleHintPayload,
            return_address = _ReturnAddress,
            commit_argument = _CommitArgument,
            predicates = _PredicateRegisters,
            last_fault = _LastFault, fault_address = _FaultAddress,
            reservation_valid = _ReservationValid,
            reservation_address = _ReservationAddress,
            reservation_size = _ReservationSize,
            last_fence_predecessor = _LastFencePredecessor,
            last_fence_successor = _LastFenceSuccessor,
            memory_replay_state = _MemoryReplayState,
            extended_system_registers = _ExtendedSystemRegisters,
            acr_trap_asynchronous = _ACRTrapAsynchronous,
            acr_trap_argument_valid = _ACRTrapArgumentValid,
            acr_trap_cause = _ACRTrapCause,
            acr_trap_number = _ACRTrapNumber,
            acr_trap_argument0 = _ACRTrapArgument0,
            trap_contexts = _TrapContexts,
            current_acr = _CurrentACR,
            memory_origin = _CurrentMemoryOrigin,
            program_order = _CurrentProgramOrder,
            scalar_execution_blocked = _ScalarExecutionBlocked
        };
        _CurrentPEContextValid = TRUE;
    end;

    if core == _CurrentModelCore && pe == _CurrentMemoryAgent &&
       _CurrentPEContextValid then
        _CurrentKernelInvocation = _KernelInvocationByCore[[core]];
        return;
    end;

    if core != _CurrentModelCore then
        SaveSelectedPEExecutionContext();
        SaveSelectedCoreExecutionContext();
        _CurrentModelCore = core;
        if _CoreContextBankValid[core] == '1' then
            LoadCoreExecutionContext(_CoreExecutionContexts[[core]]);
        else
            LoadCoreExecutionContext(_DefaultCoreExecutionContext);
        end;
        _CurrentCoreContextValid = TRUE;
        _CurrentPEContextValid = FALSE;
    elsif pe != _CurrentMemoryAgent then
        SaveSelectedPEExecutionContext();
    end;

    _CurrentMemoryAgent = pe;
    _CurrentKernelInvocation = _KernelInvocationByCore[[core]];
    if _PEContextBankValid[[core]][pe] == '1' then
        LoadPEExecutionContext(_PEExecutionContexts[[core]][[pe]]);
    else
        LoadPEExecutionContext(_DefaultPEExecutionContext);
    end;
    _CurrentProgramOrder = _PEProgramOrder[[core]][[pe]];
    _CurrentCollectiveEpoch = _PECollectiveEpoch[[core]][[pe]];
    _CurrentPEContextValid = TRUE;
end;

func ResetPEExecutionContextBank()
begin
    _CurrentModelCore = 0;
    _CurrentMemoryAgent = 0;
    _CurrentMemoryOrigin = MemoryEventOrigin_NonKernel;
    _CurrentKernelInvocation = 0;
    _CurrentProgramOrder = 0;
    _CurrentCollectiveEpoch = 0;
    _CurrentPEContextValid = FALSE;
    _CurrentCoreContextValid = FALSE;
    for core = 0 to PTO_MODEL_CORE_INSTANCES - 1 do
        _PEContextBankValid[[core]] = Zeros{PTO_MODEL_MEMORY_AGENTS};
    end;
    _CoreContextBankValid = Zeros{PTO_MODEL_CORE_INSTANCES};
end;
```
<!-- GENERATED-ASL-END: unit -->
