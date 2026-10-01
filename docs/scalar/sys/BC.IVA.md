<!-- GENERATED FROM: asl/scalar/sys/BC.IVA.asl -->
# BC.IVA

**Normative ASL source:** `asl/scalar/sys/BC.IVA.asl`

BC.IVA completes the bundle-cache virtual-address scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-BC-IVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bc-iva-purpose role=purpose -->
## What BC.IVA does

`BC.IVA` is the bundle-cache maintenance operation for a virtual-address scope. It completes synchronously as one scalar operation of a SYS block and advances the bundle-cache epoch.

The address it carries is the scope token: it selects which entries the maintenance applies to.

<!-- PTO-READER-BLOCK: scalar-bc-iva-mechanism role=mechanism -->
## How the instruction is placed and executed

This instruction is one scalar operation of an active SYS block. The scalar dispatcher first checks that a bundle is active and that its body is active with block kind System; a SYS form outside such a block is rejected with `Fault_BundleControl`, before any encoded-field check and before any architectural effect.

Encoded legality and source availability are then checked, and only then does the handler run.

The handler reads `SrcL` and runs the shared maintenance rule for the `Maintenance_BC_IVA` operation with that value as its operand. The rule first asks whether the operation is permitted at the current ring.

The all-entry cache scopes are local hints and are permitted at every ring; a virtual-address cache scope is in the same class, because only the translation scopes are restricted. The rule therefore advances the bundle-cache epoch, and on success records the operation together with the operand token it was given.

Design point: the operand is retained as the recorded maintenance operand rather than consumed by the epoch update. That keeps an address-scoped hint inspectable after the fact: the epoch says that bundle-cache maintenance completed, and the recorded token says which address scope it named.

<!-- PTO-READER-BLOCK: scalar-bc-iva-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

- `SrcL` is the source selector that supplies the scope token.
- Source selectors `0`..`23` read GPRs, `24`..`27` read `T#1`..`T#4`, and `28`..`31` read `U#1`..`U#4`. Reading a temporary never consumes or reorders it.
- Source selector `0` always reads XLEN zero, and that zero is a legal scope token: the operation is not rejected because the token is zero.
- There is no destination field, so the instruction never writes a GPR and never pushes `T` or `U`.

<!-- PTO-READER-BLOCK: scalar-bc-iva-effects role=effects -->
## Architectural effects

On success exactly one epoch advances, and for this operation it is the bundle-cache epoch. One data-cache, one instruction-cache, one bundle-cache and one TLB epoch exist in the model, and a maintenance operation that completes advances exactly one of them.

The instruction performs no ordinary scalar memory access: it does not load, store, or probe the address it carries, so a token that names no mapped memory does not raise a data-access fault. `TPC` advances by `4` bytes on success. No reservation is taken or dropped.

<!-- PTO-READER-BLOCK: scalar-bc-iva-constraints role=constraints -->
## Placement and rejection

Invalid block placement is rejected first, with `Fault_BundleControl`, before the encoded field is even considered.

A virtual-address cache scope is a local hint completion, so the maintenance permission rule accepts it at every ring; the ring restriction applies only to translation maintenance. The reachable `Fault_IllegalInstruction` paths for this form are therefore the placement and encoded-legality checks, not a ring restriction.

A source selector that names an unavailable `T` or `U` slot is rejected before the maintenance rule runs, so such a selector never advances an epoch.

<!-- PTO-READER-BLOCK: scalar-bc-iva-example role=example -->
## Non-normative example

`bc.iva a0` reads the scope token from `a0`, advances the bundle-cache epoch by one, records `Maintenance_BC_IVA` with that token, and advances `TPC` by `4` bytes. If the source selector is unavailable, no epoch advances and the instruction is rejected instead.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bc.iva SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bc_iva_32_c166de534c98 | L32 | 32 | 0x0000402b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bc_iva_32_c166de534c98 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bc_iva_32_c166de534c98 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/BC.IVA.asl -->
```asl
readonly func InstructionContractOperation_BC_IVA()
    => ScalarOperation
begin
    return ScalarOperation_BC_IVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BC.IVA executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/BC.IVA.asl -->
```asl
readonly func InstructionContractHandler_BC_IVA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_BC_IVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_BC_IVA()
    => MaintenanceOperation
begin
    return Maintenance_BC_IVA;
end;

pure func InstructionContractMaintenanceUsesOperand_BC_IVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_BC_IVA()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- Cache maintenance is a local synchronous hint completion at every ACR.

## State effects

- Success records Maintenance_BC_IVA and its exact operand token.
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

- bc.iva SrcL
