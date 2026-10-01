<!-- GENERATED FROM: asl/scalar/sys/BC.IALL.asl -->
# BC.IALL

**Normative ASL source:** `asl/scalar/sys/BC.IALL.asl`

BC.IALL completes the bundle-cache all-entry scope maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-BC-IALL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bc-iall-purpose role=purpose -->
## What BC.IALL does

`BC.IALL` is the bundle-cache maintenance operation for the all-entry scope. It completes synchronously as one scalar operation of a SYS block and advances the bundle-cache epoch.

It carries no address: the all-entry scope means every entry, so there is nothing to encode.

<!-- PTO-READER-BLOCK: scalar-bc-iall-mechanism role=mechanism -->
## How the instruction is placed and executed

This instruction is one scalar operation of an active SYS block. The scalar dispatcher first checks that a bundle is active and that its body is active with block kind System; a SYS form outside such a block is rejected with `Fault_BundleControl`, before any encoded-field check and before any architectural effect.

Encoded legality and source availability are then checked, and only then does the handler run.

The handler runs the shared maintenance rule for the `Maintenance_BC_IALL` operation with an all-zero operand. The rule first asks whether the operation is permitted at the current ring.

The all-entry cache scopes are local hints and are permitted at every ring, so for this operation the permission test cannot be the failing step. The rule then advances the bundle-cache epoch. Only when no fault was raised does it record the operation and its operand token as the last maintenance effect.

Design point: the epoch is the completion effect, and the recorded operation and operand are what make that effect auditable. A reader of `CORE_STATE`-style model state can see both that bundle-cache maintenance happened and exactly which operation and operand produced it.

<!-- PTO-READER-BLOCK: scalar-bc-iall-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

- The form has no operand field. The semantic operand is the all-zero XLEN value, and it is recorded as the last maintenance operand.
- There is no destination field, so the instruction never writes a GPR and never pushes `T` or `U`.
- No scalar register and no queue entry is read.

<!-- PTO-READER-BLOCK: scalar-bc-iall-effects role=effects -->
## Architectural effects

On success exactly one epoch advances, and for this operation it is the bundle-cache epoch. One data-cache, one instruction-cache, one bundle-cache and one TLB epoch exist in the model, and a maintenance operation that completes advances exactly one of them.

The instruction performs no ordinary scalar memory access: it does not load, store, or probe an address, and it raises no data-access fault. `TPC` advances by `4` bytes on success. No reservation is taken or dropped.

<!-- PTO-READER-BLOCK: scalar-bc-iall-constraints role=constraints -->
## Placement and rejection

Invalid block placement is rejected first, with `Fault_BundleControl`, before the encoded field is even considered.

Because the all-entry cache scope is a local hint completion at every ring, this operation is never rejected by the maintenance permission rule. The reachable `Fault_IllegalInstruction` paths for this form are therefore the placement and encoded-legality checks, not a ring restriction.

The operation carries no address, so no address-canonicality or address-range check applies to it.

<!-- PTO-READER-BLOCK: scalar-bc-iall-example role=example -->
## Non-normative example

`bc.iall` advances the bundle-cache epoch by one, records `Maintenance_BC_IALL` with a zero operand token, and advances `TPC` by `4` bytes. It generates no memory traffic and touches no scalar register.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bc.iall
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bc_iall_32_fdceb48516a8 | L32 | 32 | 0x0010402b / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/BC.IALL.asl -->
```asl
readonly func InstructionContractOperation_BC_IALL()
    => ScalarOperation
begin
    return ScalarOperation_BC_IALL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BC.IALL executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/BC.IALL.asl -->
```asl
readonly func InstructionContractHandler_BC_IALL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_BC_IALL()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_BC_IALL()
    => MaintenanceOperation
begin
    return Maintenance_BC_IALL;
end;

pure func InstructionContractMaintenanceUsesOperand_BC_IALL()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_BC_IALL()
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

- Success records Maintenance_BC_IALL and its exact operand token.
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

- bc.iall
