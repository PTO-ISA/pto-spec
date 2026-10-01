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

本单元拥有三样东西：基础系统寄存器记录类型、当前核心上该记录的唯一实例，以及安装参考配置档取值的复位函数。

该记录保存地址解码视为基础寄存器的那些寄存器，因此读者可以在一处看到每个字段、它的复位取值，以及软件是否可以写入它。跨 ACR 的上下文寄存器、24 位地址解码以及各个控制寄存器的副作用属于其他所有者。

<!-- PTO-READER-BLOCK: arch-system-addressing-concepts-state role=concepts-state -->
## 基础系统寄存器状态

`BaseSystemRegisterState` 是包含 13 个 `Word` 字段的记录：`thread_ptr`、`global_ptr`、`core_state`、`core_id`、`thread_id`、`vendor`、`version`、`core_feature`、`core_feature_enable`、`tile_capacity`、`blocknum`、`blockid` 和 `cycle`。

| 字段 | 复位取值 | 软件可写 |
| --- | --- | --- |
| `thread_ptr` | 零 | 是 |
| `global_ptr` | 零 | 是 |
| `core_state` | 零 | 是 |
| `core_id` | 零 | 否 |
| `thread_id` | 零 | 否 |
| `vendor` | 零 | 否 |
| `version` | 一 | 否 |
| `core_feature` | 零 | 否 |
| `core_feature_enable` | 零 | 是 |
| `tile_capacity` | `PTO_MODEL_MAX_TILE_CAPACITY_BYTES` | 否 |
| `blocknum` | 零 | 否 |
| `blockid` | 零 | 否 |
| `cycle` | 零 | 否 |

架构可见的所有者是变量 `_SystemRegisters`，其标识为 `PTO-STATE-ARCH-SYSTEM-REGISTERS`，成员为 `_SystemRegisters`。

<!-- PTO-READER-BLOCK: arch-system-addressing-rules-interactions role=rules-interactions -->
## 复位安装了哪些状态

`ResetProfileState` 显式写入本记录的每个字段。它复位每一个 ACR 存储体，而不只是当前存储体，然后把 `_CurrentACR` 设为 ACR0 并为该环调用 `ClearFault`，因此一次复位执行不会从先前的当前环继承归档状态。

该函数还承担参考复位的其余部分，包括通用寄存器、临时队列、谓词寄存器、模型内存、瓦片与共享瓦片描述符、描述符有效位与已定义性字段、预留状态、指令束控制状态、内存执行状态，以及每个 ACR 的陷阱上下文。

设计要点：即使复位取值为零，每个字段也会被写入，因此复位后 `version` 的取值是一、`tile_capacity` 的取值是 `PTO_MODEL_MAX_TILE_CAPACITY_BYTES`，而不依赖某个未被说明的初始状态。读者可以把一个正在运行的核心与这份清单对照，而无需追问某个配置档恰好初始化了哪些字段。

<!-- PTO-READER-BLOCK: arch-system-addressing-boundaries role=boundaries -->
## 架构边界

`cycle` 是架构时间取值。本所有者复位它，也从不递增它；另一条执行路径在每次已解码执行尝试时把计数器加一，因此复位基线是零，取值从那里开始增长。

对 `core_state` 的写入还会选择当前 ACR，而读取待处理位图或最高优先待处理中断会运行定时器所有者定义的定时器刷新。

设计要点：复位函数体清除全部 16 个环中上下文寄存器的低位索引范围，然后存入中断配置取值，因此复位前处于活动状态的存储体无法把待处理位、陷阱参数或使能位带入下一次执行。

<!-- PTO-READER-BLOCK: arch-system-addressing-example-usage role=example-usage -->
## 非规范复位阅读示例

执行 `ResetProfileState` 之后，读取基础寄存器得到：`version` 为一、`tile_capacity` 等于 `PTO_MODEL_MAX_TILE_CAPACITY_BYTES`、`cycle` 为零，并且当前 ACR 为 ACR0。字段 `core_id`、`vendor`、`thread_id`、`blocknum` 和 `blockid` 读为零，因为复位写入零且软件无法写入它们。

读取 ACR1 的低位索引 `0x0f07` 得到 3，而读取 ACR1 的 `0x0f08` 和 `0x0f09` 得到零。

<!-- PTO-READER-BLOCK: arch-system-addressing-related-owners role=related-owners-navigation -->
## 相关所有者

- [陷阱上下文记录](../data-types/trap-context.md)是声明的依赖项；复位函数体为每个 ACR 初始化一个上下文。
- [上下文寄存器](context.md)把环号与低位索引映射到扩展寄存器文件。
- [数值状态](../state/numeric-status.md)读取本页拥有的 `core_state` 字段。
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
