<!-- GENERATED FROM: asl/scalar/sys/DC.ZVA.asl -->
# DC.ZVA

**Normative ASL source:** `asl/scalar/sys/DC.ZVA.asl`

DC.ZVA completes the data-cache zero-by-address scope token maintenance operation synchronously.

## Normative identity {#PTO-INST-SCALAR-DC-ZVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dc-zva-purpose role=purpose -->
## What DC.ZVA does

`DC.ZVA` is the data-cache zero-by-address operation. It takes the target address from `SrcL` and completes synchronously, recording the operation token `Maintenance_DC_ZVA` and the exact operand (`asl/scalar/sys/DC.ZVA.asl:23`).

<!-- PTO-READER-BLOCK: scalar-dc-zva-mechanism role=mechanism -->
## System mechanism

`InstructionContractHandler_DC_ZVA` selects the shared maintenance handler (`asl/scalar/sys/DC.ZVA.asl:11`), and `InstructionContractMaintenanceUsesOperand_DC_ZVA` returning `TRUE` makes the dispatcher read the source register before the call (`asl/scalar/model/dispatch/sys.asl:30`).

The executor's data-cache group contains all eight `DC.*` operations, so `Maintenance_DC_ZVA` advances `_DataCacheEpoch` rather than installing a modelled zero block (`asl/scalar/model/sys/semantics.asl:134`).

The instruction is applicable only in an active SYS block body (`asl/scalar/model/sys/semantics.asl:322`).

<!-- PTO-READER-BLOCK: scalar-dc-zva-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SrcL` is a Reg5 source: R0..R23, T#1..T#4, or U#1..U#4. Its value is the address whose block the request names.

There is no destination. The captured address is published only as the operand field of the maintenance record, and encoded zero means the architectural zero GPR, not an omitted operand.

<!-- PTO-READER-BLOCK: scalar-dc-zva-effects role=effects -->
## Architectural effects

A successful attempt increases the data-cache epoch by one and replaces the maintenance record with `Maintenance_DC_ZVA` and the operand (`asl/scalar/model/sys/semantics.asl:137`). The record update is skipped when a fault was raised, so the record is never half-written.

Design point: modelling zeroing as an epoch step keeps the instruction from acquiring a memory result. A subsequent ordinary load from the same address is a normal memory access with no defined relationship to this instruction's epoch, so software cannot observe a zero-filled location through `DC.ZVA` alone.

The attempt performs no ordinary scalar memory access and writes no register or queue. `TPC` advances by the instruction length after success.

<!-- PTO-READER-BLOCK: scalar-dc-zva-constraints role=constraints -->
## Placement and rejection

The first gate is placement inside an active SYS block body; failure raises `Fault_BundleControl` and leaves the executor untouched. The second is the fixed-bit and Reg5 encoding check, which runs before the handler.

No access-ring restriction applies to any `DC.*` operation (`asl/scalar/model/sys/semantics.asl:123`), and the address operand is not required to be canonical, because only `TLB.IV` and `TLB.IAV` test canonical form.

<!-- PTO-READER-BLOCK: scalar-dc-zva-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Run `dc.zva SrcL` with the source register holding 0x2000. The attempt checks placement and encoding, snapshots 0x2000, advances the data-cache epoch by one, and records `Maintenance_DC_ZVA` with operand 0x2000. No memory location changes, so a load from 0x2000 afterwards is served by the ordinary memory path.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dc.zva SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_zva_32_0859a1d7aa5b | L32 | 32 | 0x0070602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_zva_32_0859a1d7aa5b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dc_zva_32_0859a1d7aa5b | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.ZVA.asl -->
```asl
readonly func InstructionContractOperation_DC_ZVA()
    => ScalarOperation
begin
    return ScalarOperation_DC_ZVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
DC.ZVA executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.ZVA.asl -->
```asl
readonly func InstructionContractHandler_DC_ZVA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;

pure func InstructionContractRequiresSystemBlock_DC_ZVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceOperation_DC_ZVA()
    => MaintenanceOperation
begin
    return Maintenance_DC_ZVA;
end;

pure func InstructionContractMaintenanceUsesOperand_DC_ZVA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractMaintenanceRequiresRootRing_DC_ZVA()
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

- Success records Maintenance_DC_ZVA and its exact operand token.
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

- dc.zva SrcL
