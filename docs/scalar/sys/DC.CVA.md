<!-- GENERATED FROM: asl/scalar/sys/DC.CVA.asl -->
# DC.CVA

**Normative ASL source:** `asl/scalar/sys/DC.CVA.asl`

DC.CVA completes the data-cache clean-by-address scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-CVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-cva-purpose role=purpose -->
## What DC.CVA does

`DC.CVA` is the data-cache clean by address operation. It takes the address to clean from `SrcL` and completes the request synchronously, recording both the operation and the exact operand token (`asl/scalar/sys/DC.CVA.asl:23`).

<!-- PTO-READER-BLOCK: scalar-dc-cva-mechanism role=mechanism -->
## System mechanism

`InstructionContractHandler_DC_CVA` selects `ScalarHandler_ExecuteMaintenance`, the one handler shared by the whole cache and translation maintenance group (`asl/scalar/sys/DC.CVA.asl:11`). What makes this instruction distinct is its operation token: `Maintenance_DC_CVA` selects the data-cache branch of `ExecuteMaintenance`, which advances `_DataCacheEpoch` by one (`asl/scalar/model/sys/semantics.asl:135`).

Placement is part of the mechanism rather than an afterthought. The instruction is applicable only in an active SYS block body, and the dispatcher rejects everything else before the handler is reached (`asl/scalar/model/sys/semantics.asl:321`).

<!-- PTO-READER-BLOCK: scalar-dc-cva-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SrcL` carries a Reg5 source, one of R0..R23, T#1..T#4, or U#1..U#4. Because `DC.CVA` is clean-by-address, that register supplies the address used for the request.

The instruction has no destination operand. Its output is the maintenance record entry, which stores the operand value as captured before the epoch advanced.

<!-- PTO-READER-BLOCK: scalar-dc-cva-effects role=effects -->
## Architectural effects

The executor increments the data-cache epoch, then, only when no fault has been raised, stores `Maintenance_DC_CVA` and the operand into the maintenance record (`asl/scalar/model/sys/semantics.asl:156`). The dispatcher's common tail then advances `TPC` by the instruction length (`asl/scalar/model/dispatch/top-level.asl:56`).

The instruction performs no ordinary scalar memory access. A load or store to the same address is unaffected, and no destination register or temporary queue is written.

Design point: an address-based maintenance request is recorded rather than executed against a modelled cache, so the observable contract is the epoch advance and the recorded token, not a specific cache line state.

<!-- PTO-READER-BLOCK: scalar-dc-cva-constraints role=constraints -->
## Placement and rejection

Placement comes first: outside an active SYS block body, the attempt raises `Fault_BundleControl` (`asl/scalar/model/dispatch/top-level.asl:28`) and no executor state is touched. Encoded legality follows, covering the fixed bits and the `SrcL` selector.

Ring permission is not a constraint here. `MaintenanceAccessPermitted` grants the data-cache operations at every ACR and reserves ring 0 for the TLB operations (`asl/scalar/model/sys/semantics.asl:120`). The address in `SrcL` is likewise not range-checked, because this operation is not the canonical-address path.

<!-- PTO-READER-BLOCK: scalar-dc-cva-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

With a GPR holding 0x1234, `dc.cva SrcL` inside a SYS block body snapshots 0x1234, advances the data-cache epoch once, and leaves the maintenance record holding `Maintenance_DC_CVA` with operand 0x1234. Nothing validates 0x1234 against an address rule, and nothing restricts the instruction to a particular ring.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dc.cva SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_cva_32_166d5a076f0e | L32 | 32 | 0x0020602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_cva_32_166d5a076f0e | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dc_cva_32_166d5a076f0e | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.CVA.asl -->
```asl
readonly func InstructionContractOperation_DC_CVA()
    => ScalarOperation
begin
    return ScalarOperation_DC_CVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.CVA executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.CVA.asl -->
```asl
readonly func InstructionContractHandler_DC_CVA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_CVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_CVA()
    => MaintenanceOperation
begin
    return Maintenance_DC_CVA;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_CVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_CVA()
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

- Success records Maintenance_DC_CVA and its exact operand token.
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

- dc.cva SrcL
