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

`TSCATTER` writes each source element into a destination row chosen by an index Tile. The column never changes: source `[r,c]` goes to destination `[index[r,c], c]`. Rows that no index selects hold zero.

Design point: `TSCATTER` is selected by `BSTART.SFU` with TEPL Mode 3 Function 16 (selector `0x070`) and has no standalone opcode.

<!-- PTO-READER-BLOCK: tile-c-tscatter-mechanism role=mechanism -->
## Operation mechanism

First, every physical destination element, including padding, is set to the all-zero carrier of the value type and marked defined. That carrier is the positive or integer zero for every accepted type except `E8M0`, `E6M2`, and `RCPE6M2`, which have no zero encoding. Then each source element is copied bit for bit to its selected destination element. No previous destination value is read.

Design point: two source coordinates may not select the same destination element. Duplicates are rejected rather than ordered, so the result does not depend on the order in which source elements are visited.

Design point: every index is checked before any write. A negative index, an index at or above the destination ValidRow, or a duplicate destination coordinate rejects the bundle, so a bad index never leaves a partial result. [Indexed rearrangement execution](../../model/execution/indexed-rearrangement.md) describes both steps.

<!-- PTO-READER-BLOCK: tile-c-tscatter-inputs-outputs role=inputs-outputs -->
## Operands, shape, and type

- `source0` is the persistent Local value source.
- `source1` is the persistent Local row-index source, of type `S16`, `U16`, `S32`, `U32`, `S64`, or `U64`.
- `destination0` is the newly allocated, zero-initialized value destination.

The value type may be any non-packed 8-, 16-, 32-, or 64-bit type: `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `HiF8`, `E4M3`, `E5M2`, `E3M2`, `E2M3`, `E8M0`, `E6M2`, `RCPE6M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, or `U8`.

The two sources share one nonzero valid shape. The destination ValidCol, from `B.DIM` LB0, must equal the source ValidCol; an omitted LB0 takes the architectural default one, and an explicitly encoded zero is illegal. The destination ValidRow comes from LB1, defaults to 1, and may differ from the source ValidRow. LB2 defaults to Col = ValidCol.

One terminating `B.IOT` carries both sources and the destination; `B.IOS` is illegal, and any `B.IOR` whose selectors are not all zero is illegal (an explicitly all-zero `B.IOR` names GPR0 only, consumes no operand, and is accepted). All three operands must pass the generic descriptor check, which excludes CUBE layouts. `B.DATR` may carry only a `Layout`; its encoded-zero `PadValueOrByteId` means the typed zero initialization.

<!-- PTO-READER-BLOCK: tile-c-tscatter-effects role=effects -->
## Definedness, padding, and publication

Both sources are snapshotted after complete preflight and before zero initialization. The complete destination payload, physical definedness, and descriptor then publish as one operation.

Every physical destination element is defined, including rows that no index selects and the padding outside the valid region; they all hold the value type's all-zero carrier. This differs from `TGATHER`, whose padding stays undefined.

Source Tiles persist unchanged. `TSCATTER` has no global-memory effect and records no numeric status.

<!-- PTO-READER-BLOCK: tile-c-tscatter-constraints role=constraints -->
## Legality, fault, and order boundaries

Malformed bindings, `B.IOR`, `B.IOS`, an unsupported value or index type, a zero or mismatched source shape, a destination column mismatch, a negative or out-of-range index, a duplicate destination coordinate, an undefined source, a reserved `Layout`, or insufficient destination capacity raise the applicable Tile fault before effects.

All three bindings use the same `PE_MASK`; the three-bit PEMode encodes only `1000`, `0100`, `0010`, `0001`, `1100`, `1110`, `1111`, and `0000`. `PE_MASK=0000` is a strict no-op after the `B.IOT` size-code encoding check: no Tile read, index or duplicate check, allocation, zero initialization, or operation fault follows, but an illegal `B.IOT` size code still raises `Fault_IllegalInstruction`.

<!-- PTO-READER-BLOCK: tile-c-tscatter-example role=example -->
## Non-normative example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

The U32 value source holds 5, 6 in row 0 and 7, 8 in row 1. The index rows are 2, 0 and 0, 1. The destination has 3 valid rows and 2 valid columns.

Column 0 receives 5 at row 2 and 7 at row 0. Column 1 receives 6 at row 0 and 8 at row 1. The destination rows are 7, 6; then 0, 8; then 5, 0. Index rows 2, 0 and 2, 1 would instead reject the bundle, because both elements of column 0 select row 2.

In macro form, an 8 x 16 U32 scatter with `T#1` as the value source and `T#2` as the index Tile is written below. The destination holds 8 x 16 x 4 = 512 bytes.

```text
TSCATTER <Row=8, Col=16, U32>, T#1, T#2, ->T<512B>
```
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
