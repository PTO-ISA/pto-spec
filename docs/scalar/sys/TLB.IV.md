<!-- GENERATED FROM: asl/scalar/sys/TLB.IV.asl -->
# TLB.IV

**Normative ASL source:** `asl/scalar/sys/TLB.IV.asl`

TLB.IV completes the canonical 48-bit virtual address maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-TLB-IV}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-tlb-iv-purpose role=purpose -->
## What TLB.IV does

`TLB.IV` completes the canonical 48-bit virtual address translation-maintenance operation synchronously. It is the plain address form: the address to invalidate arrives in `SrcL`, and the attempt is accepted only when that value is a canonical 48-bit virtual address and the current ring is ACR0.

<!-- PTO-READER-BLOCK: scalar-tlb-iv-mechanism role=mechanism -->
## System mechanism

`InstructionContractHandler_TLB_IV` selects the shared maintenance handler (`asl/scalar/sys/TLB.IV.asl:18`), and `InstructionContractMaintenanceRequiresRootRing_TLB_IV` returning `TRUE` (`asl/scalar/sys/TLB.IV.asl:42`) is what puts this operation in the executor's ring-restricted group (`asl/scalar/model/sys/semantics.asl:121`). The dispatcher reads `SrcL` for this form because `InstructionContractMaintenanceUsesOperand_TLB_IV` is `TRUE` (`asl/scalar/model/dispatch/sys.asl:50`).

Order inside the executor is privilege first, operand second: the ring check runs before the canonical-address test, and each failure has its own fault class (`asl/scalar/model/sys/semantics.asl:129`).

<!-- PTO-READER-BLOCK: scalar-tlb-iv-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SrcL` is a Reg5 source: R0..R23, T#1..T#4, or U#1..U#4. Its value is the virtual address operand, tested by `IsCanonicalAddress48`, which requires bits 63:48 to be all zeros when bit 47 is 0 and all ones when bit 47 is 1 (`asl/scalar/model/sys/semantics.asl:108`).

There is no destination operand. On success the operand is published only into the maintenance record, and encoded zero names the architectural zero GPR.

<!-- PTO-READER-BLOCK: scalar-tlb-iv-effects role=effects -->
## Architectural effects

A successful attempt advances the TLB epoch by exactly one and records `Maintenance_TLB_IV` with the address operand (`asl/scalar/model/sys/semantics.asl:146`). `TPC` then advances by the instruction length, because a fault-free attempt reports success to the dispatcher.

Design point: a rejected operand leaves the TLB epoch unchanged, and the record is only written when the attempt is fault-free (`asl/scalar/model/sys/semantics.asl:156`). A non-canonical request therefore cannot look like a completed invalidation to a reader of the epoch or the record.

The instruction performs no ordinary scalar memory access, so no page table or data memory is touched.

<!-- PTO-READER-BLOCK: scalar-tlb-iv-constraints role=constraints -->
## Placement and rejection

Placement is checked first by the dispatcher: outside an active SYS block body the attempt raises `Fault_BundleControl` and the executor never runs. Inside the body the fixed bits and `SrcL` selector are validated before the call.

The executor then applies two rejections of its own. A current ring other than ACR0 raises `Fault_IllegalInstruction`. A ring-0 attempt whose operand is not canonical raises `Fault_DataPage` with that operand as the trap argument and leaves the epoch unchanged (`asl/scalar/model/sys/semantics.asl:143`).

Design point: translation maintenance is manager state, so it is confined to the root ring, while the address-shaped operand keeps its own page-fault class. Distinguishing the two rejections lets a handler tell a privilege failure from a malformed address.

<!-- PTO-READER-BLOCK: scalar-tlb-iv-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

At ACR0, with a GPR holding 0x1234, `tlb.iv SrcL` snapshots 0x1234, passes the canonical test because bits 63:48 are clear, advances the TLB epoch by one, and records `Maintenance_TLB_IV` with operand 0x1234. The same instruction on ring ACR1 raises `Fault_IllegalInstruction` without reading the canonical form of the operand.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
tlb.iv SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| tlb_iv_32_bf0a5d1ea211 | L32 | 32 | 0x0010702b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| tlb_iv_32_bf0a5d1ea211 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| tlb_iv_32_bf0a5d1ea211 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/TLB.IV.asl -->
```asl
readonly func InstructionContractOperation_TLB_IV()
    => ScalarOperation
begin
    return ScalarOperation_TLB_IV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
TLB.IV executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/TLB.IV.asl -->
```asl
readonly func InstructionContractHandler_TLB_IV()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_TLB_IV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_TLB_IV()
    => MaintenanceOperation
begin
    return Maintenance_TLB_IV;
end;

pure func InstructionContractMaintenanceUsesOperand_TLB_IV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_TLB_IV()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- TLB maintenance is assigned only at ACR0 and rejects at every other ring before operand validation.
- The operand must be a canonical 48-bit virtual address.

## State effects

- Success records Maintenance_TLB_IV and its exact operand token.
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

- tlb.iv SrcL
