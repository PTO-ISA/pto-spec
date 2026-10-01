<!-- GENERATED FROM: asl/arch/state/program-counter.asl -->
# Program Counter

**Normative ASL source:** `asl/arch/state/program-counter.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-PROGRAM-COUNTER}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-program-counter-purpose-scope role=purpose-scope -->
## Purpose and scope

`asl/arch/state/program-counter.asl` owns six small accessors. `ReadPC`, `ReadTPC` and `ReadBPC` are `readonly` functions returning `Word`; `WritePC`, `WriteTPC` and `WriteBPC` take one `Word` argument. `Word` is `bits(PTO_XLEN)` with `PTO_XLEN` `64`, so each accessor moves a full 64-bit value.

The unit governs storage access for two program counters. Instruction sequencing, fault entry, vector selection and recovery eligibility stay with the owners that perform those steps.

<!-- PTO-READER-BLOCK: arch-program-counter-concepts-state role=concepts-state -->
## Two storage objects, three names

`ReadPC` and `ReadTPC` both `return _PC`, and `WritePC` and `WriteTPC` both assign `_PC`. `PC` and `TPC` are therefore two access names for one stored `Word`, not two counters. `ReadBPC` and `WriteBPC` use the separate object `_BPC`.

`_PC` and `_BPC` are declared in `asl/arch/programming-model/execution-context.asl` as `var _PC : Word;` and `var _BPC : Word;`. They belong to the state object `PTO-STATE-ARCH-PROGRAM-CONTROL` with scope `core`, whose owner is `PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT`. `ResetProfileState` in `asl/arch/system-registers/addressing.asl` sets both to `Zeros{PTO_XLEN}`.

Design point: because `WriteTPC` assigns the same object that `WritePC` assigns, a trap redirection is visible immediately through the ordinary PC accessor. After `SetFaultWithCause` in `asl/arch/memory-model/fault-precision.asl` executes `WriteTPC(TrapVectorEntry(ring, address))`, a later `ReadPC()` returns that vector entry. The address passed to the fault path then survives in the saved field `_TrapContexts[[ring]].tpc` and in `_FaultAddress` and `_ACRTrapArgument0[[ring]]`, so a handler that needs the faulting address reads those instead of `ReadPC`.

<!-- PTO-READER-BLOCK: arch-program-counter-rules-interactions role=rules-interactions -->
## Who reads and writes the counters

Fault entry in `SetFaultWithCause` selects the target ring with `TrapTargetForFault`, saves the context, selects that ring with `SetCurrentACR`, and installs the vector entry as the new TPC.

A service request in `RaiseServiceRequest` computes `resume_tpc` as `source_tpc + (Zeros{PTO_XLEN} + 4)`, saves the context for the target ring, overwrites the saved `tpc` field and context register `0x0f43` with `resume_tpc`, and then redirects the live counter to `TrapVectorEntry(target_ring, source_tpc)`, so the request resumes one 4-byte step later. `RaiseInterrupt` ends with `WriteTPC(TrapVectorEntry(ring, ReadTPC()))`.

Branches compute targets from `ReadPC()` or `ReadTPC()` and commit them with `WritePC(...)` in `asl/scalar/model/bru/semantics.asl`, where the sequential step is `ReadPC() + 4` and a halfword offset is scaled with `LSL(halfword_offset, 1)`. The tile memory replay path uses the bundle counter as a request token: `BeginMemoryReplay(ReadBPC())` in `asl/tile/model/memory/load-store.asl`.

Design point: `_BPC` is written only by `WriteBPC`, so a trap redirection cannot move the value that a memory replay request records. The recovery gates `PortableTrapContextRecoverable` and `TrapContextRecoverable` in `asl/arch/state/trap-context.asl` test bit `0` of the saved BPC and of the saved TPC separately, and because the two values come from independent objects, a change to one of them leaves the other bit untouched.

<!-- PTO-READER-BLOCK: arch-program-counter-boundaries role=boundaries -->
## Architectural boundaries

Each of the six bodies holds one `return` or one assignment. They contain no assertion, no fault call and no alignment test: `WriteTPC` stores whatever `Word` it is given, and no accessor advances a counter on its own.

The bit-level tests on these values live in the trap-context recovery gates. `PortableTrapContextRecoverable` requires the saved `bpc[0]` and `tpc[0]` bits to be `'0'`, and `TrapContextRecoverable` repeats both tests on the values read back from context registers `0x0f41` and `0x0f43`.

Design point: keeping the sequential step outside the accessors is what lets the trap path replace a counter outright. `SetFaultWithCause` installs a vector entry that is unrelated to the previous value by any fixed increment, while an ordinary branch adds `4`, or a scaled halfword offset, through `WritePC`.

<!-- PTO-READER-BLOCK: arch-program-counter-example-usage role=example-usage -->
## Reading example

Start from a reset core, where `ResetProfileState` has set both objects to `Zeros{PTO_XLEN}`. `WriteTPC(Zeros{PTO_XLEN} + 4096)` stores `4096` in `_PC`, so `ReadPC()` and `ReadTPC()` both return `4096`; a following `WriteBPC(Zeros{PTO_XLEN} + 4096)` changes only `ReadBPC()`.

If `SavePortableTrapContext` snapshots that state, the saved `bpc[0]` and `tpc[0]` bits are `'0'`, so `PortableTrapContextRecoverable` is `TRUE` for a valid slot. Storing `4097` with `WriteTPC` first makes `tpc[0]` `'1'`, and the same gate then returns `FALSE` even though the slot is still marked valid.

<!-- PTO-READER-BLOCK: arch-program-counter-related-owners role=related-owners-navigation -->
## Related owners

- [Scalar registers](../programming-model/scalar-registers.md) is the dependency named on line 1 and owns `_PEGPRs`.
- [Execution context](../programming-model/execution-context.md) declares `_PC` and `_BPC` and owns the program-control state object.
- [Trap context](trap-context.md) snapshots and restores both counters.
- [Fault precision](../memory-model/fault-precision.md) redirects the counter at fault, service-request and interrupt entry.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/program-counter.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-PROGRAM-COUNTER","surface":"arch","classification":["state","program-counter"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS"]}
readonly func ReadPC() => Word
begin
    return _PC;
end;

readonly func ReadTPC() => Word
begin
    return _PC;
end;

readonly func ReadBPC() => Word
begin
    return _BPC;
end;

func WritePC(value: Word)
begin
    _PC = value;
end;

func WriteTPC(value: Word)
begin
    _PC = value;
end;

func WriteBPC(value: Word)
begin
    _BPC = value;
end;
```
<!-- GENERATED-ASL-END: unit -->
