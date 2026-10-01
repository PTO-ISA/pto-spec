<!-- GENERATED FROM: asl/arch/memory-model/fault-precision.asl -->
# Fault Precision

**Normative ASL source:** `asl/arch/memory-model/fault-precision.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-fault-precision-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the replay checkpoint that lets a retry re-execute a whole Tile memory request, and the funnel from memory faults to architectural trap state. It carries `PTO-ARCH-MEMORY-MODEL-REPLAY-001` and `PTO-ARCH-MEMORY-MODEL-FLUSH-001`, and depends on `PTO-ARCH-STATE-TRAP-CONTEXT`.

The body writes `_MemoryReplayState`, the trap bank arrays, `_LastFault`, `_FaultAddress`, `TPC` and one `_ExtendedSystemRegisters` entry.

<!-- PTO-READER-BLOCK: arch-fault-precision-concepts role=concepts-state -->
## Replay checkpoint and the trap bank

- `_MemoryReplayState` is a four-field record defined in `asl/arch/data-types/memory-model.asl`: `active`, `request`, `committed_event_count` and `epoch`.
- `BeginMemoryReplay(request)` sets `active` true, stores `request`, copies `_MemoryEventCount` into `committed_event_count` and increments `epoch`.
- `CommitMemoryReplayEffect` moves `committed_event_count` up to `_MemoryEventCount`, only while `active` is true.
- `FlushMemoryReplay` rewinds `_MemoryEventCount` to `committed_event_count` and clears `active`; `CompleteMemoryReplay` moves it up and clears `active`.
- The trap bank is five per-ring arrays: `_ACRTrapAsynchronous`, `_ACRTrapArgumentValid`, `_ACRTrapCause` as `bits(24)`, `_ACRTrapNumber` as `TrapNumber` and `_ACRTrapArgument0` as `Word`.

<!-- PTO-READER-BLOCK: arch-fault-precision-rules role=rules-interactions -->
## What each entry point writes

- `SetFaultWithCause(code, address, cause)` calls `SaveTrapContext(ring, source_ring)` and writes `TPC` only for nonzero `code`, where `ring = TrapTargetForFault(CurrentACR())` and is the source ring otherwise.
- It records `code` in `_LastFault`, `address` in `_FaultAddress` and `cause` in `_ACRTrapCause`, and sets `_ACRTrapArgumentValid[[ring]]` from `code != Fault_None`.
- The `case code of` statement gives `Fault_None` and `Fault_ExecutionStateCheck` trap number `0`, `Fault_IllegalInstruction` `4`, the four tile and bundle codes a shared `5`, `Fault_ServiceRequest` `6`, and the remaining instruction, data and debug faults distinct numbers from `32` to `52`.
- For nonzero `code` it calls `SetCurrentACR(ring)` and `WriteTPC(TrapVectorEntry(ring, address))`; `TrapVectorEntry` returns `EVBASE` when nonzero and `address` otherwise.
- `ClearFault` resets the current ring's bank to `Fault_None`, zero cause, trap number and argument, false flags, and clears `_FaultAddress` too.
- `RaiseServiceRequest(request_type)` checks `ServiceRequestPermitted(source_ring, request_type)`: on refusal it raises `Fault_IllegalInstruction` at `ReadTPC()` and returns false; on success it saves context for `ServiceRequestTarget`, resumes `4` bytes past the source TPC and enters with trap number `6` and argument `source_tpc` through `TrapVectorEntry`.
- `RaiseInterrupt(interrupt_id, cause)` marks the interrupt pending and, when `InterruptEnabled` is true, saves context and enters the target ring asynchronously with trap number `44`.
- `PackTrapStatus(ring)` builds one `Word`: bit `63` asynchronous, bit `62` argument-valid, `value[24 +: 24]` cause, `value[0 +: 6]` trap number; `UnpackTrapStatus` restores those fields.

Design point: `FlushMemoryReplay` rewrites `_MemoryEventCount` and nothing else, so it cannot undo a GM write or a tile payload element; the caller wrote those before recording the event. Records above the checkpoint stay in `_MemoryEvents` but unreachable: readers bound themselves by `_MemoryEventCount`, and `AddMemoryEvent` overwrites that slot next.

Design point: `MemoryReplayCanRetryWholeRequest` needs `!_MemoryReplayState.active` and a `request` equal to the saved one or `Zeros{PTO_XLEN}`. Because `FlushMemoryReplay` clears `active`, a request is retryable only after a flush or a completion, and the caller must pass the same `Word` it passed to `BeginMemoryReplay`.

Design point: `SetFaultWithCause` writes the code before the `case`, so `Fault_None` leaves a bank with zero cause, false argument-valid and trap number `0`, while `_FaultAddress` keeps its previous value. Clearing the indicator therefore does not clear the address; `ClearFault` zeroes both.

<!-- PTO-READER-BLOCK: arch-fault-precision-boundaries role=boundaries -->
## Boundaries

`Fault_BundlePostCommit` is a success boundary, not a failed instruction: it shares trap number `5` with the tile and bundle faults, and its only ASL producer is `SetFault(Fault_BundlePostCommit, next_pc)` in `asl/block/model/lifecycle/enter-stop.asl`.

`RaiseInterrupt` is called by no ASL unit, only by tests; `RaiseServiceRequest` is called for example from `ArchitectureCloseRequest` in `asl/scalar/model/sys/semantics.asl`. The `PTO-ARCH-MEMORY-MODEL-REPLAY-001` clause calls the faulting instruction the restart point, but this unit writes the trap vector entry, and for a service request an address `4` bytes past it.

The flush writes no fault state and the fault entry writes no replay state other than the context copy, so a fault without `FlushMemoryReplay` leaves `active` true.

<!-- PTO-READER-BLOCK: arch-fault-precision-example role=example-usage -->
## Non-normative replay example

A Tile load opens the record with `BeginMemoryReplay(ReadBPC())` at `_MemoryEventCount` `4`, commits two events and reaches checkpoint `6`. When a later element fails its probe, `FlushMemoryReplay` returns `_MemoryEventCount` to `6`, and the committed events and GM writes stay in place.

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-fault-precision-related role=related-owners-navigation -->
## Related owners

- `PTO-ARCH-STATE-TRAP-CONTEXT` owns `_TrapContexts` and `SaveTrapContext`.
- `PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL` owns `CurrentACR`, `TrapTargetForFault`, `ServiceRequestPermitted`, `ServiceRequestTarget` and `TrapVectorEntry`.
- [Memory events](memory-events.md) owns `_MemoryEventCount` and the event array.
- `PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT` declares `_MemoryReplayState` and the trap bank arrays.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/fault-precision.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION","surface":"arch","classification":["memory-model","fault-precision"],"depends_on":["PTO-ARCH-STATE-TRAP-CONTEXT"]}
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-REPLAY-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// A scalar fault is precise: effects committed by older instructions remain,
// the faulting instruction is the restart point, and younger work has no
// architectural effect.  A Tile memory request is precise at its Block
// boundary; completed TLOAD/TSTORE beats remain visible, while retrying a
// fault re-executes the whole logical request and never exposes an internal
// lane or cursor as architectural state.
// NDF-END: PTO-ARCH-MEMORY-MODEL-REPLAY-001
// NDF-BEGIN: PTO-ARCH-MEMORY-MODEL-FLUSH-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// A replay flush discards only uncommitted event records and younger pending
// work.  It MUST NOT roll back committed GM writes, committed Tile payload
// elements, or a memory event already admitted before the fault.  Recovery
// retries from the saved instruction/request template.
// NDF-END: PTO-ARCH-MEMORY-MODEL-FLUSH-001

func BeginMemoryReplay(request: Word)
begin
    _MemoryReplayState.active = TRUE;
    _MemoryReplayState.request = request;
    _MemoryReplayState.committed_event_count = _MemoryEventCount;
    _MemoryReplayState.epoch = _MemoryReplayState.epoch + 1;
end;

func CommitMemoryReplayEffect()
begin
    if _MemoryReplayState.active then
        _MemoryReplayState.committed_event_count = _MemoryEventCount;
    end;
end;

func FlushMemoryReplay()
begin
    if _MemoryReplayState.active then
        // Event records after the last committed effect are speculative and
        // are removed.  Architectural memory and Tile state are not undone.
        _MemoryEventCount = _MemoryReplayState.committed_event_count;
        _MemoryReplayState.active = FALSE;
    end;
end;

func CompleteMemoryReplay()
begin
    if _MemoryReplayState.active then
        _MemoryReplayState.committed_event_count = _MemoryEventCount;
        _MemoryReplayState.active = FALSE;
    end;
end;

readonly func MemoryReplayCanRetryWholeRequest(request: Word) => boolean
begin
    return !_MemoryReplayState.active &&
           (_MemoryReplayState.request == request ||
            _MemoryReplayState.request == Zeros{PTO_XLEN});
end;
func SetFaultWithCause(code: FaultCode, address: Word, cause: bits(24))
begin
    let source_ring = CurrentACR();
    let ring = if code == Fault_None then source_ring
        else TrapTargetForFault(source_ring);
    if code != Fault_None then
        SaveTrapContext(ring, source_ring);
    end;
    _LastFault = code;
    _FaultAddress = address;
    _ACRTrapAsynchronous[[ring]] = FALSE;
    _ACRTrapArgumentValid[[ring]] = code != Fault_None;
    _ACRTrapCause[[ring]] = cause;
    case code of
        when Fault_None => _ACRTrapNumber[[ring]] = Zeros{6};
        when Fault_ExecutionStateCheck => _ACRTrapNumber[[ring]] = Zeros{6};
        when Fault_IllegalInstruction => _ACRTrapNumber[[ring]] = Zeros{6} + 4;
        when Fault_InstructionPC => _ACRTrapNumber[[ring]] = Zeros{6} + 32;
        when Fault_InstructionPage => _ACRTrapNumber[[ring]] = Zeros{6} + 33;
        when Fault_DataAlignment => _ACRTrapNumber[[ring]] = Zeros{6} + 34;
        when Fault_DataPage => _ACRTrapNumber[[ring]] = Zeros{6} + 35;
        when Fault_HardwareBreakpoint => _ACRTrapNumber[[ring]] = Zeros{6} + 49;
        when Fault_SoftwareBreakpoint => _ACRTrapNumber[[ring]] = Zeros{6} + 50;
        when Fault_HardwareWatchpoint => _ACRTrapNumber[[ring]] = Zeros{6} + 51;
        when Fault_Assert => _ACRTrapNumber[[ring]] = Zeros{6} + 52;
        when Fault_TileLegality => _ACRTrapNumber[[ring]] = Zeros{6} + 5;
        when Fault_TileAllocation => _ACRTrapNumber[[ring]] = Zeros{6} + 5;
        when Fault_BundleControl => _ACRTrapNumber[[ring]] = Zeros{6} + 5;
        // B.CATR.trap is a successful-commit boundary trap, not a failed
        // instruction.  It uses the bundle exception class while preserving
        // the already selected continuation in the saved clean context.
        when Fault_BundlePostCommit => _ACRTrapNumber[[ring]] = Zeros{6} + 5;
        when Fault_ServiceRequest => _ACRTrapNumber[[ring]] = Zeros{6} + 6;
    end;
    _ACRTrapArgument0[[ring]] = address;
    if code != Fault_None then
        SetCurrentACR(ring);
        WriteTPC(TrapVectorEntry(ring, address));
    end;
end;

func SetFault(code: FaultCode, address: Word)
begin
    SetFaultWithCause(code, address, Zeros{24});
end;

func RaiseServiceRequest(request_type: bits(4)) => boolean
begin
    let source_ring = CurrentACR();
    if !ServiceRequestPermitted(source_ring, request_type) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;

    let source_tpc = ReadTPC();
    let resume_tpc = source_tpc + (Zeros{PTO_XLEN} + 4);
    let target_ring = ServiceRequestTarget(source_ring, request_type);
    SaveTrapContext(target_ring, source_ring);
    _TrapContexts[[target_ring]].tpc = resume_tpc;
    let ebarg_tpc_index = ((target_ring * 4096) + 0x0f43)
        as SystemRegisterFileIndex;
    _ExtendedSystemRegisters[[ebarg_tpc_index]] = resume_tpc;

    _LastFault = Fault_ServiceRequest;
    _FaultAddress = source_tpc;
    _ACRTrapAsynchronous[[target_ring]] = FALSE;
    _ACRTrapArgumentValid[[target_ring]] = TRUE;
    _ACRTrapCause[[target_ring]] = ZeroExtend{24}(request_type);
    _ACRTrapNumber[[target_ring]] = Zeros{6} + 6;
    _ACRTrapArgument0[[target_ring]] = source_tpc;
    SetCurrentACR(target_ring);
    WriteTPC(TrapVectorEntry(target_ring, source_tpc));
    return TRUE;
end;

func ClearFault()
begin
    let ring = CurrentACR();
    _LastFault = Fault_None;
    _FaultAddress = Zeros{PTO_XLEN};
    _ACRTrapAsynchronous[[ring]] = FALSE;
    _ACRTrapArgumentValid[[ring]] = FALSE;
    _ACRTrapCause[[ring]] = Zeros{24};
    _ACRTrapNumber[[ring]] = Zeros{6};
    _ACRTrapArgument0[[ring]] = Zeros{PTO_XLEN};
end;

func RaiseInterrupt(interrupt_id: InterruptID, cause: bits(24))
begin
    let source_ring = CurrentACR();
    let ring = TrapTargetForInterrupt(source_ring);
    SetInterruptPending(ring, interrupt_id);
    if !InterruptEnabled(ring, interrupt_id) then return; end;
    SaveTrapContext(ring, source_ring);
    _LastFault = Fault_None;
    _FaultAddress = Zeros{PTO_XLEN};
    _ACRTrapAsynchronous[[ring]] = TRUE;
    _ACRTrapArgumentValid[[ring]] = TRUE;
    _ACRTrapCause[[ring]] = cause;
    _ACRTrapNumber[[ring]] = Zeros{6} + 44;
    _ACRTrapArgument0[[ring]] =
        NaturalToWord(interrupt_id as integer {0..262144});
    SetCurrentACR(ring);
    WriteTPC(TrapVectorEntry(ring, ReadTPC()));
end;

readonly func PackTrapStatus(ring: AccessControlRing) => Word
begin
    var value: Word = Zeros{PTO_XLEN};
    value[63] = if _ACRTrapAsynchronous[[ring]] then '1' else '0';
    value[62] = if _ACRTrapArgumentValid[[ring]] then '1' else '0';
    value[24 +: 24] = _ACRTrapCause[[ring]];
    value[0 +: 6] = _ACRTrapNumber[[ring]];
    return value;
end;

func UnpackTrapStatus(ring: AccessControlRing, value: Word)
begin
    _ACRTrapAsynchronous[[ring]] = value[63] == '1';
    _ACRTrapArgumentValid[[ring]] = value[62] == '1';
    _ACRTrapCause[[ring]] = value[24 +: 24];
    _ACRTrapNumber[[ring]] = value[0 +: 6];
end;
```
<!-- GENERATED-ASL-END: unit -->
