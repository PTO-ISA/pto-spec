<!-- GENERATED FROM: asl/scalar/sys/IC.IALL.asl -->
# IC.IALL

**Normative ASL source:** `asl/scalar/sys/IC.IALL.asl`

IC.IALL completes the instruction-cache all-entry scope maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-IC-IALL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ic-iall-purpose role=purpose -->
## What IC.IALL does

`IC.IALL` is the instruction-cache all-entry scope maintenance operation. Its encoding has no operand field (`asl/scalar/sys/IC.IALL.asl:1`), and the contract states the semantic operand is the all-zero XLEN value rather than a register.

<!-- PTO-READER-BLOCK: scalar-ic-iall-mechanism role=mechanism -->
## System mechanism

The instruction selects the shared maintenance handler (`asl/scalar/sys/IC.IALL.asl:11`) and the token `Maintenance_IC_IALL` (`asl/scalar/sys/IC.IALL.asl:23`). `Maintenance_IC_IALL` is one of the two instruction-cache cases in the executor, so it advances `_InstructionCacheEpoch` rather than the data-cache epoch (`asl/scalar/model/sys/semantics.asl:138`).

Because `InstructionContractMaintenanceUsesOperand_IC_IALL` is `FALSE` (`asl/scalar/sys/IC.IALL.asl:29`), the dispatcher supplies `Zeros{PTO_XLEN}` directly and reads no scalar register (`asl/scalar/model/dispatch/sys.asl:46`).

`IC.IALL` is applicable only in an active SYS block body (`asl/scalar/model/sys/semantics.asl:322`).

<!-- PTO-READER-BLOCK: scalar-ic-iall-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

There is no encoded operand and no destination. The single catalog record fixes every bit of the 32-bit form, so the instruction cannot select a scope, a set, or a way.

The recorded operand is zero. Nothing is written to a register, a temporary queue, or a system register.

<!-- PTO-READER-BLOCK: scalar-ic-iall-effects role=effects -->
## Architectural effects

A successful attempt advances the instruction-cache epoch by one and stores `Maintenance_IC_IALL` with operand zero in the maintenance record (`asl/scalar/model/sys/semantics.asl:159`). `TPC` then advances by 4 bytes for this 32-bit form (`asl/scalar/model/dispatch/top-level.asl:56`).

Design point: the instruction-cache epoch is also the visibility point that `fence.i` and `FENCE.D` can advance. Pairing an epoch with a recorded operation token lets a reader of the record tell an all-entry request apart from an address-scoped one, even though both move the same counter.

No data memory, register, or queue state changes.

<!-- PTO-READER-BLOCK: scalar-ic-iall-constraints role=constraints -->
## Placement and rejection

Only placement can reject `IC.IALL`: outside an active SYS block body the dispatcher raises `Fault_BundleControl` (`asl/scalar/model/dispatch/top-level.asl:28`) and the executor never runs, so the epoch and record keep their previous values. All bits are fixed, so there is no reserved encoding to reject.

Instruction-cache maintenance carries no ring restriction: `MaintenanceAccessPermitted` restricts only the four TLB operations to ring 0 (`asl/scalar/model/sys/semantics.asl:121`).

<!-- PTO-READER-BLOCK: scalar-ic-iall-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Execute `ic.iall` in a SYS block body. The attempt checks its fixed bits, advances the instruction-cache epoch by one, records `Maintenance_IC_IALL` with operand zero, and adds 4 bytes to `TPC`. The data-cache epoch and the TLB epoch are unaffected.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ic.iall
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ic_iall_32_854f0d4d906a | L32 | 32 | 0x0010502b / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/IC.IALL.asl -->
```asl
readonly func InstructionContractOperation_IC_IALL()
    => ScalarOperation
begin
    return ScalarOperation_IC_IALL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
IC.IALL executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/IC.IALL.asl -->
```asl
readonly func InstructionContractHandler_IC_IALL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_IC_IALL()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_IC_IALL()
    => MaintenanceOperation
begin
    return Maintenance_IC_IALL;
end;

pure func InstructionContractMaintenanceUsesOperand_IC_IALL()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_IC_IALL()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- This form has no operand; the semantic operand is the all-zero XLEN value.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- Cache maintenance is a local synchronous hint completion at every ACR.

## State effects

- Success records Maintenance_IC_IALL and its exact operand token.
- Success advances exactly one data-cache, instruction-cache, bundle-cache, or TLB epoch and then advances TPC.

## Memory effects and ordering

### Memory effects

- No ordinary scalar memory access is performed; success records the operation and operand and advances the selected maintenance epoch.

### Ordering

- Check block placement and encoded legality before source reads or architectural effects.
- Snapshot every scalar source before the selected system effect, then advance TPC only after success.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- ic.iall
