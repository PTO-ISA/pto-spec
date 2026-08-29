<!-- GENERATED FROM: asl/arch/profile/reset.asl -->
# Reset

**Normative ASL source:** `asl/arch/profile/reset.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-RESET}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-profile-reset-purpose role=purpose-scope -->
## 用途与范围

`ResetProfileState` 构造 PTO v0 参考配置档的完整初始状态。它在一个显式过程中重置标量、队列、谓词、内存、Tile、指令束、维护、陷阱上下文、系统寄存器和 ACR 状态。

<!-- PTO-READER-BLOCK: arch-profile-reset-concepts role=concepts-state -->
## 主要重置组

- 每个 PE GPR、临时队列条目、`_PredicateRegisters` 后备条目和模型内存字节都被清零。
- Local 与 Shared Tile 描述符被置为无效；分配、发布、已定义性、几何形状和立方体存储字段被重置。
- 程序计数器、指令束状态、预留状态、事件捕获、缓存代次、维护记录和控制请求回到已定义初值。
- 每个保存的陷阱上下文都被置为无效。部分后备字段会被赋予重置值，但这些赋值不会使无效上下文中的载荷具有含义。

<!-- PTO-READER-BLOCK: arch-profile-reset-rules role=rules-interactions -->
## 配置档专属初始化

每个 ACR 寄存器组中低索引 `0x0f00` 到 `0x0fb7` 的上下文族扩展寄存器都被清零。随后 PTO v0 在低索引 `0x0f07` 写入 `3`，启用外部中断和定时器中断收集。系统标识字段包括版本 `1` 和 Tile 容量 `PTO_MODEL_MAX_TILE_CAPACITY_BYTES`。

<!-- PTO-READER-BLOCK: arch-profile-reset-boundaries role=boundaries -->
## 完成边界

该过程在调用 `ClearFault` 前选择当前 ACR `0`，因此最终故障报告字段在该 ACR 层级中被清除。解码器生成状态和依赖的重置辅助函数属于已声明所有权链；本页不会推断该链中未出现的重置值。

<!-- PTO-READER-BLOCK: arch-profile-reset-example role=example-usage -->
## 非规范验证示例

本示例块只用于帮助阅读：先应用上文规则，再到规范 ASL 所有者中确认结果。它不会增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-profile-reset-related role=related-owners-navigation -->
## 相关所有者

- 谓词访问辅助函数拥有包括 `P0` 规则在内的可见读取行为；此处重置只初始化后备存储。
- Tile 特性图描述符、内存事件、指令束控制和陷阱上下文单元提供此处使用的专用重置辅助函数。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/reset.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-RESET","surface":"arch","classification":["profile","reset"],"depends_on":["generated:decoders","PTO-ARCH-SYSTEM-REGISTERS-MAINTENANCE","PTO-TILE-MODEL-STATE-FEATURE-MAP-DESCRIPTORS","PTO-ARCH-STATE-FUNCTIONAL-MODEL"]}
// PTO-REQ-PROFILE-001: concrete PTO v0 reference profile for every registered
// numeric, memory, time, reset, and access-control-ring boundary.

implementation func ResetProfileState()
begin
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
        _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
        _Tiles[[index]].defined_valid_elements = 0;
        _Tiles[[index]].packed_defined_elements =
            ZeroPackedTileDefinedElements();
        _Tiles[[index]].capacity_bytes = 0;
        _Tiles[[index]].rows = 0;
        _Tiles[[index]].columns = 0;
        _Tiles[[index]].valid_rows = 0;
        _Tiles[[index]].valid_columns = 0;
        _Tiles[[index]].data_type = TileDataType_U64;
        _Tiles[[index]].layout = TileLayout_RowMajor;
        _Tiles[[index]].location = TileLocation_Any;
        _Tiles[[index]].cube_k_repeat = 0;
        _Tiles[[index]].cube_n_repeat = 0;
        _Tiles[[index]].cube_cell_count = 0;
        _Tiles[[index]].cube_storage_bytes = 0;
    end;
    for index = 0 to PTO_SHARED_TILE_COUNT - 1 do
        _SharedTiles[[index]].descriptor_valid = FALSE;
        _SharedTiles[[index]].allocation_mask = Zeros{4};
        _SharedTiles[[index]].initialized_mask = Zeros{4};
        _SharedTiles[[index]].published = FALSE;
        _SharedTiles[[index]].tile.allocated = FALSE;
        _SharedTiles[[index]].tile.contents_defined = FALSE;
        _SharedTiles[[index]].tile.defined_elements =
            Zeros{PTO_MODEL_TILE_ELEMENTS};
        _SharedTiles[[index]].tile.defined_valid_elements = 0;
        _SharedTiles[[index]].tile.packed_defined_elements =
            ZeroPackedTileDefinedElements();
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
    ResetFunctionalModelState();
end;
```
<!-- GENERATED-ASL-END: unit -->
