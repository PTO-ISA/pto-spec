<!-- GENERATED FROM: asl/scalar/sys/SYNC.CORE.asl -->
# SYNC.CORE

**Normative ASL source:** `asl/scalar/sys/SYNC.CORE.asl`

Waits for all four PEs at the same Core-local phase boundary and completes their earlier GM obligations.

## Normative identity {#PTO-INST-SCALAR-SYNC-CORE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sync-core-purpose role=purpose -->
## What SYNC.CORE is for
`SYNC.CORE` creates a Core-local phase boundary for the four PEs in one kernel invocation. It exists so later work cannot outrun an earlier phase whose participating PEs and GM obligations must all be complete.

<!-- PTO-READER-BLOCK: scalar-sync-core-mechanism role=mechanism -->
## Rendezvous mechanism
Each PE arrives at the same static `SYNC.CORE` in the same dynamic order and invocation. Arrival becomes irrevocable only after older work can no longer fault or require recovery. Validated but incomplete earlier GM work may remain after arrival, but collective completion waits until that work resolves through its actual producer, issue, and completion path. The PE parks until all four participants have arrived and all cut-off GM obligations are complete; the completed generation is then retained until every parked PE consumes its release once.

<!-- PTO-READER-BLOCK: scalar-sync-core-inputs-outputs role=inputs-outputs -->
## Inputs and outputs
The instruction has no encoded operands and always names PE0, PE1, PE2, and PE3 of the current Core. It produces no register or memory value. Its observable result is that every participant may proceed past the same phase boundary after the rendezvous and required GM progress complete.

<!-- PTO-READER-BLOCK: scalar-sync-core-effects role=effects -->
## State and ordering effects
A blocked PE keeps its `TPC` on `SYNC.CORE`. Completion orders every participant's earlier qualifying GM operations before every participant's later qualifying GM operations, invalidates each participant's current local reservation, and permits each PE to advance exactly once. Retaining the release until consumption prevents a fast PE from losing its completion signal.

<!-- PTO-READER-BLOCK: scalar-sync-core-constraints role=constraints -->
## Legal envelope and rejection
The only legal body is `BSTART.SYS FALL`, one exact `sync.core` word `0x0330a02b`, and `BSTOP`. The instruction requires an active kernel invocation and cannot be entered from handler-origin execution. Wrong block kind or transfer, an extra body operation, a malformed or unfetchable stop, or handler entry rejects before any barrier arrival is recorded; the existing bundle, instruction, or fetch fault identifies the failed check.

<!-- PTO-READER-BLOCK: scalar-sync-core-example role=example -->
## Example phase boundary
```text
BSTART.SYS FALL
sync.core
BSTOP
```
If PE0, PE1, and PE2 reach this sequence first, each remains parked with `TPC` at `sync.core`. When PE3 arrives irrevocably and prior GM obligations are complete, PE3 proceeds and the retained release lets the other three PEs each proceed once.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sync.core
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sync_core_32_0330a02b7c32 | L32 | 32 | 0x0330a02b / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/SYNC.CORE.asl -->
```asl
readonly func InstructionContractOperation_SYNC_CORE() => ScalarOperation
begin
    return ScalarOperation_SYNC_CORE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
The only canonical body is BSTART.SYS FALL, sync.core, BSTOP.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/SYNC.CORE.asl -->
```asl
readonly func InstructionContractHandler_SYNC_CORE() => ScalarSemanticHandler
begin
    return ScalarHandler_SyncCore;
end;

pure func InstructionContractRequiresSystemBlock_SYNC_CORE() => boolean
begin
    return TRUE;
end;

func ExecuteSyncCore()
begin
    if _CurrentMemoryOrigin == MemoryEventOrigin_Handler then
        SetFault(Fault_BundleControl, ReadTPC());
        return;
    end;
    if !_KernelInvocationActiveByCore[[_CurrentModelCore]] ||
       _CurrentKernelInvocation == 0 then
        SetFault(Fault_BundleControl, ReadTPC());
        return;
    end;
    if !VerificationGMProgressIsDeferred() then
        ProgressKernelGMObligationsForCore(_CurrentModelCore,
            _CurrentKernelInvocation);
    end;
    if _LastFault != Fault_None then return; end;
    SyncCore();
end;

pure func InstructionContractParticipantCount_SYNC_CORE() => integer {4}
begin
    return 4;
end;

pure func InstructionContractExactMatch_SYNC_CORE() => bits(32)
begin
    return '00000011001100001010000000101011';
end;

pure func InstructionContractExactMask_SYNC_CORE() => bits(32)
begin
    return Ones{32};
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SYNC.CORE has no operands and includes PE0, PE1, PE2, and PE3.

## Legality

- Only the exact 32-bit word 0x0330a02b decodes as SYNC.CORE. The active bundle must be a Fallthrough SYS block with exactly one SYNC.CORE body operation and a required BSTOP.

## State effects

- A blocked PE does not advance its PC. On completion, the barrier generation is retained until each parked PE consumes its release once, and each participant's current local reservation is invalidated.

## Memory effects and ordering

### Memory effects

- Completion orders earlier qualifying GM operations before later qualifying GM operations for every participant pair, after those earlier operations reach their existing completion and visibility point.

### Ordering

- A PE parks at SYNC.CORE until all four PEs have irrevocably arrived at the same static instruction in the same dynamic order and invocation and every earlier GM obligation has completed. Arrival cannot be irrevocable while older work may still fault or require recovery.

## Exceptions

- The complete SYS envelope is validated before collective arrival. Wrong block composition raises Fault_BundleControl; a nonmatching instruction encoding raises Fault_IllegalInstruction.

## Examples

- sync.core
