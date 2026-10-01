<!-- GENERATED FROM: asl/scalar/sys/DC.CSW.asl -->
# DC.CSW

**Normative ASL source:** `asl/scalar/sys/DC.CSW.asl`

DC.CSW completes the data-cache clean-by-set/way scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-CSW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-csw-purpose role=purpose -->
## What DC.CSW does

`DC.CSW` performs the data-cache clean-by-set/way scope-token maintenance operation and completes it synchronously, so the attempt is finished when the instruction retires. Its single operand, `SrcL`, carries the token that identifies the scope the request was issued for (`asl/scalar/sys/DC.CSW.asl:29`).

<!-- PTO-READER-BLOCK: scalar-dc-csw-mechanism role=mechanism -->
## System mechanism

The instruction is bound to the shared maintenance handler (`asl/scalar/sys/DC.CSW.asl:11`) and to the operation token `Maintenance_DC_CSW` (`asl/scalar/sys/DC.CSW.asl:23`). `ExecuteMaintenance` compares that token against the privilege table and the operation table, and the `Maintenance_DC_CSW` case is one of the eight data-cache cases that advance `_DataCacheEpoch` (`asl/scalar/model/sys/semantics.asl:134`).

This is a System-block instruction. Its applicability rule requires the bundle to be active with an active body of block kind `BundleKind_System` (`asl/scalar/model/sys/semantics.asl:321`).

<!-- PTO-READER-BLOCK: scalar-dc-csw-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SrcL` is a Reg5 source: R0..R23, T#1..T#4, or U#1..U#4. The dispatcher captures the decoded register value and hands it to the executor as the operand (`asl/scalar/model/dispatch/sys.asl:39`).

`DC.CSW` writes no destination. It records the operand instead of returning it, and encoded zero is an assigned value, not an omitted operand.

<!-- PTO-READER-BLOCK: scalar-dc-csw-effects role=effects -->
## Architectural effects

On a fault-free attempt the data-cache epoch increases by one and the maintenance record is overwritten with `Maintenance_DC_CSW` and the operand value. The record update is guarded by the fault check inside the executor, so a faulting attempt does not touch it (`asl/scalar/model/sys/semantics.asl:156`).

Design point: instruction completion is modelled as an epoch step plus a recorded token. That gives software a defined, observable completion point without constraining how many cache lines an implementation actually cleans.

`TPC` advances after the attempt reports success; the increment is worth one instruction length, not one epoch (`asl/scalar/model/dispatch/top-level.asl:56`).

<!-- PTO-READER-BLOCK: scalar-dc-csw-constraints role=constraints -->
## Placement and rejection

A `DC.CSW` outside an active SYS block body is rejected with `Fault_BundleControl` before operand legality is evaluated, so neither the epoch nor the record changes. Inside the block body the fixed bits and the `SrcL` encoding are validated before the executor runs.

Data-cache maintenance carries no ring restriction: `MaintenanceAccessPermitted` returns `TRUE` for every operation except the four TLB ones (`asl/scalar/model/sys/semantics.asl:123`). There is therefore no `Fault_IllegalInstruction` path in `DC.CSW` for ring, address, or access class.

<!-- PTO-READER-BLOCK: scalar-dc-csw-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Execute `dc.csw SrcL` from a SYS block body with the source register holding the token 7. Placement and encoding pass, the register is snapshotted, the data-cache epoch advances by one, and the maintenance record then reads `Maintenance_DC_CSW` with operand 7. Repeating the same instruction advances the epoch again and rewrites the record with the same token.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dc.csw SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_csw_32_2719115a9246 | L32 | 32 | 0x0050602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_csw_32_2719115a9246 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dc_csw_32_2719115a9246 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.CSW.asl -->
```asl
readonly func InstructionContractOperation_DC_CSW()
    => ScalarOperation
begin
    return ScalarOperation_DC_CSW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.CSW executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.CSW.asl -->
```asl
readonly func InstructionContractHandler_DC_CSW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_CSW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_CSW()
    => MaintenanceOperation
begin
    return Maintenance_DC_CSW;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_CSW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_CSW()
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

- Success records Maintenance_DC_CSW and its exact operand token.
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

- dc.csw SrcL
