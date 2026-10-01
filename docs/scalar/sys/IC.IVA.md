<!-- GENERATED FROM: asl/scalar/sys/IC.IVA.asl -->
# IC.IVA

**Normative ASL source:** `asl/scalar/sys/IC.IVA.asl`

IC.IVA completes the instruction-cache virtual-address scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-IC-IVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ic-iva-purpose role=purpose -->
## What IC.IVA does

`IC.IVA` performs the instruction-cache virtual-address scope-token maintenance operation and completes it synchronously. The scope token arrives in the single source operand `SrcL`, which the instruction captures and records (`asl/scalar/sys/IC.IVA.asl:29`).

<!-- PTO-READER-BLOCK: scalar-ic-iva-mechanism role=mechanism -->
## System mechanism

The instruction is bound to `ScalarHandler_ExecuteMaintenance` (`asl/scalar/sys/IC.IVA.asl:11`) and to the token `Maintenance_IC_IVA` (`asl/scalar/sys/IC.IVA.asl:23`). Inside `ExecuteMaintenance` that token selects the instruction-cache case, which advances `_InstructionCacheEpoch` exactly once (`asl/scalar/model/sys/semantics.asl:138`).

Placement is enforced by applicability: the bundle must be active with a System block body, otherwise the attempt stops before operand legality (`asl/scalar/model/sys/semantics.asl:321`).

<!-- PTO-READER-BLOCK: scalar-ic-iva-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SrcL` accepts the Reg5 source encodings R0..R23, T#1..T#4, and U#1..U#4, and supplies the address token for the request. The instruction has no destination operand, so no result is published to a register or queue.

Encoded zero selects the architectural zero GPR. It is an assigned value, and the zero token is recorded like any other.

<!-- PTO-READER-BLOCK: scalar-ic-iva-effects role=effects -->
## Architectural effects

After a successful attempt the instruction-cache epoch is one higher and the maintenance record reads `Maintenance_IC_IVA` with the snapshotted operand (`asl/scalar/model/sys/semantics.asl:156`). `TPC` then advances by the instruction length.

Design point: the token is recorded rather than range-checked. The portable model exposes one epoch and one record for instruction-cache maintenance, so the recorded operand is what preserves the caller's scope information.

`IC.IVA` performs no ordinary scalar memory access and does not itself make any instruction byte visible; the epoch is the observable point. No register, queue, or system register is written.

<!-- PTO-READER-BLOCK: scalar-ic-iva-constraints role=constraints -->
## Placement and rejection

Two gates precede the effect. An attempt outside an active SYS block body raises `Fault_BundleControl` and returns without touching the executor. Inside the body, the fixed bits and the `SrcL` selector are validated before the handler runs.

There is no ring gate for instruction-cache maintenance and no canonical-address requirement. Only `TLB.IV` and `TLB.IAV` test canonical form, and only the TLB operations require ring 0 (`asl/scalar/model/sys/semantics.asl:115`).

<!-- PTO-READER-BLOCK: scalar-ic-iva-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

With the source register holding 0x1234, `ic.iva SrcL` in a SYS block body snapshots 0x1234, advances the instruction-cache epoch by one, and records `Maintenance_IC_IVA` with operand 0x1234. The same instruction executed at any access ring behaves identically, because instruction-cache maintenance is not ring-restricted.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ic.iva SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ic_iva_32_11b9a61dd8b5 | L32 | 32 | 0x0000502b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ic_iva_32_11b9a61dd8b5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ic_iva_32_11b9a61dd8b5 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/IC.IVA.asl -->
```asl
readonly func InstructionContractOperation_IC_IVA()
    => ScalarOperation
begin
    return ScalarOperation_IC_IVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
IC.IVA executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/IC.IVA.asl -->
```asl
readonly func InstructionContractHandler_IC_IVA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_IC_IVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_IC_IVA()
    => MaintenanceOperation
begin
    return Maintenance_IC_IVA;
end;

pure func InstructionContractMaintenanceUsesOperand_IC_IVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_IC_IVA()
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

- Success records Maintenance_IC_IVA and its exact operand token.
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

- ic.iva SrcL
