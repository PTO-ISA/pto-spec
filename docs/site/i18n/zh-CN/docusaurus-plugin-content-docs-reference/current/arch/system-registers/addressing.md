<!-- GENERATED FROM: asl/arch/system-registers/addressing.asl -->
# Addressing

**Normative ASL source:** `asl/arch/system-registers/addressing.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-system-addressing-purpose-scope role=purpose-scope -->
## 用途与范围

本单元拥有基础系统寄存器状态记录，以及用于初始化架构状态中由配置档拥有的部分的配置档复位钩子。

<!-- PTO-READER-BLOCK: arch-system-addressing-concepts-state role=concepts-state -->
## 基础系统寄存器状态

`BaseSystemRegisterState` 包含 `thread_ptr`、`global_ptr`、`core_state`、`core_id`、`thread_id`、`vendor`、`version`、`core_feature`、`core_feature_enable`、`tile_capacity`、`blocknum`、`blockid` 和 `cycle`，每个字段都表示为 `Word`。

架构可见的所有者是 `_SystemRegisters`，其标识为 `PTO-STATE-ARCH-SYSTEM-REGISTERS`。

<!-- PTO-READER-BLOCK: arch-system-addressing-rules-interactions role=rules-interactions -->
## 配置档复位钩子

`ResetProfileState` 由实现定义，可以由当前活动的具体配置档覆写。本所有者中的默认函数体把 `_CurrentACR` 设为 `0`，并把 `_SystemRegisters.cycle` 清为 `Zeros{PTO_XLEN}`。

<!-- PTO-READER-BLOCK: arch-system-addressing-boundaries role=boundaries -->
## 架构边界

默认函数体不会写入 `BaseSystemRegisterState` 的其他字段。因此，本页不会为所有者未触及的字段指定复位值。

配置档专用的复位行为必须保留在 `ResetProfileState` 钩子后面，不能从某个目标实现推断。

<!-- PTO-READER-BLOCK: arch-system-addressing-example-usage role=example-usage -->
## 非规范复位阅读示例

检查可移植默认行为时，调用 `ResetProfileState` 后应看到 ACR0 和清零的周期计数器。除非另一个当前所有者或活动配置档给出定义，否则应把 `vendor` 或 `tile_capacity` 的值视为本辅助函数未解决的问题。

<!-- PTO-READER-BLOCK: arch-system-addressing-related-owners role=related-owners-navigation -->
## 相关所有者

- [陷阱上下文数据类型](../data-types/trap-context.md)是声明的依赖项。
- [上下文寄存器](context.md)把相对环的上下文寄存器映射到扩展系统寄存器存储。
- [数值状态](../state/numeric-status.md)使用本页拥有的 `core_state` 字段。
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
