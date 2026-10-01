<!-- GENERATED FROM: asl/scalar/sys/DC.CIVA.asl -->
# DC.CIVA

**Normative ASL source:** `asl/scalar/sys/DC.CIVA.asl`

DC.CIVA completes the data-cache clean-and-invalidate scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-CIVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-civa-purpose role=purpose -->
## What DC.CIVA does

`DC.CIVA` completes the data-cache clean-and-invalidate scope-token maintenance operation synchronously. Unusually for the data-cache group, the operand is a scope token rather than an address: the instruction reads `SrcL` and records it, but the portable model never interprets it as a memory location.

<!-- PTO-READER-BLOCK: scalar-dc-civa-mechanism role=mechanism -->
## System mechanism

`InstructionContractHandler_DC_CIVA` returns `ScalarHandler_ExecuteMaintenance` (`asl/scalar/sys/DC.CIVA.asl:11`), and `InstructionContractMaintenanceOperation_DC_CIVA` fixes the token recorded for a successful attempt to `Maintenance_DC_CIVA` (`asl/scalar/sys/DC.CIVA.asl:23`). The executor itself is shared: `ExecuteMaintenance` dispatches on the operation token, and `Maintenance_DC_CIVA` sits in the data-cache group that advances `_DataCacheEpoch` (`asl/scalar/model/sys/semantics.asl:134`).

Like the other fifteen instructions that share this handler, `DC.CIVA` is applicable only inside an active SYS block body (`asl/scalar/model/sys/semantics.asl:322`).

<!-- PTO-READER-BLOCK: scalar-dc-civa-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SrcL` is the single encoded operand, a Reg5 source drawn from R0..R23, T#1..T#4, or U#1..U#4. `DC.CIVA` has no destination field, so no register or queue receives a result.

Encoded zero in `SrcL` selects the architectural zero GPR. It is a real operand value, and it is not an omission marker.

<!-- PTO-READER-BLOCK: scalar-dc-civa-effects role=effects -->
## Architectural effects

A successful attempt advances the data-cache epoch exactly once and stores `Maintenance_DC_CIVA` plus the operand token in the maintenance record. `TPC` advances afterwards, as the common dispatch tail advances it only for an attempt that reported success (`asl/scalar/model/dispatch/top-level.asl:55`).

Design point: the record is written only when the attempt is still fault-free, so a rejected `DC.CIVA` leaves the previous operation and operand visible in the record. Code that reads the record therefore sees the last attempt that actually completed.

Nothing else in the architectural state moves. `DC.CIVA` performs no ordinary scalar memory access, writes no register or queue, and defines no cache contents.

<!-- PTO-READER-BLOCK: scalar-dc-civa-constraints role=constraints -->
## Placement and rejection

Two checks protect the effect. The first is placement: outside an active SYS block body the attempt raises `Fault_BundleControl` (`asl/scalar/model/dispatch/top-level.asl:28`) and stops before the legality pass. The second is encoded legality: fixed bits and the Reg5 encoding are validated before the executor is called.

All eight data-cache operations, `DC.CIVA` included, are permitted at every access ring (`asl/scalar/model/sys/semantics.asl:115`). The only maintenance operations that need ring 0 are the four TLB ones, so `DC.CIVA` raises no privilege fault on a non-root ring.

<!-- PTO-READER-BLOCK: scalar-dc-civa-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Inside a SYS block body, execute `dc.civa SrcL`. The attempt checks placement and encoding, reads `SrcL` into the operand, advances the data-cache epoch by one, and records `Maintenance_DC_CIVA` with that operand. The operand value itself never reaches the memory system.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dc.civa SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_civa_32_265d686549c8 | L32 | 32 | 0x0030602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_civa_32_265d686549c8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dc_civa_32_265d686549c8 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.CIVA.asl -->
```asl
readonly func InstructionContractOperation_DC_CIVA()
    => ScalarOperation
begin
    return ScalarOperation_DC_CIVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.CIVA executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.CIVA.asl -->
```asl
readonly func InstructionContractHandler_DC_CIVA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_CIVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_CIVA()
    => MaintenanceOperation
begin
    return Maintenance_DC_CIVA;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_CIVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_CIVA()
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

- Success records Maintenance_DC_CIVA and its exact operand token.
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

- dc.civa SrcL
