<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TSHL.asl -->
# TSHL

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TSHL.asl`

Shift corresponding integer elements left by element-width-masked counts.

## Normative identity {#PTO-INST-TILE-TSHL}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tshl-purpose role=purpose -->
## What TSHL does

`TSHL` shifts each element of a Local integer value Tile left by the count held in the corresponding element of a second Local integer Tile. It writes the results into a newly allocated Local destination Tile. Each element has its own shift count.

Design point: `TSHL` has no standalone opcode. It is selected by `BSTART.VEC` Mode 0 Function 9 (TEPL selector `0x009`), and its operand legality and execution follow the same closed Local binary Tile contract as `TADD`.

<!-- PTO-READER-BLOCK: tile-c-tshl-mechanism role=mechanism -->
## Element and Tile mechanism

After complete preflight, `ExecuteTileBinary` reads both sources and processes each coordinate of the valid rectangle `ValidRow x ValidCol`. For an element width `W` of 8, 16, 32, or 64 bits, the shift count is the unsigned value of the low `log2(W)` bits of the `source1` element: 3 bits for 8-bit types, 4 for 16-bit, 5 for 32-bit, and 6 for 64-bit. Other count bits are ignored.

The destination element is the low `W` bits of `source0` shifted left by the count; bits shifted past bit `W-1` are discarded and zeros enter from the right. Signedness does not change the operation. Carrier bits above `W` are zero in the result.

Design point: masking the count to `log2(W)` bits keeps every count in the range 0 to `W-1`. No count is out of range and none needs a fault or a special case. A count of `W` or larger wraps modulo `W`, and a negative signed count uses its low bits in the same way.

Design point: `TSHL` is a raw-carrier operation. The value source is not validated as a number, and the shift produces no rounding, saturation, or numeric status. A left shift is the same bit operation for signed and unsigned types, so one rule serves all eight integer types.

<!-- PTO-READER-BLOCK: tile-c-tshl-inputs-outputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the integer value source. It is an existing, allocated Local Tile.
- `source1` is the integer shift-count source. Its physical shape, valid shape, and layout must match `source0`.
- `destination0` is a newly allocated Local Tile. Its backing `DataType` is the selected operation `DataType`, and its shape matches the sources.

One terminating `B.IOT` binds all three Tiles under a single `PE_MASK`; `B.IOR` and `B.IOS` are not accepted. `PE_MASK=0000` is a strict no-op before reads, allocation, or faults.

Design point: `source0` may be stored under any same-width, non-packed backing type and its bits are used unchanged. Legality separately requires the stored backing `DataType` of `source1` to be an integer type, independent of the operation `DataType`. A same-width floating count Tile, such as an `FP32` count with a `U32` shift, is therefore rejected, while `source0` has no such check.

<!-- PTO-READER-BLOCK: tile-c-tshl-effects role=effects -->
## Publication, definedness, and padding

Both source payloads are snapshotted before the first destination write. Either source may alias the destination, and both may name the same Tile; the result is computed from the old values.

The destination descriptor, the valid-region results, the padding, and every element's definedness publish as one commit. A rejected `TSHL` leaves descriptors, payloads, and allocation state unchanged.

Elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero`, `Max`, and `Min` are defined, with `Max` and `Min` using the integer `DataType` bounds; `Null`, selected when `B.DATR` is omitted, leaves them undefined. When an ExecutionMask is in force, inactive coordinates receive the mask's zero or merge value. `TSHL` has no global-memory effect.

<!-- PTO-READER-BLOCK: tile-c-tshl-constraints role=constraints -->
## Type, layout, and fault boundary

The accepted data-type set is `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`. Floating and packed operation types are rejected before effects.

The layout is `RowMajor` by default, or `CUBE_M16` or `CUBE_M32` when an explicit `Layout` selects it. `CUBE_N8`, Shared Tiles, and mixed layouts are illegal.

Every source element in the valid rectangle (every active one, when an ExecutionMask is in force) must be defined. Malformed bindings, missing or zero dimensions, undefined or mismatched sources, a non-integer count backing type, an unsupported layout, an unsupported `DataType`, or invalid destination capacity raises `Fault_TileLegality` before effects. A nondefault `CMode`, `Sat`, `Canonicalize`, secondary `DataType`, or `RMode` is illegal.

<!-- PTO-READER-BLOCK: tile-c-tshl-example role=example -->
## Non-normative example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

With `DataType=U8`, a value row `[0x81, 0x01, 0x01]` and a count row `[1, 7, 9]` produce `[0x02, 0x80, 0x02]`. The count 9 is masked to its low 3 bits, which give 1.

In macro form, `TSHL <Row=8, Col=64, S32>, T#1, T#2, ->T<2KB>` shifts all 8 x 64 elements of the `S32` value Tile `T#1` by the counts in `T#2`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TSHL <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSHL | TEPL | 0x009 | 9 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | integer value source |
| source1 | integer shift-count source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TSHL.asl -->
```asl
readonly func InstructionContractOperation_TSHL() => TileOperation
begin
    return TileOperation_TSHL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TSHL, DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Value, ShiftCount, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TSHL.asl -->
```asl
pure func InstructionContractDataTypeLegal_TSHL(
    data_type: TileDataType) => boolean
begin
    return TileBinaryDataTypeSupported(TileBinary_SHL, data_type);
end;

readonly func InstructionContractOperandsLegal_TSHL(
    destination: TileIndex,
    value_source: TileIndex,
    count_source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_SHL,
        destination,
        value_source,
        count_source);
end;

readonly func InstructionContractHandler_TSHL() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TSHL(
    destination: TileIndex,
    value_source: TileIndex,
    count_source: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_SHL,
        destination,
        value_source,
        count_source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Physical Rows derive from TSize, Col, and DataType; Rows and Col are powers of two and contain ValidRow x ValidCol.

## Legality

- TSHL is selected by TEPL carrier Mode 0 Function 9 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies ordered value and shift-count sources plus one newly allocated Local destination; B.IOR and B.IOS are not accepted.
- DataType is exactly S64, S32, S16, S8, U64, U32, U16, or U8; packed and floating formats reject before effects.
- B.DATR permits PadValueOrByteId and Layout; omitted Layout selects RowMajor, while an explicit Layout selects the operation Local layout; PE_MASK=0000 is a strict no-op before reads, allocation, or faults.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- For element width W, use the unsigned low log2(W) bits of source1 as the count and store the low W bits of source0 shifted left; signedness does not alter the operation and carrier bits above W are zero.
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

- BSTART.VEC TSHL, U8; B.DIM LB0=ValidCol; B.IOT Value, ShiftCount, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
