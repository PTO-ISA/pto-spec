<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
# MGATHER_CAS

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl`

Atomically compare and conditionally replace GM elements at signed or unsigned byte displacements.

## Normative identity {#PTO-INST-TILE-MGATHER-CAS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mgather-cas-purpose role=purpose -->
## What MGATHER_CAS does

`MGATHER_CAS` is a selector-encoded Tile operation executed by `TLSU`. It uses index, expected, and replacement Tiles to perform per-element GM compare-and-swap and records each observed old value; its current instruction contract owns the exact bundle form and publication boundary.

<!-- PTO-READER-BLOCK: tile-mgather-cas-mechanism role=mechanism -->
## Element and Tile mechanism

After all descriptor and operand checks succeed, the owning ASL handler uses index, expected, and replacement Tiles to perform per-element GM compare-and-swap and records each observed old value. Source payloads are snapshotted before destination writes whenever the contract permits aliasing.

The handler uses the resolved valid region rather than treating physical padding as input data. Its operation-specific dtype, layout, rounding, saturation, and profile hooks remain the executable definition.

<!-- PTO-READER-BLOCK: tile-mgather-cas-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `destination0` has the exact contract role **observed-old-values destination**.
- `address` has the exact contract role **base-address**.
- `source0` has the exact contract role **byte-displacement indices**.
- `source1` has the exact contract role **expected values**.
- `source2` has the exact contract role **replacement values**.

Every source coordinate read by the operation must be defined before execution reaches destination publication.
`PE_MASK=0000` is a strict no-op before descriptor, allocation, payload, numeric-status, or memory effects.

<!-- PTO-READER-BLOCK: tile-mgather-cas-effects role=effects -->
## Publication, definedness, and padding

After complete atomic-address preflight, the selected PadValue carrier initializes every physical destination coordinate; observed old values then overwrite valid coordinates.

On success the full physical destination is marked defined and `contents_defined=TRUE`; payload, definedness, and descriptor publish together.

The operation preflights every enabled GM address before the first load, atomic event, or destination update; a failed access leaves no partial destination or event.

<!-- PTO-READER-BLOCK: tile-mgather-cas-constraints role=constraints -->
## Type, layout, and fault boundary

Index Tiles use `S32`, `U32`, `S64`, or `U64`. Packed four-bit transfer types `E2M1X2`, `E1M2X2`, `HiF4X2`, `S4X2`, and `U4X2` are rejected because this indexed transfer has no nibble selector.

The generated legality and exception sections below are authoritative for dtype pairs, layout, dimensions, capacity, definedness, padding controls, profile behavior, and fault class. Legality and allocation failures occur before partial architectural effects.

<!-- PTO-READER-BLOCK: tile-mgather-cas-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `MGATHER_CAS` example, an indexed old value `5`, expected value `5`, and replacement `9` publish observed value `5` and replace GM with `9`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MGATHER_CAS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MGATHER_CAS | TLSU |  | 8 |  | MGATHER_CAS |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### B.IOR.RegSrc0 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | observed-old-values destination |
| address | base-address |
| source0 | byte displacements |
| source1 | expected values |
| source2 | replacement values |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
```asl
readonly func InstructionContractOperation_MGATHER_CAS() => TileOperation
begin
    return TileOperation_MGATHER_CAS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.CAS DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT IndexTile, ExpectedTile, mask=PE_MASK
B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
```asl
readonly func InstructionContractHandler_MGATHER_CAS() => TileSemanticHandler
begin
    return TileHandler_MGATHER_CAS;
end;

pure func InstructionContractUsesByteDisplacements_MGATHER_CAS()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MGATHER_CAS()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MGATHER_CAS()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractWritesMemory_MGATHER_CAS()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- DataType is always encoded and selects the transfer, comparison, replacement, and destination element type.
- The completed schema requires explicit B.IOR: RegSrc0 supplies the per-PE byte-address base; RegSrc1, RegSrc2, and RegDst must encode zero. Omitted LB1 defaults to one, omitted LB2 defaults to LB0, and omitted B.DATR uses the operation defaults.
- Each IndexTile logical element is a signed or unsigned byte displacement relative to BaseGPR.

## Legality

- MGATHER_CAS is selected only by BSTART.MGATHER.CAS function 8 in the TLSU selector space; it has no standalone opcode.
- Exactly two Local B.IOT bindings are required. The first supplies IndexTile and ExpectedTile without a destination and has L=0. The second supplies ReplacementTile and a newly allocated destination and has L=1. Both carry one common PE_MASK; B.IOS is not accepted.
- ExpectedTile and ReplacementTile must be allocated, fully defined, use the selected transfer DataType, and match the resolved ValidRow x ValidCol. Comparison uses their encoded element values.
- Packed four-bit transfer DataTypes E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 are rejected because the block carries no nibble selector.
- Destination physical Rows are derived from TSize, physical Col, and transfer DataType. Rows and Col are powers of two and the physical region contains ValidRow x ValidCol.
- B.IOT PE_MASK=0000 is a strict no-op before schema, GPR, source, dimension, allocation, address, or fault checks.
- B.DATR applicability allows only PadValueOrByteId as PadValue and Layout.
- IndexTile must be allocated, fully defined, generically indexable, and use S32 or U32. Each logical element is sign- or zero-extended as a byte displacement.
- B.IOR RegSrc0 supplies the per-PE byte-address base; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- Allocate a new Local destination descriptor using B.IOT TSize, resolved dimensions, selected transfer DataType, selected Layout, and PE_MASK.
- Initialize every physical destination coordinate from the selected PadValue carrier before enabled valid-lane writes.
- On success overwrite enabled valid coordinates with loaded or observed values, mark the full physical destination defined, set contents_defined=TRUE, and publish atomically.

## Memory effects and ordering

### Memory effects

- For each valid coordinate, atomically access BaseGPR plus the corresponding signed or unsigned byte displacement from IndexTile.
- All lane addresses are preflighted before the first atomic event. Duplicate-address lanes serialize in an implementation-defined order.

### Ordering

- Each lane is one atomic read-modify-write governed by the block memory-order attributes.
- Duplicate-address lanes serialize in an implementation-defined order. No additional inter-PE order is guaranteed.
- Base, dimensions, and all enabled indices are snapshotted before complete address preflight.

## Exceptions

- A missing B.IOR, missing LB0, malformed two-command B.IOT sequence, non-S32/U32 IndexTile, shape or type mismatch, packed four-bit transfer DataType, or invalid dimensions raises Fault_TileLegality before destination allocation, atomic events, or memory writes.
- Every valid-region read and write address is probed before the first compare-and-swap. Any access fault leaves the destination unallocated and produces no partial atomic event, memory write, or payload effect.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.MGATHER.CAS DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, ExpectedTile, mask=PE_MASK; B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
