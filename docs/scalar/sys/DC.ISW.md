<!-- GENERATED FROM: asl/scalar/sys/DC.ISW.asl -->
# DC.ISW

**Normative ASL source:** `asl/scalar/sys/DC.ISW.asl`

DC.ISW completes the data-cache set/way scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-ISW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-isw-purpose role=purpose -->
## What DC.ISW does

`DC.ISW` performs the data-cache set/way scope-token maintenance operation and completes it synchronously. The token comes from the single source operand `SrcL` (`asl/scalar/sys/DC.ISW.asl:29`), which the instruction snapshots and records.

<!-- PTO-READER-BLOCK: scalar-dc-isw-mechanism role=mechanism -->
## System mechanism

The instruction is bound to the maintenance handler (`asl/scalar/sys/DC.ISW.asl:11`) and to `Maintenance_DC_ISW` (`asl/scalar/sys/DC.ISW.asl:23`). The executor's privilege table treats that token as a cache operation, and its operation table places it in the data-cache group that advances `_DataCacheEpoch` (`asl/scalar/model/sys/semantics.asl:134`).

`DC.ISW` is one scalar operation in an active SYS block body. The applicability rule that enforces this reads the active bundle and its block kind, not the decoded operand (`asl/scalar/model/sys/semantics.asl:321`).

<!-- PTO-READER-BLOCK: scalar-dc-isw-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SrcL` is a Reg5 source: R0..R23, T#1..T#4, or U#1..U#4. The decoded value is captured before the effect and passed to the executor as the operand (`asl/scalar/model/dispatch/sys.asl:27`).

There is no destination operand, so the operand value is published only into the maintenance record. Encoded zero selects the architectural zero GPR and is a usable token value rather than an omission.

<!-- PTO-READER-BLOCK: scalar-dc-isw-effects role=effects -->
## Architectural effects

On success, `_DataCacheEpoch` increases by one and the maintenance record is set to `Maintenance_DC_ISW` plus the captured operand (`asl/scalar/model/sys/semantics.asl:137`). `TPC` advances by the instruction length afterwards, from the dispatcher's success tail (`asl/scalar/model/dispatch/top-level.asl:56`).

Design point: the epoch and the record are separate observables. The epoch says a data-cache maintenance step completed; the record says which operation and which token caused it. Reading only the epoch cannot distinguish `DC.ISW` from `DC.CVA`.

No scalar memory access, register write, or queue push accompanies the operation.

<!-- PTO-READER-BLOCK: scalar-dc-isw-constraints role=constraints -->
## Placement and rejection

Placement and encoding are checked before the executor is entered. An attempt outside an active SYS block body raises `Fault_BundleControl` at the active block's `TPC` value (`asl/scalar/model/dispatch/top-level.asl:28`), and the record and epoch are left untouched.

Ring permission does not constrain `DC.ISW`, because only the TLB maintenance operations reject a non-root ring (`asl/scalar/model/sys/semantics.asl:121`). The recorded token is never bounds-checked against a modelled set or way count.

<!-- PTO-READER-BLOCK: scalar-dc-isw-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Run `dc.isw SrcL` in a SYS block body with the source holding 0x21. The attempt passes placement and encoding, snapshots 0x21, advances the data-cache epoch by one, and leaves the record holding `Maintenance_DC_ISW` with operand 0x21. Running the same sequence at any access ring gives the same result, since the operation is not ring-restricted.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dc.isw SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_isw_32_7940273560b2 | L32 | 32 | 0x0040602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_isw_32_7940273560b2 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dc_isw_32_7940273560b2 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.ISW.asl -->
```asl
readonly func InstructionContractOperation_DC_ISW()
    => ScalarOperation
begin
    return ScalarOperation_DC_ISW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.ISW executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.ISW.asl -->
```asl
readonly func InstructionContractHandler_DC_ISW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_ISW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_ISW()
    => MaintenanceOperation
begin
    return Maintenance_DC_ISW;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_ISW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_ISW()
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

- Success records Maintenance_DC_ISW and its exact operand token.
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

- dc.isw SrcL
