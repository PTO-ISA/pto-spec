<!-- GENERATED FROM: asl/scalar/sys/TLB.IALL.asl -->
# TLB.IALL

**Normative ASL source:** `asl/scalar/sys/TLB.IALL.asl`

TLB.IALL completes the all translation entries maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-TLB-IALL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-tlb-iall-purpose role=purpose -->
## What TLB.IALL does

`TLB.IALL` completes the all-translation-entries maintenance operation synchronously. Being the widest TLB request, it needs no operand: the encoding has no field (`asl/scalar/sys/TLB.IALL.asl:1`), and the semantic operand is the all-zero XLEN value.

<!-- PTO-READER-BLOCK: scalar-tlb-iall-mechanism role=mechanism -->
## System mechanism

`InstructionContractHandler_TLB_IALL` selects the shared maintenance handler (`asl/scalar/sys/TLB.IALL.asl:18`), and the token `Maintenance_TLB_IALL` has the last case in the executor, advancing the TLB epoch with no operand test at all (`asl/scalar/model/sys/semantics.asl:154`).

`InstructionContractMaintenanceUsesOperand_TLB_IALL` is `FALSE` (`asl/scalar/sys/TLB.IALL.asl:36`), so the dispatcher passes `Zeros{PTO_XLEN}` and reads no scalar register (`asl/scalar/model/dispatch/sys.asl:59`).

Ring privilege still applies: `InstructionContractMaintenanceRequiresRootRing_TLB_IALL` returns `TRUE` (`asl/scalar/sys/TLB.IALL.asl:42`).

<!-- PTO-READER-BLOCK: scalar-tlb-iall-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

There is no encoded operand and no destination. Every bit of the 32-bit form is fixed by the single catalog record, so the instruction cannot be narrowed to a scope, an identifier, or an address.

The recorded operand is zero, and nothing is written to a register, temporary queue, or system register.

<!-- PTO-READER-BLOCK: scalar-tlb-iall-effects role=effects -->
## Architectural effects

On success the TLB epoch advances by one and `Maintenance_TLB_IALL` with operand zero is written into the maintenance record (`asl/scalar/model/sys/semantics.asl:155`). `TPC` then advances by 4 bytes for this 32-bit form.

Design point: an all-entries request has no operand to validate, but the privilege check still runs first. That keeps translation maintenance uniformly manager-only, so an unprivileged attempt cannot even reach the epoch step.

The instruction performs no ordinary scalar memory access and does not define translation-table contents.

<!-- PTO-READER-BLOCK: scalar-tlb-iall-constraints role=constraints -->
## Placement and rejection

Outside an active SYS block body the attempt raises `Fault_BundleControl` before the handler. Inside the body, a current ring other than ACR0 raises `Fault_IllegalInstruction`, and the TLB epoch keeps its previous value because the executor returns before the epoch step (`asl/scalar/model/sys/semantics.asl:130`).

There is no reserved encoding and no operand-shape rejection, since all bits are fixed and no operand is read.

<!-- PTO-READER-BLOCK: scalar-tlb-iall-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

At ACR0, `tlb.iall` in a SYS block body advances the TLB epoch by one, records `Maintenance_TLB_IALL` with operand zero, and advances `TPC` by 4 bytes. The same instruction at ACR1 raises `Fault_IllegalInstruction`, and the three other epoch counters are untouched in both cases.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
tlb.iall
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| tlb_iall_32_0fb421b85c88 | L32 | 32 | 0x0030702b / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/TLB.IALL.asl -->
```asl
readonly func InstructionContractOperation_TLB_IALL()
    => ScalarOperation
begin
    return ScalarOperation_TLB_IALL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
TLB.IALL executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/TLB.IALL.asl -->
```asl
readonly func InstructionContractHandler_TLB_IALL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_TLB_IALL()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_TLB_IALL()
    => MaintenanceOperation
begin
    return Maintenance_TLB_IALL;
end;

pure func InstructionContractMaintenanceUsesOperand_TLB_IALL()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_TLB_IALL()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- This form has no operand; the semantic operand is the all-zero XLEN value.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- TLB maintenance is assigned only at ACR0 and rejects at every other ring before operand validation.

## State effects

- Success records Maintenance_TLB_IALL and its exact operand token.
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

- tlb.iall
