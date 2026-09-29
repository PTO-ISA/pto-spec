<!-- GENERATED FROM: asl/block/model/commit/effects.asl -->
# Effects

**Normative ASL source:** `asl/block/model/commit/effects.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-COMMIT-EFFECTS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-commit-effects-purpose role=purpose-scope -->
## 用途与范围

本单元保存独立 block 命令的效果例程。这些命令直接作用于内存、队列或控制状态，而不是配置指令束。它们包括队列管理命令（`HL.QMT`、`HL.QPOP`、`HL.QPUSH`）、内存命令（`MCOPY`、`MSET`）以及跨 block 转移状态例程。

<!-- PTO-READER-BLOCK: block-model-commit-effects-concepts role=concepts-state -->
## 概念与可见状态

- 队列管理例程调用通用队列管理器（GQM），并把结果写入标量目标（`HL.QPOP` 写入两个）。它们还把地址、第二操作数和标志分别记录到 `_LastQueueLeft`、`_LastQueueRight` 和 `_LastQueueFlags`。
- `MCOPY` 使用 `_MemoryCopyTemplate`：一个活动标志、指令 PC、目标、源和长度的快照，以及 `progress`，即第一个尚未复制的字节。
- `MSET` 用其值操作数的低字节填充一个范围。
- 成功的 `MCOPY` 和 `MSET` 会记录 `_LastMemoryCommandAddress` 和 `_LastMemoryCommandSize`。

<!-- PTO-READER-BLOCK: block-model-commit-effects-rules role=rules-interactions -->
## 规则与交互

`HL.QMT` 的标志位从高到低依次为 initialize、event、suspend 和 restore。initialize 用第二操作数位 `9:0` 中的容量创建一个队列，并返回 `capacity * 8`，状态为 `00`。没有 initialize 时，已知且未损坏的队列返回其剩余计数；否则状态为 `01`。event，以及随后的 suspend 或 restore，只在主操作成功后运行。命令分派器在本例程运行之前，以 `Fault_IllegalInstruction` 拒绝同时设置 suspend 和 restore。

`MCOPY` 以 `Fault_IllegalInstruction` 拒绝回绕的范围，或相互重叠的非空源范围与目标范围。随后它按 8、4、2 或 1 字节的步长向前复制，每次使用不超过剩余长度的最大步长。`MSET` 以 `Fault_IllegalInstruction` 拒绝回绕的范围，并以 `Fault_DataPage` 拒绝超过 262144 字节或超过模型内存大小的长度。随后它在一次存储中探测并填充整个范围。

设计要点：`MCOPY` 的每一步都在读取源之前同时探测源和目标。ASL 注释给出了原因：这样被拒绝的目标不会留下任何源读取或内存事件。

设计要点：`MCOPY` 可以按步粒度重新启动。发生故障的步骤不会推进 `progress`，模板会保留在陷阱上下文中。同一条指令再次运行时，它复用这些快照并从 `progress` 处恢复，因此已提交的字节不会被复制两次。只有当模板记录的 PC 与当前 `TPC` 匹配时，才会复用该模板。

设计要点：重叠范围在第一步之前就被拒绝。因此，逐步向前复制永远不会读取同一次复制中较早步骤写入的字节，目标总是收到原始的源字节。

<!-- PTO-READER-BLOCK: block-model-commit-effects-boundaries role=boundaries -->
## 架构边界

这些例程不属于 [validation](validation.md) 中的指令束提交路径。它们由各自的命令执行。

`ExecuteCrossBlockTransferState` 本会记录一个 ACR 和 block ID，并把 `BARG` 转移设为 `Indirect`。PTO 永远不会到达它：`CommandHandlerSupported` 对跨 block 处理程序返回 false，因此 `XB` 会先引发 `Fault_IllegalInstruction`。

队列语义，包括 push 和 pop 的结果，由 GQM 单元拥有。

<!-- PTO-READER-BLOCK: block-model-commit-effects-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

长度为 13 字节的 `MCOPY` 先复制 8 字节，再复制 4 字节，最后复制 1 字节。如果 4 字节的步骤在其目标上发生故障，`progress` 保持为 8，该步骤的任何字节都不会被读取或写入。重试时复制字节 8 到 11，然后复制字节 12。

<!-- PTO-READER-BLOCK: block-model-commit-effects-related role=related-owners-navigation -->
## 相关所有者

- [MCOPY](../../lifecycle/MCOPY.md) 和 [MSET](../../lifecycle/MSET.md) 是内存命令页面。
- [HL.QMT](../../lifecycle/HL.QMT.md)、[HL.QPOP](../../lifecycle/HL.QPOP.md) 和 [HL.QPUSH](../../lifecycle/HL.QPUSH.md) 是队列命令页面。
- [通用队列管理](../../../arch/programming-model/general-queue-management.md)拥有队列行为。
- [XB](../../encoding/XB.md) 是被拒绝的跨 block 编码。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/commit/effects.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-COMMIT-EFFECTS","surface":"block","classification":["model","commit","effects"],"depends_on":["PTO-BLOCK-MODEL-LIFECYCLE-LIFETIME","PTO-ARCH-GQM"]}
func ExecuteQueueManagerMove(destination: Reg5Selector,
                             address: Word,
                             capacity_source: Word,
                             flags: bits(4))
begin
    let initialize = flags[3] == '1';
    let notify_event = flags[2] == '1';
    let suspend = flags[1] == '1';
    let restore = flags[0] == '1';
    var result = GQMResult(0, '01');
    var succeeded = FALSE;

    if initialize then
        let capacity = UInt(capacity_source[9:0]) as GQMQueueCapacity;
        - = InitializeGQMQueue(address, capacity);
        result = GQMResult((capacity * 8) as integer {0..8191}, '00');
        succeeded = TRUE;
    else
        let found = FindGQMQueue(address);
        if found != PTO_MODEL_GQM_QUEUE_SLOTS then
            let slot = found as GQMQueueSlot;
            if !_GQMQueueCorrupt[[slot]] then
                result = GQMResult(GQMQueueRemaining(address), '00');
                succeeded = TRUE;
            end;
        end;
    end;

    if succeeded then
        // Combined controls execute after the primary operation, in encoded
        // architectural order: event first, then suspension or restoration.
        if notify_event then
            BroadcastGQMEvent(address);
        end;
        if suspend then
            SetGQMQueueSuspended(address, TRUE);
        elsif restore then
            SetGQMQueueSuspended(address, FALSE);
        end;
    end;

    _LastQueueLeft = address;
    _LastQueueRight = capacity_source;
    _LastQueueFlags = flags;
    WriteScalarDestination(destination, result);
end;

func ExecuteQueueManagerPop(destination0: Reg5Selector,
                            destination1: Reg5Selector,
                            address: Word,
                            flags: bits(4))
begin
    let notify_event = flags[1] == '1';
    let relaxed = flags[0] == '1';
    let response = PopGQMQueueEntry(
        address,
        relaxed,
        notify_event);

    _LastQueueLeft = address;
    _LastQueueRight = Zeros{PTO_XLEN};
    _LastQueueFlags = flags;
    WriteScalarDestination(destination0, response.data);
    WriteScalarDestination(destination1, response.result);
end;

func ExecuteQueueManagerPush(destination: Reg5Selector,
                             address: Word,
                             entry: Word,
                             flags: bits(4))
begin
    let at_head = flags[3] == '1';
    let notify_event = flags[2] == '1';
    let relaxed = flags[0] == '1';
    let result = PushGQMQueueEntry(
        address,
        entry,
        at_head,
        relaxed,
        notify_event);

    _LastQueueLeft = address;
    _LastQueueRight = entry;
    _LastQueueFlags = flags;
    WriteScalarDestination(destination, result);
end;

pure func MemoryRangeWraps(address: Word, length: Word) => boolean
begin
    if length == Zeros{PTO_XLEN} then
        return FALSE;
    end;
    let end_address = address + length;
    return UInt(end_address) < UInt(address);
end;

pure func MemoryCopyRangesOverlap(destination: Word,
                                  source: Word,
                                  length: Word) => boolean
begin
    if length == Zeros{PTO_XLEN} then
        return FALSE;
    end;
    let destination_end = destination + length;
    let source_end = source + length;
    return UInt(destination) < UInt(source_end) &&
           UInt(source) < UInt(destination_end);
end;

pure func MemoryCopyStepSize(remaining: Word) => integer {1,2,4,8}
begin
    assert remaining != Zeros{PTO_XLEN};
    if UInt(remaining) >= 8 then
        return 8;
    elsif UInt(remaining) >= 4 then
        return 4;
    elsif UInt(remaining) >= 2 then
        return 2;
    else
        return 1;
    end;
end;

func StartMemoryCopyTemplate(destination: Word,
                             source: Word,
                             length: Word) => boolean
begin
    if MemoryRangeWraps(destination, length) ||
       MemoryRangeWraps(source, length) ||
       MemoryCopyRangesOverlap(destination, source, length) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;

    _MemoryCopyTemplate.active = TRUE;
    _MemoryCopyTemplate.instruction_pc = ReadTPC();
    _MemoryCopyTemplate.destination = destination;
    _MemoryCopyTemplate.source = source;
    _MemoryCopyTemplate.length = length;
    _MemoryCopyTemplate.progress = Zeros{PTO_XLEN};
    return TRUE;
end;

func CompleteMemoryCopyTemplate()
begin
    _LastMemoryCommandAddress = _MemoryCopyTemplate.destination;
    _LastMemoryCommandSize = _MemoryCopyTemplate.length;
    _MemoryCopyTemplate.active = FALSE;
end;

func ExecuteMemoryCopyStep()
begin
    let progress = _MemoryCopyTemplate.progress;
    let remaining = _MemoryCopyTemplate.length - progress;
    let step_size = MemoryCopyStepSize(remaining);
    let step_word = NaturalToWord(
        step_size as integer {0..262144});
    let source_address = _MemoryCopyTemplate.source + progress;
    let destination_address = _MemoryCopyTemplate.destination + progress;

    // Both accesses are probed before the source value is observed.  A
    // rejected destination therefore cannot leave a source read or event.
    let source_probe = ProbeDataAccess(
        source_address,
        step_size,
        1,
        FALSE);
    let destination_probe = ProbeDataAccess(
        destination_address,
        step_size,
        1,
        TRUE);
    if RaiseDataAccessFault(source_probe, source_address) then
        return;
    elsif RaiseDataAccessFault(destination_probe, destination_address) then
        return;
    end;

    let value = LoadTranslatedUnsigned(
        source_probe.translated_address,
        step_size);
    RecordLoadEvent(
        source_probe.translated_address,
        step_size,
        value,
        MemoryOrder_Relaxed);
    StoreTranslated(
        destination_address,
        destination_probe.translated_address,
        step_size,
        value);
    RecordStoreEvent(
        destination_probe.translated_address,
        step_size,
        value,
        MemoryOrder_Relaxed);
    _MemoryCopyTemplate.progress = progress + step_word;
end;

func ExecuteMemoryCopyTemplate(destination: Word,
                               source: Word,
                               length: Word)
begin
    if !_MemoryCopyTemplate.active then
        if !StartMemoryCopyTemplate(destination, source, length) then
            return;
        end;
    end;

    if _MemoryCopyTemplate.instruction_pc != ReadTPC() then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;

    for step = 0 to PTO_MODEL_MEMORY_BYTES - 1
        looplimit PTO_MODEL_MEMORY_BYTES do
        if _MemoryCopyTemplate.active &&
           _LastFault == Fault_None then
            if _MemoryCopyTemplate.progress ==
               _MemoryCopyTemplate.length then
                CompleteMemoryCopyTemplate();
            else
                ExecuteMemoryCopyStep();
            end;
        end;
    end;

    if _MemoryCopyTemplate.active &&
       _LastFault == Fault_None &&
       _MemoryCopyTemplate.progress == _MemoryCopyTemplate.length then
        CompleteMemoryCopyTemplate();
    end;
end;

func ExecuteMemorySet(destination: Word, value: Word, length: Word)
begin
    if MemoryRangeWraps(destination, length) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;

    if UInt(length) > 262144 ||
       UInt(length) > PTO_MODEL_MEMORY_BYTES then
        SetFault(Fault_DataPage, destination);
        return;
    end;

    let byte_count = UInt(length) as integer {0..262144};
    if byte_count != 0 then
        let access_size = byte_count as integer {1..262144};
        let write_probe = ProbeDataAccess(destination, access_size, 1, TRUE);
        if RaiseDataAccessFault(write_probe, destination) then
            return;
        else
            StoreTranslatedFillModelBounded(
                destination,
                write_probe.translated_address,
                byte_count as integer {1..262144},
                value[7:0]);
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
    _BARG.transfer_type = BundleTransfer_Indirect;
end;
```
<!-- GENERATED-ASL-END: unit -->
