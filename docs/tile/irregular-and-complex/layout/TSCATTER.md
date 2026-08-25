<!-- GENERATED FROM: asl/tile/irregular-and-complex/layout/TSCATTER.asl -->
# TSCATTER

**Normative ASL source:** `asl/tile/irregular-and-complex/layout/TSCATTER.asl`

Scatter values to distinct destination rows selected independently at each source coordinate.

## Normative identity {#PTO-INST-TILE-TSCATTER}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tscatter-purpose role=purpose -->
## What TSCATTER does

`TSCATTER` writes source values into distinct destination rows selected by an index Tile.

<!-- PTO-READER-BLOCK: tile-c-tscatter-mechanism role=mechanism -->
## Operation mechanism

Every physical destination coordinate is first initialized to typed zero.

For source coordinate `[r,c]`, index value `k` writes the exact source bits to destination `[k,c]`; duplicate destination coordinates are illegal.

<!-- PTO-READER-BLOCK: tile-c-tscatter-inputs-outputs role=inputs-outputs -->
## Operands, shape, and type

- `destination0` identifies a newly allocated destination.

- `source0` supplies a persistent source Tile.

- `source1` supplies the index Tile.

- Value Tiles accept the non-packed types `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `HiF8`, `E4M3`, `E5M2`, `E3M2`, `E2M3`, `E8M0`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`.

- The index Tile accepts exactly `S16`, `U16`, `S32`, `U32`, `S64`, `U64`.

- Data Tiles use row-major layout unless this mnemonic explicitly selects another permitted layout.

- `LB0`, `LB1`, and `LB2` complete the valid and physical shape according to this mnemonic’s contract; every required valid extent is nonzero.

<!-- PTO-READER-BLOCK: tile-c-tscatter-effects role=effects -->
## Definedness, padding, and publication

All source descriptors and payloads are validated and snapshotted before destination publication.

The complete destination payload, descriptor, definedness, padding state, and applicable numeric status publish atomically; rejection publishes none.

Source Tiles persist and are not modified by successful execution.

<!-- PTO-READER-BLOCK: tile-c-tscatter-constraints role=constraints -->
## Legality, fault, and order boundaries

Complete binding schema, dimensions, DataType, layout, source definedness, numeric encoding, destination capacity, and allocation are preflighted before effects.

A failed legality or allocation check raises the applicable Tile fault without partial destination, status, or memory effects.

`PE_MASK=0000` is a strict no-op before operand reads, allocation, faults, numeric status, or payload effects.

<!-- PTO-READER-BLOCK: tile-c-tscatter-example role=example -->
## Non-normative example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

`TSCATTER <bundle operands>` performs complete preflight and source snapshotting before atomically publishing the mnemonic-defined result and padding state.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TSCATTER <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSCATTER | TEPL | 0x070 | 16 | 3 | TSCATTER |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new zero-initialized Local value destination |
| source0 | persistent Local value source |
| source1 | persistent Local S16, U16, S32, U32, S64, or U64 row-index source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/layout/TSCATTER.asl -->
```asl
readonly func InstructionContractOperation_TSCATTER() => TileOperation
begin
    return TileOperation_TSCATTER;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TSCATTER, ValueDataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT ValueSrc, IndexSrc, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/layout/TSCATTER.asl -->
```asl
readonly func InstructionContractOperandsLegal_TSCATTER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    return TileOperandsLegal_TSCATTER(destination, source, indices);
end;

readonly func InstructionContractHandler_TSCATTER() => TileSemanticHandler
begin
    return TileHandler_TSCATTER;
end;

func InstructionContractExecute_TSCATTER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex)
begin
    assert InstructionContractOperandsLegal_TSCATTER(
        destination,
        source,
        indices);
    TSCATTER(destination, source, indices);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero destination ValidCol; omitted LB1 selects destination ValidRow=1 and omitted LB2 selects physical Col=ValidCol.
- Omitted B.DATR retains row-major destination layout; an assigned legal Layout changes only destination physical placement. PadValueOrByteId is encoded zero and means typed positive or integer zero for this operation; every other B.DATR field remains zero.
- Before scatter writes, every physical destination element is initialized to the selected value DataType's positive or integer zero and is defined.

## Legality

- TSCATTER uses the TEPL encoding carrier Mode 3 Function 16, is canonically assembled with BSTART.SFU, and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent value source, one persistent row-index source, and one newly allocated destination; B.IOR and B.IOS are illegal.
- Every non-packed B8-NP, B16, B32, or B64 value pairs with every S16, U16, S32, U32, S64, or U64 index.
- The two sources have the same nonzero valid shape. Destination ValidCol equals source ValidCol and destination ValidRow is nonzero.
- Every signed index is nonnegative and every index is less than destination ValidRow. No two source coordinates may select the same destination coordinate [index[r,c],c].
- Both source valid rectangles are fully defined and validly encoded. All three bindings use the same PE_MASK; any nonzero subset is legal.

## State effects

- Initialize every physical destination coordinate to typed positive or integer zero.
- For every source coordinate [r,c], read k=index[r,c] and write source[r,c] bit-for-bit to destination[k,c].
- Both sources persist, no previous destination value is read, and rejection publishes no destination state.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, descriptor, type-pair, dimension, layout, capacity, index-range, duplicate-coordinate, and source-definedness preflight precedes source snapshots.
- Both sources are snapshotted before zero initialization and scatter evaluation; complete destination payload, physical definedness, and descriptor publish atomically.

## Exceptions

- Malformed bindings, B.IOR, B.IOS, unsupported value/index pair, zero or mismatched source shape, destination-column mismatch, negative or out-of-range index, duplicate destination coordinate, undefined source, invalid consumed encoding, reserved Layout, or insufficient destination capacity raises the applicable Tile fault before effects.
- PE_MASK=0000 is a strict no-op before Tile reads, index and duplicate checks, allocation, faults, zero initialization, or payload effects.

## Examples

- BSTART.SFU TSCATTER, U16; B.DIM LB0=2; B.DIM LB1=4; B.IOT ValueSrc, IndexSrc, mask=1111, <last>, ->Dst<2>; BSTOP
