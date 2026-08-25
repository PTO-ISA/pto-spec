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

通用队列管理对按地址访问的队列、队列条目以及队列操作返回的状态进行建模。`PTO-STATE-ARCH-GQM` 拥有队列表、条目存储、释放与获取纪元，以及事件观测状态。

该所有者定义初始化、暂停与损坏状态、压入与弹出行为以及事件通知。指令解码仍由调用这些辅助函数的指令所有者定义。

<!-- PTO-READER-BLOCK: arch-gqm-concepts-state role=concepts-state -->
## 队列状态与结果字

每个有效模型槽记录地址、容量、计数、队头、暂停标志、损坏标志和条目数组。每个条目包含一个 `Word` 值和一个释放纪元。

`GQMResult` 把主值放入位 `12:0`，把两位状态放入位 `63:62`；其他结果位从零开始。状态 `00` 表示成功路径。压入操作在队列暂停或已满时使用 `01`，弹出操作则在队列为空时使用 `01`。状态 `10` 用于队列不存在或已经损坏。

<!-- PTO-READER-BLOCK: arch-gqm-rules-interactions role=rules-interactions -->
## 压入、弹出与通知

`PushGQMQueueEntry` 拒绝不存在或损坏的队列；对于暂停或已满的队列，它返回剩余容量；否则根据 `at_head` 在队头或队尾插入。非宽松压入会递增 `_GQMReleaseEpoch` 并把该纪元存入条目；宽松压入存入纪元 `0`。

`PopGQMQueueEntry` 对不存在或损坏的队列返回零数据和状态 `10`，对空队列返回状态 `01`，否则移除队头条目。非宽松弹出会把条目中非零的释放纪元复制到 `_LastGQMAcquireEpoch`。

当成功压入或弹出的 `notify_event` 为真时，`BroadcastGQMEvent` 递增 `_GQMEventEpoch`，并在 `_LastGQMEventAddress` 中记录队列地址。

<!-- PTO-READER-BLOCK: arch-gqm-boundaries role=boundaries -->
## 容量与模型边界

单个队列的容量范围为 `0` 到 `1023`。`PTO_MODEL_GQM_QUEUE_SLOTS` 可配置为 `1` 到 `16`，默认值为 `4`；但所有者明确把它当作可执行验证的后备容量，而不是已初始化队列数量的架构限制。

初始化会复用相同地址的现有槽，或者选择第一个空闲槽。可执行配置档必须为其工作负载提供足够的模型槽；槽耗尽会触发断言，而不是定义一个可移植的队列数量失败结果。

<!-- PTO-READER-BLOCK: arch-gqm-example-usage role=example-usage -->
## 非规范队列流程示例

对于容量为二的队列，一次成功的队尾压入会把计数从零改为一，并报告剩余一个条目。随后进行非宽松弹出会返回所存值，把计数恢复为零、把队头复位为零，并观测条目的非零释放纪元。

这个流程仅用于说明；嵌入的 ASL 仍是状态字段和状态更新顺序的确切来源。

<!-- PTO-READER-BLOCK: arch-gqm-related-owners role=related-owners-navigation -->
## 相关所有者

- [执行上下文](execution-context.md)提供 GQM 所依赖的架构上下文。
- [内存排序](../memory-model/ordering.md)拥有架构排序关系；GQM 的纪元字段不会取代该所有者。
- [陷阱上下文](../state/trap-context.md)拥有执行上下文的可移植保存与恢复行为。
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

    var entry_index: GQMQueueEntryIndex = 0;
    if at_head then
        if _GQMQueueHead[[slot]] == 0 then
            entry_index = (_GQMQueueCapacity[[slot]] - 1)
                as GQMQueueEntryIndex;
        else
            entry_index = (_GQMQueueHead[[slot]] - 1)
                as GQMQueueEntryIndex;
        end;
        _GQMQueueHead[[slot]] = entry_index;
    else
        entry_index = ((_GQMQueueHead[[slot]] + _GQMQueueCount[[slot]])
            MOD _GQMQueueCapacity[[slot]]) as GQMQueueEntryIndex;
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

    let head = _GQMQueueHead[[slot]];
    let entry = _GQMQueueEntries[[slot]][[head]];
    let next_head = ((head + 1) MOD _GQMQueueCapacity[[slot]])
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
