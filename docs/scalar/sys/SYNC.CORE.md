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
