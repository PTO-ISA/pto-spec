<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TNOT.asl -->
# TNOT

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TNOT.asl`

Element-width bitwise complement over one Local integer Tile source.

## Normative identity {#PTO-INST-TILE-TNOT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tnot-purpose role=purpose -->
## What TNOT does

`TNOT` inverts every bit of every element of one Local integer Tile and writes the results into a newly allocated Local destination Tile. It is the bitwise complement.

Design point: `TNOT` has no standalone opcode. `BSTART.VEC` Mode 0 Function 16 (TEPL selector `0x010`) selects it, and it shares the closed unary bundle schema with `TABS`, `TNEG`, and `TRELU`.

<!-- PTO-READER-BLOCK: tile-tnot-mechanism role=mechanism -->
## Element and Tile mechanism

After complete preflight, `ExecuteTileUnary` reads the source and, for each coordinate of the valid rectangle `ValidRow x ValidCol`, complements exactly the selected 8-, 16-, 32-, or 64-bit element width. Signedness does not change the result: `S8` and `U8` both map `0x0F` to `0xF0`.

Design point: only the element's own `W` bits are complemented, and carrier bits above `W` are zero in the result. The model holds every element in a 64-bit carrier; complementing the whole carrier would turn the unused upper bits into ones. Limiting the result to `W` bits keeps an 8-bit result an 8-bit value.

Design point: `TNOT` is a bit operation, so it applies no numeric rounding, saturation, or status. Unlike `TABS`, `TNEG`, and `TRELU`, which also accept floating types, `TNOT` accepts only the eight integer types.

<!-- PTO-READER-BLOCK: tile-tnot-inputs-outputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the bitwise source. It is an existing, allocated Local Tile.
- `destination0` is a newly allocated Local Tile with the same physical shape, valid shape, layout, and `DataType` as the source.

One terminating `B.IOT` binds both Tiles under a single `PE_MASK`; `B.IOR` and `B.IOS` are illegal. `PE_MASK=0000` is a strict no-op before dimensions, source access, schema checks, or destination allocation.

Design point: the unary legality path for `TNOT` requires the source backing `DataType` to equal the operation `DataType`. It does not use the same-width reinterpretation that `TABS`, `TNEG`, and `TRELU` allow, so a source stored under another backing type is rejected before any effect.

<!-- PTO-READER-BLOCK: tile-tnot-effects role=effects -->
## Publication, definedness, and padding

The source payload is snapshotted before the first destination write, so a source that aliases the destination is read with its old values.

The destination descriptor, the valid-region results, the padding, and every element's definedness publish together; a rejected `TNOT` has no architectural effect. Elements outside `ValidRow x ValidCol` receive the selected `PadValue`: `Zero`, `Max`, and `Min` are defined, and `Null`, the value when `B.DATR` is omitted, leaves them undefined. When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value. `TNOT` has no global-memory effect.

<!-- PTO-READER-BLOCK: tile-tnot-constraints role=constraints -->
## Type, layout, and fault boundary

The accepted data-type set is `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`. Floating and packed formats are rejected. The layout is `RowMajor` by default, or `CUBE_M16` or `CUBE_M32` when an explicit `Layout` selects it; `CUBE_N8`, Shared Tiles, and mixed layouts are illegal. Among CUBE layouts, a 64-bit operation type is legal only in `CUBE_M32`; `CUBE_M16` rejects it.

Malformed bindings, missing or zero dimensions, undefined or mismatched source state, an unsupported `DataType`, a non-selected layout, or a nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`, or `RMode` raises `Fault_TileLegality` before any effect. An unrepresentable destination shape or insufficient `TSize` capacity raises `Fault_TileAllocation` before allocation.

<!-- PTO-READER-BLOCK: tile-tnot-example role=example -->
## Non-normative contract sketch

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

With `DataType=U16`, valid elements `[0x0000, 0x00FF, 0xFFFF]` become `[0xFFFF, 0xFF00, 0x0000]`. In macro form, `TNOT <Row=8, Col=64, U16>, T#1, ->T<1KB>` complements all 8 x 64 elements into a new 1 KB destination.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TNOT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TNOT | TEPL | 0x010 | 16 | 0 | ExecuteTileUnary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | bitwise source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TNOT.asl -->
```asl
readonly func InstructionContractOperation_TNOT() => TileOperation
begin
    return TileOperation_TNOT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TNOT, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TNOT.asl -->
```asl
pure func InstructionContractDataTypeLegal_TNOT(
    data_type: TileDataType) => boolean
begin
    return TileVecScalarIntegerDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TNOT(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_NOT,
        destination,
        source);
end;

pure func InstructionContractValue_TNOT(
    data_type: TileDataType,
    source: Word) => Word
begin
    let (result, -) = TileFixedUnaryValue(
        TileUnary_NOT,
        data_type,
        source);
    return result;
end;

readonly func InstructionContractHandler_TNOT() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TNOT(
    destination: TileIndex,
    source: TileIndex)
begin
    ExecuteTileUnary(TileUnary_NOT, destination, source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- TNOT complements exactly the selected 8-, 16-, 32-, or 64-bit element width and zero-extends the result to the Tile payload carrier.

## Legality

- TNOT is BSTART.VEC Mode 0 Function 16 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one Local source and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of S64, S32, S16, S8, U64, U32, U16, or U8.
- Source and destination match physical shape, valid shape, selected layout, DataType, and PE_MASK; the source valid region is fully defined.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal.
- PE_MASK zero is a strict no-op before dimensions, source access, schema checks, or destination allocation.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- For every valid coordinate, complement exactly the selected integer element width and clear upper carrier bits.
- Publish the complete valid result and selected physical padding atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- The source payload is snapshotted after complete schema, dimension, DataType, layout, definedness, encoding, mask, and destination-capacity preflight and before destination writes.
- Source-to-destination aliasing therefore observes the complete pre-operation source payload.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched source state, unsupported DataType, non-selected layout, or invalid floating source encoding raises Fault_TileLegality before effects; an unrepresentable destination shape or insufficient TSize capacity raises Fault_TileAllocation before allocation.
- This operation introduces no memory fault and reports no floating invalid condition solely from its value transform.

## Examples

- BSTART.VEC TNOT, U64; B.DIM LB0=ValidCol; B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
