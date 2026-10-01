<!-- GENERATED FROM: asl/arch/programming-model/general-queue-management.asl -->
# General Queue Management

**Normative ASL source:** `asl/arch/programming-model/general-queue-management.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-GQM}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-gqm-purpose-scope role=purpose-scope -->
## 用途与范围

通用队列管理（GQM）提供软件可见的队列，队列条目为 64 位，每个队列由一个 64 位地址标识。程序可以创建队列、压入与弹出条目、暂停或恢复队列，并可在队列操作成功时选择广播事件。`PTO-STATE-ARCH-GQM` 拥有队列表、条目存储、释放与获取纪元，以及事件观测状态。

本单元以辅助函数的形式定义队列行为。`HL.QMT`、`HL.QPUSH` 和 `HL.QPOP` 指令译码其操作数，并通过队列管理器效果函数调用这些辅助函数。

<!-- PTO-READER-BLOCK: arch-gqm-concepts-state role=concepts-state -->
## 队列状态与结果字

每个有效模型槽记录地址、容量、计数、队头、暂停标志、损坏标志和条目数组。每个条目包含一个 `Word` 值和一个释放纪元。

每个操作都在由 `GQMResult` 构造的结果字中报告结果。主值（例如剩余容量或剩余计数）位于位 `12:0`。两位状态位于位 `63:62`，其余位均为零。

| 状态 | 压入 | 弹出 |
| --- | --- | --- |
| `00` | 条目已存入 | 条目已移除 |
| `01` | 队列暂停或已满 | 队列为空 |
| `10` | 队列不存在或已损坏 | 队列不存在或已损坏 |

设计要点：压入与弹出辅助函数在结果字中报告不成功的结果，而不引发故障。软件因此可以检查状态位并重试或退避，队列满或空只是普通结果。

<!-- PTO-READER-BLOCK: arch-gqm-rules-interactions role=rules-interactions -->
## 压入、弹出与通知

`PushGQMQueueEntry` 拒绝不存在或损坏的队列；对于暂停或已满的队列，它返回剩余容量；否则根据 `at_head` 在队头或队尾插入。存储是环形的：队头插入把队头后退一个槽位，并回绕到最后一个槽位；队尾插入写入最后一个条目之后的槽位。

`PopGQMQueueEntry` 对不存在或损坏的队列返回零数据和状态 `10`，对空队列返回状态 `01`。否则它移除队头条目，并返回其值和剩余计数。移除最后一个条目时，队头复位为零。

设计要点：释放纪元与获取纪元把一次弹出与产生该条目的压入联系起来。非宽松压入会递增 `_GQMReleaseEpoch` 并把新值存入条目；宽松压入存入纪元 `0`。非宽松弹出把条目中非零的纪元复制到 `_LastGQMAcquireEpoch`，因此该字段指明最近一次被非宽松弹出消费其条目的非宽松压入。宽松的压入或弹出不留下这种联系。

当成功压入或弹出的 `notify_event` 为真时，`BroadcastGQMEvent` 递增 `_GQMEventEpoch`，并在 `_LastGQMEventAddress` 中记录队列地址。

<!-- PTO-READER-BLOCK: arch-gqm-boundaries role=boundaries -->
## 容量与模型边界

单个队列的容量范围为 `0` 到 `1023`。`PTO_MODEL_GQM_QUEUE_SLOTS` 可配置为 `1` 到 `16`，默认值为 `4`；但所有者明确把它当作可执行验证的后备容量，而不是已初始化队列数量的架构限制。

初始化会复用相同地址的现有槽，或者选择第一个空闲槽。可执行配置档必须为其工作负载提供足够的模型槽；槽耗尽会触发断言，而不是定义一个可移植的队列数量失败结果。

设计要点：压入与弹出对被标记为损坏的队列的处理与不存在的队列完全相同：两者都返回状态 `10`，且不改变任何队列状态。用 `HL.QMT` 再次初始化同一地址会清除损坏标志。

<!-- PTO-READER-BLOCK: arch-gqm-example-usage role=example-usage -->
## 非规范队列演示

对于容量为二的队列，一次成功的非宽松队尾压入会把计数从零改为一，并返回状态 `00` 和主值 `1`，即剩余容量。第二次压入填满队列并报告 `0`。第三次压入返回状态 `01` 和主值 `0`，不存入任何内容。

随后的非宽松弹出返回第一个存入的值，报告剩余一个条目，并把该条目的非零释放纪元复制到 `_LastGQMAcquireEpoch`。

这个流程仅用于说明；嵌入的 ASL 仍是状态字段和状态更新顺序的确切来源。

<!-- PTO-READER-BLOCK: arch-gqm-related-owners role=related-owners-navigation -->
## 相关所有者

- [执行上下文](execution-context.md)提供 GQM 所依赖的架构上下文。
- [HL.QMT](../../block/lifecycle/HL.QMT.md)、[HL.QPUSH](../../block/lifecycle/HL.QPUSH.md) 和 [HL.QPOP](../../block/lifecycle/HL.QPOP.md) 是调用这些辅助函数的指令。
- [内存排序](../memory-model/ordering.md)拥有架构的排序关系；GQM 的纪元字段不能替代该所有者。
- [陷阱上下文](../state/trap-context.md)拥有执行上下文的可移植保存与恢复。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/general-queue-management.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-GQM","surface":"arch","classification":["programming-model","general-queue-management"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT"]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-GQM","classification":["architecture","general-queue-management"],"scope":"system","owner":"PTO-ARCH-GQM","members":["_GQMQueueValid","_GQMQueueAddress","_GQMQueueCapacity","_GQMQueueCount","_GQMQueueHead","_GQMQueueSuspended","_GQMQueueCorrupt","_GQMQueueEntries","_GQMReleaseEpoch","_LastGQMAcquireEpoch","_GQMEventEpoch","_LastGQMEventAddress"],"depends_on":[]}

constant PTO_GQM_MAX_CAPACITY = 1023;

// This bound sizes executable verification backing. It is not an
// architectural limit on the number of simultaneously initialized queues.
config PTO_MODEL_GQM_QUEUE_SLOTS : integer {1..16} = 4;

type GQMQueueSlot of integer {0..PTO_MODEL_GQM_QUEUE_SLOTS-1};
// The lookup result includes one sentinel value.  Use the configured maximum
// as the static type bound so ASLRef can prove assignments for every allowed
// PTO_MODEL_GQM_QUEUE_SLOTS value.
type GQMQueueLookup of integer {0..16};
type GQMQueueCapacity of integer {0..PTO_GQM_MAX_CAPACITY};
type GQMNonzeroCapacity of integer {1..PTO_GQM_MAX_CAPACITY};
type GQMQueueEntryIndex of integer {0..PTO_GQM_MAX_CAPACITY-1};

type GQMQueueEntry of record {
    value: Word,
    release_epoch: integer
};

type GQMQueueEntryArray of array [[PTO_GQM_MAX_CAPACITY]] of GQMQueueEntry;
type GQMQueueEntryStore of array [[PTO_MODEL_GQM_QUEUE_SLOTS]]
    of GQMQueueEntryArray;

type GQMPopResult of record {
    data: Word,
    result: Word
};

var _GQMQueueValid : array [[PTO_MODEL_GQM_QUEUE_SLOTS]] of boolean;
var _GQMQueueAddress : array [[PTO_MODEL_GQM_QUEUE_SLOTS]] of Word;
var _GQMQueueCapacity : array [[PTO_MODEL_GQM_QUEUE_SLOTS]]
    of GQMQueueCapacity;
var _GQMQueueCount : array [[PTO_MODEL_GQM_QUEUE_SLOTS]]
    of GQMQueueCapacity;
var _GQMQueueHead : array [[PTO_MODEL_GQM_QUEUE_SLOTS]]
    of GQMQueueEntryIndex;
var _GQMQueueSuspended : array [[PTO_MODEL_GQM_QUEUE_SLOTS]] of boolean;
var _GQMQueueCorrupt : array [[PTO_MODEL_GQM_QUEUE_SLOTS]] of boolean;
var _GQMQueueEntries : GQMQueueEntryStore;
var _GQMReleaseEpoch : integer;
var _LastGQMAcquireEpoch : integer;
var _GQMEventEpoch : integer;
var _LastGQMEventAddress : Word;

pure func GQMResult(primary: integer {0..8191},
                    status: bits(2)) => Word
begin
    var result = Zeros{PTO_XLEN};
    result[12:0] = Zeros{13} + primary;
    result[63:62] = status;
    return result;
end;

readonly func FindGQMQueue(address: Word) => GQMQueueLookup
begin
    var selected: GQMQueueLookup =
        PTO_MODEL_GQM_QUEUE_SLOTS as GQMQueueLookup;
    for candidate = 0 to PTO_MODEL_GQM_QUEUE_SLOTS - 1 do
        let slot = candidate as GQMQueueSlot;
        if selected == PTO_MODEL_GQM_QUEUE_SLOTS &&
           _GQMQueueValid[[slot]] &&
           _GQMQueueAddress[[slot]] == address then
            selected = slot as GQMQueueLookup;
        end;
    end;
    return selected;
end;

readonly func FindFreeGQMQueue() => GQMQueueLookup
begin
    var selected: GQMQueueLookup =
        PTO_MODEL_GQM_QUEUE_SLOTS as GQMQueueLookup;
    for candidate = 0 to PTO_MODEL_GQM_QUEUE_SLOTS - 1 do
        let slot = candidate as GQMQueueSlot;
        if selected == PTO_MODEL_GQM_QUEUE_SLOTS &&
           !_GQMQueueValid[[slot]] then
            selected = slot as GQMQueueLookup;
        end;
    end;
    return selected;
end;

readonly func GQMQueueInitialized(address: Word) => boolean
begin
    return FindGQMQueue(address) != PTO_MODEL_GQM_QUEUE_SLOTS;
end;

readonly func GQMQueueRemaining(address: Word) => GQMQueueCapacity
begin
    let found = FindGQMQueue(address);
    if found == PTO_MODEL_GQM_QUEUE_SLOTS then
        return 0;
    end;
    let slot = found as GQMQueueSlot;
    return (_GQMQueueCapacity[[slot]] - _GQMQueueCount[[slot]])
        as GQMQueueCapacity;
end;

readonly func GQMQueueSuspended(address: Word) => boolean
begin
    let found = FindGQMQueue(address);
    return if found == PTO_MODEL_GQM_QUEUE_SLOTS then
        FALSE
    else
        _GQMQueueSuspended[[found as GQMQueueSlot]];
end;

readonly func GQMQueueHeadValue(address: Word) => Word
begin
    let slot = FindGQMQueue(address) as GQMQueueSlot;
    assert _GQMQueueCount[[slot]] > 0;
    return _GQMQueueEntries[[slot]][[_GQMQueueHead[[slot]]]].value;
end;

readonly func GQMQueueHeadReleaseEpoch(address: Word) => integer
begin
    let slot = FindGQMQueue(address) as GQMQueueSlot;
    assert _GQMQueueCount[[slot]] > 0;
    return _GQMQueueEntries[[slot]][[_GQMQueueHead[[slot]]]].release_epoch;
end;

func ResetGQMState()
begin
    for candidate = 0 to PTO_MODEL_GQM_QUEUE_SLOTS - 1 do
        let slot = candidate as GQMQueueSlot;
        _GQMQueueValid[[slot]] = FALSE;
        _GQMQueueAddress[[slot]] = Zeros{PTO_XLEN};
        _GQMQueueCapacity[[slot]] = 0;
        _GQMQueueCount[[slot]] = 0;
        _GQMQueueHead[[slot]] = 0;
        _GQMQueueSuspended[[slot]] = FALSE;
        _GQMQueueCorrupt[[slot]] = FALSE;
    end;
    _GQMReleaseEpoch = 0;
    _LastGQMAcquireEpoch = 0;
    _GQMEventEpoch = 0;
    _LastGQMEventAddress = Zeros{PTO_XLEN};
end;

func InitializeGQMQueue(address: Word,
                        capacity: GQMQueueCapacity) => GQMQueueSlot
begin
    var found = FindGQMQueue(address);
    if found == PTO_MODEL_GQM_QUEUE_SLOTS then
        found = FindFreeGQMQueue();
    end;

    // The executable profile must provide enough backing for its workload.
    // This assertion does not define an architectural queue-count limit.
    assert found != PTO_MODEL_GQM_QUEUE_SLOTS;
    let slot = found as GQMQueueSlot;
    _GQMQueueValid[[slot]] = TRUE;
    _GQMQueueAddress[[slot]] = address;
    _GQMQueueCapacity[[slot]] = capacity;
    _GQMQueueCount[[slot]] = 0;
    _GQMQueueHead[[slot]] = 0;
    _GQMQueueSuspended[[slot]] = FALSE;
    _GQMQueueCorrupt[[slot]] = FALSE;
    return slot;
end;

func SetGQMQueueSuspended(address: Word, suspended: boolean)
begin
    let found = FindGQMQueue(address);
    if found != PTO_MODEL_GQM_QUEUE_SLOTS then
        _GQMQueueSuspended[[found as GQMQueueSlot]] = suspended;
    end;
end;

func SetGQMQueueCorrupt(address: Word, corrupt: boolean)
begin
    let found = FindGQMQueue(address);
    if found != PTO_MODEL_GQM_QUEUE_SLOTS then
        _GQMQueueCorrupt[[found as GQMQueueSlot]] = corrupt;
    end;
end;

func BroadcastGQMEvent(address: Word)
begin
    _GQMEventEpoch = _GQMEventEpoch + 1;
    _LastGQMEventAddress = address;
end;

func PushGQMQueueEntry(address: Word,
                       value: Word,
                       at_head: boolean,
                       relaxed: boolean,
                       notify_event: boolean) => Word
begin
    let found = FindGQMQueue(address);
    if found == PTO_MODEL_GQM_QUEUE_SLOTS then
        return GQMResult(0, '10');
    end;

    let slot = found as GQMQueueSlot;
    if _GQMQueueCorrupt[[slot]] then
        return GQMResult(0, '10');
    end;

    let remaining = GQMQueueRemaining(address);
    if _GQMQueueSuspended[[slot]] || remaining == 0 then
        return GQMResult(remaining, '01');
    end;
    assert _GQMQueueCapacity[[slot]] > 0;
    let capacity = _GQMQueueCapacity[[slot]] as GQMNonzeroCapacity;

    var entry_index: GQMQueueEntryIndex = 0;
    if at_head then
        if _GQMQueueHead[[slot]] == 0 then
            entry_index = (capacity - 1)
                as GQMQueueEntryIndex;
        else
            entry_index = (_GQMQueueHead[[slot]] - 1)
                as GQMQueueEntryIndex;
        end;
        _GQMQueueHead[[slot]] = entry_index;
    else
        entry_index = ((_GQMQueueHead[[slot]] + _GQMQueueCount[[slot]])
            MOD capacity) as GQMQueueEntryIndex;
    end;

    var release_epoch: integer = 0;
    if !relaxed then
        _GQMReleaseEpoch = _GQMReleaseEpoch + 1;
        release_epoch = _GQMReleaseEpoch;
    end;
    _GQMQueueEntries[[slot]][[entry_index]].value = value;
    _GQMQueueEntries[[slot]][[entry_index]].release_epoch = release_epoch;
    _GQMQueueCount[[slot]] = (_GQMQueueCount[[slot]] + 1)
        as GQMQueueCapacity;

    if notify_event then
        BroadcastGQMEvent(address);
    end;
    return GQMResult(GQMQueueRemaining(address), '00');
end;

func PopGQMQueueEntry(address: Word,
                      relaxed: boolean,
                      notify_event: boolean) => GQMPopResult
begin
    var response = GQMPopResult {
        data = Zeros{PTO_XLEN},
        result = GQMResult(0, '10')
    };
    let found = FindGQMQueue(address);
    if found == PTO_MODEL_GQM_QUEUE_SLOTS then
        return response;
    end;

    let slot = found as GQMQueueSlot;
    if _GQMQueueCorrupt[[slot]] then
        return response;
    elsif _GQMQueueCount[[slot]] == 0 then
        response.result = GQMResult(0, '01');
        return response;
    end;
    assert _GQMQueueCapacity[[slot]] > 0;
    let capacity = _GQMQueueCapacity[[slot]] as GQMNonzeroCapacity;

    let head = _GQMQueueHead[[slot]];
    let entry = _GQMQueueEntries[[slot]][[head]];
    let next_head = ((head + 1) MOD capacity)
        as GQMQueueEntryIndex;
    _GQMQueueHead[[slot]] = next_head;
    _GQMQueueCount[[slot]] = (_GQMQueueCount[[slot]] - 1)
        as GQMQueueCapacity;
    if _GQMQueueCount[[slot]] == 0 then
        _GQMQueueHead[[slot]] = 0;
    end;

    if !relaxed && entry.release_epoch != 0 then
        _LastGQMAcquireEpoch = entry.release_epoch;
    end;
    if notify_event then
        BroadcastGQMEvent(address);
    end;
    response.data = entry.value;
    response.result = GQMResult(_GQMQueueCount[[slot]], '00');
    return response;
end;
```
<!-- GENERATED-ASL-END: unit -->
