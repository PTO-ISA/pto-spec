<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MGATHER.asl -->
# MGATHER

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MGATHER.asl`

Gather GM elements addressed by signed or unsigned logical linear element indices into a newly allocated Local Tile.

## Normative identity {#PTO-INST-TILE-MGATHER}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mgather-purpose role=purpose -->
## What MGATHER does

`MGATHER` is a selector-encoded Tile operation executed by `TLSU`. It uses each integer index as a signed or unsigned GM byte displacement and gathers the addressed elements into a new Local Tile; its current instruction contract owns the exact bundle form and publication boundary.

<!-- PTO-READER-BLOCK: tile-mgather-mechanism role=mechanism -->
## Element and Tile mechanism

After all descriptor and operand checks succeed, the owning ASL handler uses each integer index as a signed or unsigned GM byte displacement and gathers the addressed elements into a new Local Tile. Source payloads are snapshotted before destination writes whenever the contract permits aliasing.

The handler uses the resolved valid region rather than treating physical padding as input data. Its operation-specific dtype, layout, rounding, saturation, and profile hooks remain the executable definition.

<!-- PTO-READER-BLOCK: tile-mgather-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `destination0` has the exact contract role **destination**.
- `address` has the exact contract role **base-address**.
- `source0` has the exact contract role **indices**.

Every source coordinate read by the operation must be defined before execution reaches destination publication.
`PE_MASK=0000` is a strict no-op before descriptor, allocation, payload, numeric-status, or memory effects.

<!-- PTO-READER-BLOCK: tile-mgather-effects role=effects -->
## Publication, definedness, and padding

After complete address preflight, the selected PadValue carrier initializes every physical destination coordinate; gathered valid values then overwrite their coordinates.

On success the full physical destination is marked defined and `contents_defined=TRUE`; payload, definedness, and descriptor publish together.

The operation preflights every enabled GM address before the first load, atomic event, or destination update; a failed access leaves no partial destination or event.

<!-- PTO-READER-BLOCK: tile-mgather-constraints role=constraints -->
## Type, layout, and fault boundary

Index Tiles use `S32`, `U32`, `S64`, or `U64`. Packed four-bit transfer types `E2M1X2`, `E1M2X2`, `HiF4X2`, `S4X2`, and `U4X2` are rejected because this indexed transfer has no nibble selector.

The generated legality and exception sections below are authoritative for dtype pairs, layout, dimensions, capacity, definedness, padding controls, profile behavior, and fault class. Legality and allocation failures occur before partial architectural effects.

<!-- PTO-READER-BLOCK: tile-mgather-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `MGATHER` example, with one valid index `4`, the destination receives the element loaded from `base + 4`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MGATHER <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MGATHER | TLSU |  | 4 |  | MGATHER |

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

### B.IOR.RegSrc1 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

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
| destination0 | destination |
| address | base-address |
| scalar0 | per-PE private-GPR GM row stride in elements |
| source0 | indices |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MGATHER.asl -->
```asl
readonly func InstructionContractOperation_MGATHER() => TileOperation
begin
    return TileOperation_MGATHER;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, StrideGPR, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MGATHER.asl -->
```asl
readonly func InstructionContractHandler_MGATHER() => TileSemanticHandler
begin
    return TileHandler_MGATHER;
end;

pure func InstructionContractUsesLogicalElementIndices_MGATHER()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MGATHER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MGATHER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MGATHER()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the GM base address, RegSrc1 names the nonzero GM row stride in elements, and RegSrc2 plus RegDst must encode zero.
- LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.
- Omitted B.DATR selects PadValue=Null and Layout=NORM. An explicit encoded PadValue is used for every physical destination element outside ValidRow x ValidCol.
- Each IndexTile logical element is a signed or unsigned logical linear element index. ValidCol splits it into a logical row and column; RegSrc1 replaces ValidCol as the GM row stride before transfer-element-size scaling.

## Legality

- MGATHER is selected only by BSTART.MGATHER function 4 in the TLSU selector space; it has no standalone opcode.
- Exactly one Local B.IOT binding supplies IndexTile and one destination, uses L=1, and carries the common PE_MASK and destination TSize. B.IOS is not accepted.
- IndexTile must be allocated, fully defined, generically indexable, and use S32, U32, S64, or U64. Its ValidRow x ValidCol must equal the resolved destination valid region, and every element is interpreted as a signed or unsigned logical linear element index.
- The transfer DataType may be any accepted BSTART.MGATHER DataType except E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2, whose missing nibble selector makes them reserved for indexed TLSU transfer.
- Destination physical Rows are derived from TSize, physical Col, and transfer DataType. Rows and Col are powers of two and the physical region must contain ValidRow x ValidCol.
- B.IOT PE_MASK=0000 is a strict no-op before all schema, GPR, source, dimension, allocation, and memory checks.
- B.DATR applicability allows only PadValueOrByteId as PadValue and Layout.
- The B.IOR row stride is nonzero and no smaller than ValidCol; an invalid stride rejects before address probes or effects.

## State effects

- Allocate a new Local destination descriptor using B.IOT TSize, resolved dimensions, selected transfer DataType, selected Layout, and PE_MASK.
- Initialize every physical destination coordinate from the selected PadValue carrier before enabled valid-lane writes.
- On success overwrite enabled valid coordinates with loaded or observed values, mark the full physical destination defined, set contents_defined=TRUE, and publish atomically.

## Memory effects and ordering

### Memory effects

- For every valid destination coordinate, load one transfer-typed element from BaseGPR plus ((floor(index / ValidCol) * row_stride_elements) + (index mod ValidCol)) times the transfer element size.
- Probe the complete valid region before recording memory events. After successful preflight, publish the loaded valid region and pad every remaining physical destination coordinate atomically.

### Ordering

- Selected lanes contribute load events in destination row/column order using the block memory-order attributes; no cross-PE request order is guaranteed.
- Base, stride, dimensions, and all enabled indices are snapshotted before complete address preflight.

## Exceptions

- A missing B.IOR, missing LB0, malformed B.IOT, non-integer IndexTile, shape mismatch, non-power-of-two physical Col, or packed four-bit transfer DataType, zero row stride, or row stride smaller than ValidCol raises Fault_TileLegality before allocation, memory events, or destination effects.
- Every valid-region address is probed before the first event or destination update; any access fault leaves the destination unallocated and produces no partial event or payload effect.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.MGATHER DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, StrideGPR, zero, ->zero; BSTOP
