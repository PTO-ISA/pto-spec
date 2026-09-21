<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER.asl -->
# MSCATTER

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER.asl`

scatter using explicit byte displacements.

## Normative identity {#PTO-INST-TILE-MSCATTER}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mscatter-purpose role=purpose -->
## What MSCATTER does

`MSCATTER` is a selector-encoded Tile operation executed by `TLSU`. It uses each integer index as a GM byte displacement and stores the corresponding valid source element; its current instruction contract owns the exact bundle form and publication boundary.

<!-- PTO-READER-BLOCK: tile-mscatter-mechanism role=mechanism -->
## Element and Tile mechanism

After all descriptor and operand checks succeed, the owning ASL handler uses each integer index as a GM byte displacement and stores the corresponding valid source element. Source payloads are snapshotted before destination writes whenever the contract permits aliasing.

The handler uses the resolved valid region rather than treating physical padding as input data. Its operation-specific dtype, layout, rounding, saturation, and profile hooks remain the executable definition.

<!-- PTO-READER-BLOCK: tile-mscatter-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `address` has the exact contract role **base-address**.
- `source0` has the exact contract role **source data**.
- `source1` has the exact contract role **byte-displacement indices**.

Every source coordinate read by the operation must be defined before execution reaches destination publication.
`PE_MASK=0000` is a strict no-op before descriptor, allocation, payload, numeric-status, or memory effects.

<!-- PTO-READER-BLOCK: tile-mscatter-effects role=effects -->
## Publication, definedness, and padding

GM writes and memory events begin only after complete source, predicate, address, and permission preflight; the operation has no Tile destination.

Physical coordinates outside the valid rectangle follow the contract-selected padding rule; `Null` padding remains undefined when that rule applies.

The operation preflights every enabled GM address before the first store or memory event and allocates no destination Tile.

<!-- PTO-READER-BLOCK: tile-mscatter-constraints role=constraints -->
## Type, layout, and fault boundary

Index Tiles use `S32`, `U32`, `S64`, or `U64`. Packed four-bit transfer types `E2M1X2`, `E1M2X2`, `HiF4X2`, `S4X2`, and `U4X2` are rejected because this indexed transfer has no nibble selector.

The generated legality and exception sections below are authoritative for dtype pairs, layout, dimensions, capacity, definedness, padding controls, profile behavior, and fault class. Legality and allocation failures occur before partial architectural effects.

<!-- PTO-READER-BLOCK: tile-mscatter-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `MSCATTER` example, index `4` and source value `7` store `7` at `base + 4` after complete preflight.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER | TLSU |  | 5 |  | MSCATTER |

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
| address | base-address |
| source0 | source data |
| source1 | byte-displacement indices |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER.asl -->
```asl
readonly func InstructionContractOperation_MSCATTER() => TileOperation
begin
    return TileOperation_MSCATTER;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER DataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT DataTile, IndexTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER() => TileSemanticHandler
begin
    return TileHandler_MSCATTER;
end;

pure func InstructionContractUsesByteDisplacements_MSCATTER()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MSCATTER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MSCATTER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MSCATTER()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.
- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.
- IndexTile entries are S32, U32, S64, or U64 byte displacements and are not scaled or decomposed.

## Legality

- Non-packed transfer shapes match IndexTile; packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and rejects incomplete pairs.
- ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.
- Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.
- B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.

## State effects

- Source Tile descriptors and payloads persist unchanged after success or rejection.
- On success only memory and memory-event state change; MSCATTER allocates no destination Tile.

## Memory effects and ordering

### Memory effects

- Each indexed transaction stores one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the byte displacement.
- All valid addresses are preflighted before the first architectural effect.

### Ordering

- Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.

## Exceptions

- Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects.

## Examples

- BSTART.MSCATTER DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK, <last>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
