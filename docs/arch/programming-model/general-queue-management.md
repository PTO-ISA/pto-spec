<!-- GENERATED FROM: asl/arch/programming-model/general-queue-management.asl -->
# General Queue Management

**Normative ASL source:** `asl/arch/programming-model/general-queue-management.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-GQM}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-gqm-purpose-scope role=purpose-scope -->
## Purpose and scope

General Queue Management models addressed queues, their entries, and the status returned by queue operations. `PTO-STATE-ARCH-GQM` owns the queue tables, entry storage, release/acquire epochs, and event-observation state.

The owner defines initialization, suspension and corruption state, push and pop behavior, and event notification. Instruction decoding remains in the instruction owners that call these helpers.

<!-- PTO-READER-BLOCK: arch-gqm-concepts-state role=concepts-state -->
## Queue state and result words

Each valid model slot records an address, capacity, count, head, suspended flag, corrupt flag, and entry array. Each entry contains a `Word` value and a release epoch.

`GQMResult` places its primary value in bits `12:0` and its two-bit status in bits `63:62`; all other result bits start at zero. Status `00` is the successful path. A push uses `01` when the queue is suspended or full, while a pop uses `01` when the queue is empty. Status `10` is used when the queue is missing or corrupt.

<!-- PTO-READER-BLOCK: arch-gqm-rules-interactions role=rules-interactions -->
## Push, pop, and notification

`PushGQMQueueEntry` rejects a missing or corrupt queue, returns remaining capacity for a suspended or full queue, and otherwise inserts at the head or tail selected by `at_head`. A non-relaxed push increments `_GQMReleaseEpoch` and stores that epoch with the entry; a relaxed push stores epoch `0`.

`PopGQMQueueEntry` returns zero data with status `10` for a missing or corrupt queue, status `01` for an empty queue, and otherwise removes the head entry. A non-relaxed pop copies a nonzero entry release epoch into `_LastGQMAcquireEpoch`.

When `notify_event` is true on a successful push or pop, `BroadcastGQMEvent` increments `_GQMEventEpoch` and records the queue address in `_LastGQMEventAddress`.

<!-- PTO-READER-BLOCK: arch-gqm-boundaries role=boundaries -->
## Capacity and model boundaries

One queue capacity is in the range `0` through `1023`. `PTO_MODEL_GQM_QUEUE_SLOTS` is configurable from `1` through `16` and defaults to `4`, but the owner explicitly treats it as executable verification backing rather than an architectural limit on initialized queues.

Initialization reuses an existing slot for the same address or selects the first free slot. The executable profile must provide enough model slots for its workload; exhaustion reaches an assertion instead of defining a portable queue-count failure result.

<!-- PTO-READER-BLOCK: arch-gqm-example-usage role=example-usage -->
## Non-normative queue walkthrough

For a capacity-two queue, a successful tail push changes the count from zero to one and reports one remaining entry. A following non-relaxed pop returns the stored value, changes the count back to zero, resets the head to zero, and observes the entry's nonzero release epoch.

This walkthrough is illustrative; the embedded ASL remains the exact source for status fields and state-update order.

<!-- PTO-READER-BLOCK: arch-gqm-related-owners role=related-owners-navigation -->
## Related owners

- [Execution context](execution-context.md) supplies the architectural context on which GQM depends.
- [Memory ordering](../memory-model/ordering.md) owns the architecture's ordering relations; GQM's epoch fields do not replace that owner.
- [Trap context](../state/trap-context.md) owns portable save and recovery of execution context.
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
