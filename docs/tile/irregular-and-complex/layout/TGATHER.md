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
## What TGATHER does

`TGATHER` builds a new Local Tile by reading, for each destination element, a source row chosen by an index Tile. The column never changes: destination `[r,c]` receives source `[index[r,c], c]`.

Design point: `TGATHER` is selected by `BSTART.SFU` with TEPL Mode 3 Function 15 (selector `0x06F`) and has no standalone opcode.

<!-- PTO-READER-BLOCK: tile-tgather-mechanism role=mechanism -->
## Index rule

Each index element is read as an unsigned row number from its low 16, 32, or 64 bits, after a signed index has been checked to be nonnegative. The selected source element is copied bit for bit; no numeric conversion runs, and an unusual floating encoding is not rejected.

Design point: the index selects a logical source row and never flattens, wraps, clamps, or selects another column. The source must therefore have at least as many valid columns as the destination, but it may have more.

Design point: every index is checked before any write. A negative index, an index at or above the source ValidRow, an undefined index, or an undefined selected source element rejects the bundle, so a bad index never leaves a partial result. [Indexed rearrangement legality](../../model/legality/indexed-rearrangement.md) owns these checks.

<!-- PTO-READER-BLOCK: tile-tgather-inputs-outputs role=inputs-outputs -->
## Operands, shape, and type

- `source0` is the persistent Local value source.
- `source1` is the persistent Local row-index source, of type `S16`, `U16`, `S32`, `U32`, `S64`, or `U64`.
- `destination0` is the newly allocated value destination, with the same type as `source0`.

The value type may be any non-packed 8-, 16-, 32-, or 64-bit type: HiF8, E4M3, E5M2, E3M2, E2M3, E8M0, E6M2, RCPE6M2, S8, U8, FP16, BF16, S16, U16, FP32, TF32, HF32, S32, U32, FP64, S64, or U64.

`B.DIM` LB0 gives the destination ValidCol; an omitted LB0 takes the architectural default one, and an explicitly encoded zero is illegal. LB1 defaults to ValidRow 1, and LB2 defaults to Col = ValidCol. The index and destination valid shapes must be equal and nonzero.

One terminating `B.IOT` carries both sources and the destination; `B.IOS` is illegal, and any `B.IOR` whose selectors are not all zero is illegal (an explicitly all-zero `B.IOR` names GPR0 only, consumes no operand, and is accepted). All three operands must pass the generic descriptor check, which excludes CUBE layouts. `B.DATR` may carry only a `Layout`, which changes only the destination physical placement.

<!-- PTO-READER-BLOCK: tile-tgather-effects role=effects -->
## Publication and definedness

Both sources are snapshotted after complete preflight. The complete destination payload, definedness, `Null` padding, and descriptor then publish as one operation. Every valid destination element becomes defined, and physical elements outside the valid region stay undefined.

Both sources persist unchanged. `TGATHER` has no global-memory effect and records no numeric status; a rejected bundle publishes no destination state.

<!-- PTO-READER-BLOCK: tile-tgather-constraints role=constraints -->
## Legality and fault boundary

Malformed bindings, `B.IOR`, `B.IOS`, an unsupported value or index type, a zero or mismatched valid shape, too few source columns, a negative, out-of-range, or undefined index, an undefined selected source element, a reserved `Layout`, or insufficient destination capacity raise the applicable Tile fault before effects.

All three bindings use the same `PE_MASK`; the three-bit PEMode encodes only `1000`, `0100`, `0010`, `0001`, `1100`, `1110`, `1111`, and `0000`. `PE_MASK=0000` is a strict no-op after the `B.IOT` size-code encoding check: no Tile read, index check, allocation, or operation fault follows, but an illegal `B.IOT` size code still raises `Fault_IllegalInstruction`.

<!-- PTO-READER-BLOCK: tile-tgather-example role=example -->
## Non-normative contract sketch

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

A U32 value source has 3 valid rows and 2 valid columns: row 0 is 10, 11; row 1 is 20, 21; row 2 is 30, 31. The U16 index Tile has 2 rows: 2, 0 and 1, 1.

Destination `[0,0]` reads source `[2,0]` = 30 and `[0,1]` reads source `[0,1]` = 11. Row 1 reads source `[1,0]` and `[1,1]`, which are 20 and 21. An index of 3 anywhere would reject the bundle, because the source has only 3 valid rows.

In macro form, an 8 x 16 U32 gather with `T#1` as the value source and `T#2` as the index Tile is written below. The destination holds 8 x 16 x 4 = 512 bytes.

```text
TGATHER <Row=8, Col=16, U32>, T#1, T#2, ->T<512B>
```
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
