<!-- GENERATED FROM: asl/scalar/sys/DC.IVA.asl -->
# DC.IVA

**Normative ASL source:** `asl/scalar/sys/DC.IVA.asl`

DC.IVA completes the data-cache virtual-address scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-IVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-iva-purpose role=purpose -->
## What DC.IVA does

`DC.IVA` is the data-cache clean-and-invalidate by virtual address operation. The address travels in the single Reg5 source `SrcL`, and the instruction records the operation token and that operand when it completes (`asl/scalar/sys/DC.IVA.asl:23`).

<!-- PTO-READER-BLOCK: scalar-dc-iva-mechanism role=mechanism -->
## System mechanism

The DOC region binds the instruction to `ScalarHandler_ExecuteMaintenance` (`asl/scalar/sys/DC.IVA.asl:11`), and the operation token `Maintenance_DC_IVA` selects the data-cache case inside the executor (`asl/scalar/model/sys/semantics.asl:134`). The dispatcher reads the source register for this form, because `InstructionContractMaintenanceUsesOperand_DC_IVA` is `TRUE` (`asl/scalar/sys/DC.IVA.asl:29`).

Block placement is part of the applicability rule: the bundle must be active and its body must be a System block before operand legality is even considered (`asl/scalar/model/sys/semantics.asl:321`).

<!-- PTO-READER-BLOCK: scalar-dc-iva-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SrcL` accepts the Reg5 source encodings R0..R23, T#1..T#4, and U#1..U#4, and supplies the virtual address of the request. The instruction has no destination field.

The only output is the maintenance record entry. Encoded zero in `SrcL` names the architectural zero GPR, so a zero address is expressed by naming that register rather than by omitting the operand.

<!-- PTO-READER-BLOCK: scalar-dc-iva-effects role=effects -->
## Architectural effects

The attempt advances the data-cache epoch once and then writes `Maintenance_DC_IVA` and the snapshotted operand into the maintenance record, provided no fault was raised (`asl/scalar/model/sys/semantics.asl:156`). `TPC` advances after the attempt reports success (`asl/scalar/model/dispatch/top-level.asl:56`).

The address is recorded, not used: `DC.IVA` performs no ordinary scalar memory access, so a subsequent load or store to the same virtual address sees unchanged memory. No register, temporary queue, or system register is written.

<!-- PTO-READER-BLOCK: scalar-dc-iva-constraints role=constraints -->
## Placement and rejection

An attempt outside an active SYS block body raises `Fault_BundleControl` before the handler, so neither the epoch nor the record is modified. Inside the body, the fixed bits and the `SrcL` selector are validated before the executor runs.

`DC.IVA` imposes no ring gate and no address-shape gate. The data-cache operations are permitted at every ACR, and the canonical-address test belongs to the TLB operations only (`asl/scalar/model/sys/semantics.asl:115`). Even an operand with high bits set is recorded rather than rejected.

Design point: the same handler serves address-based and token-based data-cache requests. Keeping the caller's operand verbatim in the record is what lets the two kinds of request be told apart afterwards.

<!-- PTO-READER-BLOCK: scalar-dc-iva-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

With a GPR holding 0x1234, `dc.iva SrcL` in a SYS block body snapshots 0x1234, advances the data-cache epoch by one, and records `Maintenance_DC_IVA` with operand 0x1234. An operand such as 0xffff000000001234 is accepted by the same path and recorded unchanged, because only the TLB operations test address canonicality.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dc.iva SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_iva_32_0131d0cf364f | L32 | 32 | 0x0000602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_iva_32_0131d0cf364f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dc_iva_32_0131d0cf364f | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.IVA.asl -->
```asl
readonly func InstructionContractOperation_DC_IVA()
    => ScalarOperation
begin
    return ScalarOperation_DC_IVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.IVA executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.IVA.asl -->
```asl
readonly func InstructionContractHandler_DC_IVA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_IVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_IVA()
    => MaintenanceOperation
begin
    return Maintenance_DC_IVA;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_IVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_IVA()
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

- Success records Maintenance_DC_IVA and its exact operand token.
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

- dc.iva SrcL
