<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TOR.asl -->
# TOR

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TOR.asl`

Compute the bitwise OR of corresponding integer elements.

## Normative identity {#PTO-INST-TILE-TOR}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tor-purpose role=purpose -->
## What TOR does

`TOR` computes the bitwise OR of corresponding elements of two Local integer Tiles and writes the results into a newly allocated Local destination Tile. Bitwise OR sets a bit where either source has it set.

Design point: `TOR` has no standalone opcode. It is selected by `BSTART.VEC` Mode 0 Function 7 (TEPL selector `0x007`). Its operand legality and execution follow the same closed Local binary Tile contract as `TADD`, and it differs from `TAND` and `TXOR` only in the bit operation.

<!-- PTO-READER-BLOCK: tile-tor-mechanism role=mechanism -->
## Element and Tile mechanism

Preflight checks the complete bundle first: operand schema, dimensions, `DataType`, layout, source definedness, and destination capacity. Only then does `ExecuteTileBinary` read both sources and compute `left OR right` for each coordinate of the valid rectangle `ValidRow x ValidCol`.

For an element width `W` of 8, 16, 32, or 64 bits, the result is the low `W` bits of the OR, and carrier bits above `W` are zero. Signedness does not change the operation: `S8` and `U8` produce the same bits.

Design point: `TOR` is a raw-carrier operation. Arithmetic operations such as `TADD` require every source element to be a valid encoding of the selected `DataType`; `TOR` skips that numeric validation and consumes the stored bits as they are. A bit operation has no numeric meaning to validate, and it produces no rounding, saturation, or numeric status.

<!-- PTO-READER-BLOCK: tile-tor-inputs-outputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the left operand. It is an existing, allocated Local Tile.
- `source1` is the right operand. Its physical shape, valid shape, and layout must match `source0`.
- `destination0` is a newly allocated Local Tile. Its backing `DataType` is the selected operation `DataType`, and its shape matches the sources.

One terminating `B.IOT` binds all three Tiles under a single `PE_MASK`; `B.IOR` and `B.IOS` are not accepted. `PE_MASK=0000` is a strict no-op before reads, allocation, or faults.

Design point: each source may be stored with a different same-width, non-packed backing type, and its bits are used unchanged. For example, `FP32` data read as `U32` and ORed with `0x80000000` sets each sign bit and yields the `U32` encodings of the negated absolute values.

<!-- PTO-READER-BLOCK: tile-tor-effects role=effects -->
## Publication, definedness, and padding

Both source payloads are snapshotted before the first destination write. Either source may alias the destination, and both sources may name the same Tile; the result is always computed from the old values.

The destination descriptor, the valid-region results, the padding, and every element's definedness publish as one commit. A rejected `TOR` leaves descriptors, payloads, and allocation state unchanged.

Elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero` writes zero, and `Max` and `Min` write the numeric maximum and minimum of the integer `DataType`; `Null`, selected when `B.DATR` is omitted, leaves them undefined. When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value. `TOR` has no global-memory effect.

<!-- PTO-READER-BLOCK: tile-tor-constraints role=constraints -->
## Type, layout, and fault boundary

The accepted data-type set is `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`. Floating and packed operation types are rejected before effects; floating data can still be processed through a same-width integer operation type, as shown above.

The layout is `RowMajor` by default, or `CUBE_M16` or `CUBE_M32` when an explicit `Layout` selects it. `CUBE_N8`, Shared Tiles, and mixed layouts are illegal. Among CUBE layouts, a 64-bit operation type is legal only in `CUBE_M32`; `CUBE_M16` rejects it.

Every source element in the valid rectangle (every active one, when an ExecutionMask is in force) must be defined, even though its encoding is not validated. Malformed bindings, missing or zero dimensions, undefined or mismatched sources, an unsupported layout, an unsupported `DataType`, or invalid destination capacity raises `Fault_TileLegality` before effects. A nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`, or `RMode` is illegal.

<!-- PTO-READER-BLOCK: tile-tor-example role=example -->
## Non-normative contract sketch

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

With `DataType=U8`, a left source row `[0x0F, 0xF0, 0xFF]` and a right source row `[0x3C, 0x3C, 0x81]` produce the destination row `[0x3F, 0xFC, 0xFF]`.

In macro form, `TOR <Row=8, Col=64, U32>, T#1, T#2, ->T<2KB>` computes all 8 x 64 results of two `U32` Tiles into a new 2 KB destination.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TOR <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TOR | TEPL | 0x007 | 7 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | ordered left Local source |
| source1 | ordered right Local source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TOR.asl -->
```asl
readonly func InstructionContractOperation_TOR() => TileOperation
begin
    return TileOperation_TOR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TOR, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TOR.asl -->
```asl
pure func InstructionContractDataTypeLegal_TOR(
    data_type: TileDataType) => boolean
begin
    return TileVecScalarIntegerDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TOR(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_OR,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TOR() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TOR(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_OR,
        destination,
        source_left,
        source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Physical Rows derive from TSize, Col, and DataType; Rows and Col are powers of two and contain ValidRow x ValidCol.

## Legality

- TOR is selected by TEPL carrier Mode 0 Function 7 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local sources and one newly allocated Local destination; B.IOR and B.IOS are not accepted.
- DataType is exactly S64, S32, S16, S8, U64, U32, U16, or U8; packed and floating formats reject before effects.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; PE_MASK=0000 is a strict no-op before reads, allocation, or faults.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- Apply element-width bitwise OR to corresponding valid source elements; signedness does not change the bit operation and carrier bits above the selected width are zero.
- Either source may alias the destination with read-old/write-new behavior, and both sources may name the same Tile.
- Publish the complete valid result and selected physical padding definedness as one destination commit; rejection leaves descriptors, payloads, and allocation state unchanged.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both source payloads are snapshotted after complete preflight and before the first destination write.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched sources, an unsupported layout, an unsupported DataType, or invalid destination capacity raises Fault_TileLegality before effects.
- Explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, is illegal before source snapshots or destination allocation.

## Examples

- BSTART.VEC TOR, U8; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
