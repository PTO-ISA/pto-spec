<!-- GENERATED FROM: asl/arch/system-registers/addressing.asl -->
# Addressing

**Normative ASL source:** `asl/arch/system-registers/addressing.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-system-addressing-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit owns three things: the base system-register record type, the single instance of that record for the current core, and the reset function that installs the reference-profile values.

The record holds the registers that address decoding treats as base registers, so a reader can see every field, its reset value, and whether software may write it in one place. Cross-ACR context registers, the 24-bit address decode, and the side effects of individual control registers are other owners.

<!-- PTO-READER-BLOCK: arch-system-addressing-concepts-state role=concepts-state -->
## Base system-register state

`BaseSystemRegisterState` is a record of thirteen `Word` fields: `thread_ptr`, `global_ptr`, `core_state`, `core_id`, `thread_id`, `vendor`, `version`, `core_feature`, `core_feature_enable`, `tile_capacity`, `blocknum`, `blockid`, and `cycle`.

| Field | Reset value | Software writable |
| --- | --- | --- |
| `thread_ptr` | zero | yes |
| `global_ptr` | zero | yes |
| `core_state` | zero | yes |
| `core_id` | zero | no |
| `thread_id` | zero | no |
| `vendor` | zero | no |
| `version` | one | no |
| `core_feature` | zero | no |
| `core_feature_enable` | zero | yes |
| `tile_capacity` | `PTO_MODEL_MAX_TILE_CAPACITY_BYTES` | no |
| `blocknum` | zero | no |
| `blockid` | zero | no |
| `cycle` | zero | no |

The architecture-visible owner is the variable `_SystemRegisters`, declared as `PTO-STATE-ARCH-SYSTEM-REGISTERS` with members `_SystemRegisters`.

<!-- PTO-READER-BLOCK: arch-system-addressing-rules-interactions role=rules-interactions -->
## What reset installs

`ResetProfileState` writes every field of this record explicitly. It resets every ACR bank rather than only the current one, then sets `_CurrentACR` to ACR0 and calls `ClearFault` for that ring, so a reset execution cannot inherit archived state from a ring that was formerly current.

The function also carries the rest of the reference reset, including general-purpose registers, temporary queues, predicate registers, model memory, tile and shared-tile descriptors, descriptor-valid and definedness fields, reservation state, bundle-control state, memory-execution state, and the trap contexts of every ACR.

Design point: each field is written even when its reset value is zero, so the post-reset value of `version` is one and of `tile_capacity` is `PTO_MODEL_MAX_TILE_CAPACITY_BYTES` instead of depending on an unstated initial state. A reader can compare a running core against this list without asking which fields a particular profile happened to initialize.

<!-- PTO-READER-BLOCK: arch-system-addressing-boundaries role=boundaries -->
## Architectural boundaries

`cycle` is the architectural time value. This owner resets it and never increments it; a separate execution path advances the counter once per decoded execution attempt, so the reset baseline is zero and the value grows from there.

A write to `core_state` also selects the current ACR, and a read of the interrupt pending bitmap or of the top pending interrupt runs the timer refresh that the timer owner defines.

Design point: the reset body clears the context-register low-index range in all sixteen rings and then stores the interrupt configuration value, so a bank that was active before reset cannot carry pending bits, trap arguments, or enable bits into the next execution.

<!-- PTO-READER-BLOCK: arch-system-addressing-example-usage role=example-usage -->
## Non-normative reset reading example

After `ResetProfileState`, reading the base registers gives `version` one, `tile_capacity` equal to `PTO_MODEL_MAX_TILE_CAPACITY_BYTES`, `cycle` zero, and the current ACR ACR0. The fields `core_id`, `vendor`, `thread_id`, `blocknum`, and `blockid` read zero because reset writes zero and software cannot write them.

Reading low index `0x0f07` of ACR1 gives 3, and reading `0x0f08` and `0x0f09` of ACR1 gives zero.

<!-- PTO-READER-BLOCK: arch-system-addressing-related-owners role=related-owners-navigation -->
## Related owners

- [Trap-context record](../data-types/trap-context.md) is the declared dependency; the reset body initializes one context per ACR.
- [Context registers](context.md) maps a ring number and a low index into the extended register file.
- [Numeric status](../state/numeric-status.md) reads the `core_state` field owned here.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/system-registers/addressing.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING","surface":"arch","classification":["system-registers","addressing"],"depends_on":["PTO-ARCH-DATA-TYPES-TRAP-CONTEXT"]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-SYSTEM-REGISTERS","classification":["architecture","system-registers"],"scope":"system","owner":"PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING","members":["_SystemRegisters"],"depends_on":[]}
type BaseSystemRegisterState of record {
    thread_ptr: Word,
    global_ptr: Word,
    core_state: Word,
    core_id: Word,
    thread_id: Word,
    vendor: Word,
    version: Word,
    core_feature: Word,
    core_feature_enable: Word,
    tile_capacity: Word,
    blocknum: Word,
    blockid: Word,
    cycle: Word
};

var _SystemRegisters : BaseSystemRegisterState;

func ResetProfileState()
begin
    let zero_tile_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        for index = 0 to PTO_ABSOLUTE_GPR_COUNT - 1 do
            _PEGPRs[[pe]][[index]] = Zeros{PTO_XLEN};
        end;
    end;
    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        _TQueue[[index]] = Zeros{PTO_XLEN};
        _TQueueValid[[index]] = FALSE;
        _UQueue[[index]] = Zeros{PTO_XLEN};
        _UQueueValid[[index]] = FALSE;
    end;
    ResetGQMState();
    for index = 0 to PTO_PREDICATE_REGISTER_COUNT - 1 do
        _PredicateRegisters[[index]] = Zeros{PTO_PREDICATE_WIDTH};
    end;
    for index = 0 to PTO_MODEL_MEMORY_BYTES - 1 do
        _Memory[[index]] = Zeros{8};
    end;
    // Context-family registers occupy low indices 0xf00..0xfb7 in every ACR
    // bank. The larger array is verification backing for the complete 16-bit
    // banked address domain.
    for ring = 0 to PTO_ACR_COUNT - 1 do
        for low_index = 0x0f00 to 0x0fb7 do
            let index = ((ring * 4096) + low_index)
                as SystemRegisterFileIndex;
            _ExtendedSystemRegisters[[index]] = Zeros{PTO_XLEN};
        end;
        // PTO v0 enables external and timer interrupt collection at reset.
        _ExtendedSystemRegisters[[((ring * 4096) + 0x0f07)
            as SystemRegisterFileIndex]] = Zeros{PTO_XLEN} + 3;
    end;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        _TileFeatureMapDescriptors[[index]].valid = FALSE;
        _TileAllocationMasks[[index]] = Zeros{4};
        _Tiles[[index]].allocated = FALSE;
        _Tiles[[index]].contents_defined = FALSE;
        _Tiles[[index]].defined_elements = zero_tile_elements;
        _Tiles[[index]].defined_valid_elements = 0;
        _Tiles[[index]].packed_defined_elements =
            zero_packed_tile_elements;
        _Tiles[[index]].capacity_bytes = 0;
        _Tiles[[index]].rows = 0;
        _Tiles[[index]].columns = 0;
        _Tiles[[index]].valid_rows = 0;
        _Tiles[[index]].valid_columns = 0;
        _Tiles[[index]].data_type = TileDataType_U64;
        _Tiles[[index]].predicate_basis_type = TileDataType_U64;
        _Tiles[[index]].layout = TileLayout_RowMajor;
        _Tiles[[index]].cube_k_repeat = 0;
        _Tiles[[index]].cube_n_repeat = 0;
        _Tiles[[index]].cube_cell_count = 0;
        _Tiles[[index]].cube_storage_bytes = 0;
    end;
    for hand = 0 to 3 do
        _TileRelativeValid[[hand]] = Zeros{16};
        for distance = 0 to 15 do
            _TileRelativeOrder[[hand]][[distance]] = 0;
        end;
    end;
    for index = 0 to PTO_SHARED_TILE_COUNT - 1 do
        _SharedTiles[[index]].descriptor_valid = FALSE;
        _SharedTiles[[index]].allocation_mask = Zeros{4};
        _SharedTiles[[index]].initialized_mask = Zeros{4};
        _SharedTiles[[index]].published = FALSE;
        _SharedTiles[[index]].tile.allocated = FALSE;
        _SharedTiles[[index]].tile.contents_defined = FALSE;
        _SharedTiles[[index]].tile.defined_elements =
            zero_tile_elements;
        _SharedTiles[[index]].tile.defined_valid_elements = 0;
        _SharedTiles[[index]].tile.packed_defined_elements =
            zero_packed_tile_elements;
        _SharedTiles[[index]].tile.cube_k_repeat = 0;
        _SharedTiles[[index]].tile.cube_n_repeat = 0;
        _SharedTiles[[index]].tile.cube_cell_count = 0;
        _SharedTiles[[index]].tile.cube_storage_bytes = 0;
    end;
    _PC = Zeros{PTO_XLEN};
    _BPC = Zeros{PTO_XLEN};
    _BundleActive = FALSE;
    _BundleBodyActive = FALSE;
    ResetBundleControlState();
    _ReturnAddress = Zeros{PTO_XLEN};
    _CommitArgument = Zeros{PTO_XLEN};
    _ReservationValid = FALSE;
    _ReservationAddress = Zeros{PTO_XLEN};
    _ReservationSize = 1;
    ResetMemoryExecution();
    _MemoryEventCaptureEnabled = FALSE;
    _CurrentMemoryAgent = 0;
    _MemoryReplayState.active = FALSE;
    _MemoryReplayState.request = Zeros{PTO_XLEN};
    _MemoryReplayState.committed_event_count = 0;
    _MemoryReplayState.epoch = 0;
    _LastFencePredecessor = Zeros{4};
    _LastFenceSuccessor = Zeros{4};
    _DataCacheEpoch = 0;
    _InstructionCacheEpoch = 0;
    _BundleCacheEpoch = 0;
    _TLBEpoch = 0;
    _LastMaintenanceOperation = Maintenance_DC_IALL;
    _LastMaintenanceOperand = Zeros{PTO_XLEN};
    _BundleHintEpoch = 0;
    _ArchitectureRequestEpoch = 0;
    _LastControlRequest = ExecutionControl_SendEvent;
    _ControlRequestOperand = Zeros{PTO_XLEN};
    for ring = 0 to PTO_ACR_COUNT - 1 do
        _ACRTrapAsynchronous[[ring]] = FALSE;
        _ACRTrapArgumentValid[[ring]] = FALSE;
        _ACRTrapCause[[ring]] = Zeros{24};
        _ACRTrapNumber[[ring]] = Zeros{6};
        _ACRTrapArgument0[[ring]] = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].valid = FALSE;
        _TrapContexts[[ring]].source_acr = 0;
        _TrapContexts[[ring]].tpc = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].bpc = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].core_state = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].bundle_argument = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].commit_argument = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].return_address = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].bundle_argument_kind = Zeros{3};
        _TrapContexts[[ring]].bundle_active = FALSE;
        _TrapContexts[[ring]].bundle_body_active = FALSE;
        _TrapContexts[[ring]].bundle_commit_target_set = FALSE;
        _TrapContexts[[ring]].bundle_condition_set = FALSE;
        _TrapContexts[[ring]].system_block_terminal_pending = FALSE;
        _TrapContexts[[ring]].bundle_fixed_point_attributes.valid = FALSE;
        _TrapContexts[[ring]].bundle_fixed_point_attributes.pre_quant_mode = Zeros{6};
        _TrapContexts[[ring]].bundle_fixed_point_attributes.relu_mode = Zeros{3};
        _TrapContexts[[ring]].bundle_fixed_point_attributes.group_n_code = Zeros{4};
        _TrapContexts[[ring]].bundle_fixed_point_attributes.row_max_en = FALSE;
        _TrapContexts[[ring]].bundle_fixed_point_attributes.group_max_en = FALSE;
        _TrapContexts[[ring]].bundle_fixed_point_attributes.row_max_init = FALSE;
        _TrapContexts[[ring]].bundle_fixed_point_attributes.max_abs_en = FALSE;
        _TrapContexts[[ring]].bundle_fixed_point_attributes.trans_a = FALSE;
        _TrapContexts[[ring]].bundle_fixed_point_attributes.trans_b = FALSE;
        _TrapContexts[[ring]].bundle_fixed_point_attributes.c_scale_en = FALSE;
        _TrapContexts[[ring]].bundle_range_group = _BundleRangeGroup;
        _TrapContexts[[ring]].memory_copy_template = _MemoryCopyTemplate;
        _TrapContexts[[ring]].frame_template = _FrameTemplate;
        _TrapContexts[[ring]].memory_replay_state.active = FALSE;
        _TrapContexts[[ring]].memory_replay_state.request = Zeros{PTO_XLEN};
        _TrapContexts[[ring]].memory_replay_state.committed_event_count = 0;
        _TrapContexts[[ring]].memory_replay_state.epoch = 0;
        _TrapContexts[[ring]].t_queue = _TQueue;
        _TrapContexts[[ring]].t_queue_valid = _TQueueValid;
        _TrapContexts[[ring]].u_queue = _UQueue;
        _TrapContexts[[ring]].u_queue_valid = _UQueueValid;
        _TrapContexts[[ring]].predicates = _PredicateRegisters;
    end;
    _SystemRegisters.thread_ptr = Zeros{PTO_XLEN};
    _SystemRegisters.global_ptr = Zeros{PTO_XLEN};
    _SystemRegisters.core_state = Zeros{PTO_XLEN};
    _SystemRegisters.core_id = Zeros{PTO_XLEN};
    _SystemRegisters.thread_id = Zeros{PTO_XLEN};
    _SystemRegisters.vendor = Zeros{PTO_XLEN};
    _SystemRegisters.version = Zeros{PTO_XLEN} + 1;
    _SystemRegisters.core_feature = Zeros{PTO_XLEN};
    _SystemRegisters.core_feature_enable = Zeros{PTO_XLEN};
    _SystemRegisters.tile_capacity = Zeros{PTO_XLEN} +
        PTO_MODEL_MAX_TILE_CAPACITY_BYTES;
    _SystemRegisters.blocknum = Zeros{PTO_XLEN};
    _SystemRegisters.blockid = Zeros{PTO_XLEN};
    _SystemRegisters.cycle = Zeros{PTO_XLEN};
    _CurrentACR = 0;
    ClearFault();
end;
```
<!-- GENERATED-ASL-END: unit -->
