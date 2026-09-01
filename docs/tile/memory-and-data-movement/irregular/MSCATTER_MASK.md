<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl -->
# MSCATTER_MASK

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl`

Scatter exact-one source lanes to GM using signed or unsigned logical linear element indices.

## Normative identity {#PTO-INST-TILE-MSCATTER-MASK}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mscatter-mask-purpose role=purpose -->
## What MSCATTER_MASK does

`MSCATTER_MASK` is a selector-encoded Tile operation executed by `TLSU`. It stores only exact-one predicate lanes at their indexed GM byte displacements; its current instruction contract owns the exact bundle form and publication boundary.

<!-- PTO-READER-BLOCK: tile-mscatter-mask-mechanism role=mechanism -->
## Element and Tile mechanism

After all descriptor and operand checks succeed, the owning ASL handler stores only exact-one predicate lanes at their indexed GM byte displacements. Source payloads are snapshotted before destination writes whenever the contract permits aliasing.

The handler uses the resolved valid region rather than treating physical padding as input data. Its operation-specific dtype, layout, rounding, saturation, and profile hooks remain the executable definition.

<!-- PTO-READER-BLOCK: tile-mscatter-mask-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `address` has the exact contract role **base-address**.
- `source0` has the exact contract role **source data**.
- `source1` has the exact contract role **byte-displacement indices**.
- `source2` has the exact contract role **exact zero-or-one predicate mask**.

Every source coordinate read by the operation must be defined before execution reaches destination publication.
`PE_MASK=0000` is a strict no-op before descriptor, allocation, payload, numeric-status, or memory effects.

<!-- PTO-READER-BLOCK: tile-mscatter-mask-effects role=effects -->
## Publication, definedness, and padding

GM writes and memory events begin only after complete source, predicate, address, and permission preflight; the operation has no Tile destination.

No padding behavior beyond the current handler contract is implied.

The operation preflights every enabled GM address before the first store or memory event and allocates no destination Tile.

<!-- PTO-READER-BLOCK: tile-mscatter-mask-constraints role=constraints -->
## Type, layout, and fault boundary

Index Tiles use `S32`, `U32`, `S64`, or `U64`. Packed four-bit transfer types `E2M1X2`, `E1M2X2`, `HiF4X2`, `S4X2`, and `U4X2` are rejected because this indexed transfer has no nibble selector.

The generated legality and exception sections below are authoritative for dtype pairs, layout, dimensions, capacity, definedness, padding controls, profile behavior, and fault class. Legality and allocation failures occur before partial architectural effects.

<!-- PTO-READER-BLOCK: tile-mscatter-mask-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `MSCATTER_MASK` example, source value `7` with mask `1` is stored, while the same lane with mask `0` generates no address.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER_MASK <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER_MASK | TLSU |  | 7 |  | MSCATTER_MASK |

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
| address | base-address |
| scalar0 | per-PE private-GPR GM row stride in elements |
| source0 | source data |
| source1 | logical linear element indices |
| source2 | exact zero-or-one predicate mask |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl -->
```asl
readonly func InstructionContractOperation_MSCATTER_MASK() => TileOperation
begin
    return TileOperation_MSCATTER_MASK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.MASK DataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT DataTile, IndexTile, mask=PE_MASK
B.IOT MaskTile, mask=PE_MASK, <last>
B.IOR BaseGPR, StrideGPR, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER_MASK() => TileSemanticHandler
begin
    return TileHandler_MSCATTER_MASK;
end;

pure func InstructionContractUsesLogicalElementIndices_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MSCATTER_MASK()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the GM base address, RegSrc1 names the nonzero GM row stride in elements, and RegSrc2 plus RegDst must encode zero.
- LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.
- Omitted B.DATR selects Layout=NORM; every other B.DATR field must remain zero.
- Each IndexTile logical element is a signed or unsigned logical linear element index. ValidCol splits it into a logical row and column; RegSrc1 replaces ValidCol as the GM row stride before transfer-element-size scaling.

## Legality

- MSCATTER_MASK is selected only by BSTART.MSCATTER.MASK function 7 in the TLSU selector space; it has no standalone opcode.
- Exactly two Local B.IOT records supply DataTile plus IndexTile and then MaskTile with the sole last marker. Neither record has a destination or TSize; B.IOS and additional bindings are illegal.
- All three sources are allocated and fully defined, share ValidRow x ValidCol and Layout, and persist after execution. DataTile DataType equals BSTART DataType; IndexTile uses S32, U32, S64, or U64 logical linear element indices; MaskTile valid elements are exactly zero or one.
- DataTile physical Col equals LB2. IndexTile and MaskTile may use different physical shapes outside the common valid rectangle.
- Packed four-bit transfer DataTypes E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 reject because the block carries no nibble selector.
- PE_MASK is common across both B.IOT records. PE_MASK=0000 is a strict no-op before schema, predicate, GPR, address, permission, event, or memory checks.
- B.DATR applicability allows only Layout.
- The B.IOR row stride is nonzero and no smaller than ValidCol; an invalid stride rejects before address probes or effects.

## State effects

- All three source descriptors and payloads persist unchanged after success or rejection.
- On success only enabled-lane memory and event state changes; MSCATTER_MASK allocates no destination Tile.

## Memory effects and ordering

### Memory effects

- For each valid coordinate whose MaskTile value is one, store the corresponding DataTile element to the address obtained by splitting the logical linear index by ValidCol, applying row_stride_elements to the row, and scaling the resulting element offset by the transfer element size.
- A zero mask value performs no address generation, translation, permission check, store, or memory event. Physical source elements outside ValidRow x ValidCol also have no effect.
- All enabled lanes are preflighted before stores. Duplicate or overlapping enabled targets have an implementation-defined final winner.

### Ordering

- Enabled stores participate in the common memory-order domain; no lane or inter-PE issue order is guaranteed.
- B.CATR.atomic=1 makes the complete block effect non-interleavable but does not define an internal enabled-lane order or duplicate-address winner.
- Base, stride, dimensions, and all enabled indices are snapshotted before complete address preflight.

## Exceptions

- A missing B.IOR or LB0, malformed or unterminated B.IOT stream, undefined source, source DataType mismatch, non-integer IndexTile, mask value other than zero or one, shape or layout mismatch, invalid dimensions, or packed transfer DataType, zero row stride, or row stride smaller than ValidCol raises Fault_TileLegality before effects.
- Only exact-one lanes generate addresses. Every enabled address is probed before the first store or event; an enabled-lane fault produces no partial write or event, while a disabled lane cannot fault from its ignored index.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.MSCATTER.MASK DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK; B.IOT MaskTile, mask=PE_MASK, <last>; B.IOR BaseGPR, StrideGPR, zero, ->zero; BSTOP
