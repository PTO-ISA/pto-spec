<!-- GENERATED FROM: asl/scalar/sys/DC.IALL.asl -->
# DC.IALL

**Normative ASL source:** `asl/scalar/sys/DC.IALL.asl`

DC.IALL completes the data-cache all-entry scope maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-IALL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-iall-purpose role=purpose -->
## What DC.IALL does

`DC.IALL` is the data-cache all-entry scope maintenance operation. It removes any operand question entirely: the encoding is a single fixed 32-bit form with no field at all (`asl/scalar/sys/DC.IALL.asl:1`), so the semantic operand is the all-zero XLEN value.

<!-- PTO-READER-BLOCK: scalar-dc-iall-mechanism role=mechanism -->
## System mechanism

The instruction selects the shared maintenance handler (`asl/scalar/sys/DC.IALL.asl:11`) and the operation token `Maintenance_DC_IALL` (`asl/scalar/sys/DC.IALL.asl:23`). Because `InstructionContractMaintenanceUsesOperand_DC_IALL` returns `FALSE` (`asl/scalar/sys/DC.IALL.asl:29`), the dispatcher passes `Zeros{PTO_XLEN}` instead of reading a register (`asl/scalar/model/dispatch/sys.asl:23`).

That dispatch line is the practical difference from `DC.IVA` and its siblings: no scalar register is read at all, so a temporary queue that happens to be empty cannot make this instruction illegal.

The instruction still needs an active SYS block body to be applicable (`asl/scalar/model/sys/semantics.asl:322`).

<!-- PTO-READER-BLOCK: scalar-dc-iall-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

There is no encoded operand. The mask `0xffffffff` of the single catalog record leaves no variable bits, so every 32-bit word that matches the form means exactly one thing.

The recorded operand is zero, and the instruction writes no destination register and no temporary queue entry.

<!-- PTO-READER-BLOCK: scalar-dc-iall-effects role=effects -->
## Architectural effects

A successful attempt advances the data-cache epoch by one (`asl/scalar/model/sys/semantics.asl:137`) and stores `Maintenance_DC_IALL` together with the zero operand in the maintenance record (`asl/scalar/model/sys/semantics.asl:159`). `TPC` then advances by 4 bytes, the length of this 32-bit form (`asl/scalar/model/dispatch/top-level.asl:56`).

Design point: an all-entry request has no scope token to preserve, but the record is still written. The record therefore always describes the most recent successful maintenance operation, whether or not that operation had an operand worth naming.

No ordinary scalar memory access happens, and no data is installed into or removed from a modelled cache.

<!-- PTO-READER-BLOCK: scalar-dc-iall-constraints role=constraints -->
## Placement and rejection

The only rejection path that reaches this instruction is placement. Outside an active SYS block body the dispatcher raises `Fault_BundleControl` and never calls the executor, so the record and the epoch hold their prior values.

There are no reserved encodings to reject, because every bit is fixed. There is also no ring restriction: `MaintenanceAccessPermitted` returns `TRUE` for the data-cache operations at every ACR (`asl/scalar/model/sys/semantics.asl:123`).

<!-- PTO-READER-BLOCK: scalar-dc-iall-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Execute `dc.iall` inside a SYS block body. The attempt checks its fixed bits, advances the data-cache epoch by one, records `Maintenance_DC_IALL` with operand zero, and advances `TPC` by 4 bytes. Executing it in any other block kind, for example a Standard block body, raises `Fault_BundleControl` instead.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dc.iall
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_iall_32_3d61563dd077 | L32 | 32 | 0x0010602b / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.IALL.asl -->
```asl
readonly func InstructionContractOperation_DC_IALL()
    => ScalarOperation
begin
    return ScalarOperation_DC_IALL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.IALL executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.IALL.asl -->
```asl
readonly func InstructionContractHandler_DC_IALL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_IALL()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_IALL()
    => MaintenanceOperation
begin
    return Maintenance_DC_IALL;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_IALL()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_IALL()
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

- Success records Maintenance_DC_IALL and its exact operand token.
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

- dc.iall
