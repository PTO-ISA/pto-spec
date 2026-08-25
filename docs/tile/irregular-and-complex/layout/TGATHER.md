<!-- GENERATED FROM: asl/tile/irregular-and-complex/layout/TGATHER.asl -->
# TGATHER

**Normative ASL source:** `asl/tile/irregular-and-complex/layout/TGATHER.asl`

Gather values from source rows selected independently at each destination coordinate.

## Normative identity {#PTO-INST-TILE-TGATHER}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tgather-purpose role=purpose -->
## Purpose

`TGATHER` gathers values from independently selected source rows.

<!-- PTO-READER-BLOCK: tile-tgather-mechanism role=mechanism -->
## Execution mechanism

The ASL DOC contract selects `TileHandler_TGATHER` through the instruction's selector-encoded block carrier.

Dimensions, descriptors, layouts, DataTypes, source definedness, consumed encodings, destination capacity, masks, and operation-specific indices or offsets are checked before any source snapshot.

<!-- PTO-READER-BLOCK: tile-tgather-inputs-outputs role=inputs-outputs -->
## Operands and descriptors

`destination0` is the new Local value destination; `source0` is the persistent Local value source; `source1` is the persistent Local S16, U16, S32, U32, S64, or U64 row-index source.

Sources remain persistent unless the current contract explicitly names a consumed or replaced state; destination descriptors are published only after complete preflight.

<!-- PTO-READER-BLOCK: tile-tgather-effects role=effects -->
## Publication and ordering

Sources are snapshotted before construction, so allowed aliases observe complete pre-operation payload and definedness.

The complete destination payload, definedness, padding policy, and descriptor publish together; rejection publishes no partial destination.

<!-- PTO-READER-BLOCK: tile-tgather-constraints role=constraints -->
## Legality, padding, and faults

Malformed bindings, unsupported types or layouts, invalid shapes, undefined consumed elements, illegal attributes, or insufficient destination capacity are rejected before source snapshots or publication.

Allocation failure raises the owner-defined Tile allocation fault; other rejected schema or value conditions raise the owner-defined legality, bundle-control, or memory fault without partial effects.

<!-- PTO-READER-BLOCK: tile-tgather-example role=example -->
## Non-normative contract sketch

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

Read `BSTART.SFU TGATHER, U16; B.DIM LB0=2; B.DIM LB1=2; B.IOT ValueSrc, IndexSrc, mask=1111, <last>, ->Dst<2>; BSTOP` as a non-normative binding walkthrough, then use the generated contract below for exact dimensions, attributes, and fault behavior.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TGATHER <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGATHER | TEPL | 0x06F | 15 | 3 | TGATHER |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local value destination |
| source0 | persistent Local value source |
| source1 | persistent Local S16, U16, S32, U32, S64, or U64 row-index source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/layout/TGATHER.asl -->
```asl
readonly func InstructionContractOperation_TGATHER() => TileOperation
begin
    return TileOperation_TGATHER;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TGATHER, ValueDataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT ValueSrc, IndexSrc, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/layout/TGATHER.asl -->
```asl
readonly func InstructionContractOperandsLegal_TGATHER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    return TileOperandsLegal_TGATHER(destination, source, indices);
end;

readonly func InstructionContractHandler_TGATHER() => TileSemanticHandler
begin
    return TileHandler_TGATHER;
end;

func InstructionContractExecute_TGATHER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex)
begin
    assert InstructionContractOperandsLegal_TGATHER(
        destination,
        source,
        indices);
    TGATHER(destination, source, indices);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero destination ValidCol; omitted LB1 selects destination ValidRow=1 and omitted LB2 selects physical Col=ValidCol.
- Omitted B.DATR retains row-major destination layout; an assigned legal Layout changes only destination physical placement. PadValueOrByteId, secondary DataType, CMode, RMode, Sat, and Canonicalize remain zero.
- Physical destination coordinates outside the valid rectangle are undefined Null padding.

## Legality

- TGATHER uses the TEPL encoding carrier Mode 3 Function 15, is canonically assembled with BSTART.SFU, and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent value source, one persistent row-index source, and one newly allocated destination; B.IOR and B.IOS are illegal.
- Value source and destination use the same one of HiF8, E4M3, E5M2, E3M2, E2M3, E8M0, S8, U8, FP16, BF16, S16, U16, FP32, TF32, HF32, S32, U32, FP64, S64, or U64. The index source is exactly S16, U16, S32, U32, S64, or U64.
- Index and destination valid shapes are equal and nonzero. The value source has at least destination ValidCol columns.
- Every signed index is nonnegative and every index is less than source ValidRow. The complete index rectangle and every selected source[value,row,column] element are defined and validly encoded.
- All three bindings use the same PE_MASK; any nonzero subset is legal.

## State effects

- For every destination coordinate [r,c], read k=index[r,c] and copy source[k,c] bit-for-bit to destination[r,c].
- Indices select logical source rows and never flatten, wrap, clamp, or select another column.
- Both sources persist and rejection publishes no destination state.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, descriptor, type, dimension, layout, capacity, index-range, and referenced-definedness preflight precedes source snapshots.
- Both source payloads are snapshotted before result construction; complete destination payload, definedness, Null padding, and descriptor publish atomically.

## Exceptions

- Malformed bindings, B.IOR, B.IOS, unsupported value or index DataType, zero or mismatched valid shape, insufficient source columns, negative or out-of-range index, undefined index, undefined selected source element, invalid consumed encoding, reserved Layout, or insufficient destination capacity raises the applicable Tile fault before effects.
- PE_MASK=0000 is a strict no-op before Tile reads, index checks, allocation, faults, or payload effects.

## Examples

- BSTART.SFU TGATHER, U16; B.DIM LB0=2; B.DIM LB1=2; B.IOT ValueSrc, IndexSrc, mask=1111, <last>, ->Dst<2>; BSTOP
