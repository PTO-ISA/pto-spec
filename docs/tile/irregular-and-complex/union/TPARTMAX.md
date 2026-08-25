<!-- GENERATED FROM: asl/tile/irregular-and-complex/union/TPARTMAX.asl -->
# TPARTMAX

**Normative ASL source:** `asl/tile/irregular-and-complex/union/TPARTMAX.asl`

Form the origin-anchored union of two Local Tiles and select the maximum of overlap elements.

## Normative identity {#PTO-INST-TILE-TPARTMAX}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tpartmax-purpose role=purpose -->
## Purpose

`TPARTMAX` forms an origin-anchored union and selects overlap maxima.

<!-- PTO-READER-BLOCK: tile-tpartmax-mechanism role=mechanism -->
## Execution mechanism

The ASL DOC contract selects `TileHandler_ExecuteTilePartial` through the instruction's selector-encoded block carrier.

Two origin-anchored Local source rectangles are snapshotted after coverage, type, layout, definedness, encoding, mask, and allocation preflight.

<!-- PTO-READER-BLOCK: tile-tpartmax-inputs-outputs role=inputs-outputs -->
## Operands and descriptors

`destination0` is the new Local union destination; `source0` is the persistent Local left source anchored at origin; `source1` is the persistent Local right source anchored at origin.

Sources remain persistent unless the current contract explicitly names a consumed or replaced state; destination descriptors are published only after complete preflight.

<!-- PTO-READER-BLOCK: tile-tpartmax-effects role=effects -->
## Publication and ordering

Overlap coordinates apply the selected typed operation; coordinates covered by only one source copy that source bit-for-bit.

The result, sticky numeric flags, descriptor, and undefined Null padding outside the valid rectangle publish atomically.

<!-- PTO-READER-BLOCK: tile-tpartmax-constraints role=constraints -->
## Legality, padding, and faults

Malformed bindings, unsupported types or layouts, invalid shapes, undefined consumed elements, illegal attributes, or insufficient destination capacity are rejected before source snapshots or publication.

Allocation failure raises the owner-defined Tile allocation fault; other rejected schema or value conditions raise the owner-defined legality, bundle-control, or memory fault without partial effects.

<!-- PTO-READER-BLOCK: tile-tpartmax-example role=example -->
## Non-normative contract sketch

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

Read `BSTART.SFU TPARTMAX, S16; B.DIM LB0=16; B.IOT Left, Right, mask=1111, <last>, ->Dst<1>; BSTOP` as a non-normative binding walkthrough, then use the generated contract below for exact dimensions, attributes, and fault behavior.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TPARTMAX <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TPARTMAX | TEPL | 0x073 | 19 | 3 | ExecuteTilePartial |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local union destination |
| source0 | persistent Local left source anchored at origin |
| source1 | persistent Local right source anchored at origin |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/union/TPARTMAX.asl -->
```asl
readonly func InstructionContractOperation_TPARTMAX() => TileOperation
begin
    return TileOperation_TPARTMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TPARTMAX, FP32|FP16|BF16|S32|S16|S8|U32|U16|U8
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional; omission defaults to 1)
B.DIM LB2=Col (optional; omission defaults to ValidCol)
B.IOT exactly two persistent Local sources and one new Local destination, common PE_MASK, <last>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/union/TPARTMAX.asl -->
```asl
pure func InstructionContractDataTypeLegal_TPARTMAX(
    data_type: TileDataType) => boolean
begin
    return TilePartialDataTypeSupportedForOperation(
        TilePartial_MAX,
        data_type);
end;

readonly func InstructionContractOperandsLegal_TPARTMAX(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTilePartial(
        TilePartial_MAX,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TPARTMAX() => TileSemanticHandler
begin
    return TileHandler_ExecuteTilePartial;
end;

func InstructionContractExecute_TPARTMAX(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    assert InstructionContractOperandsLegal_TPARTMAX(
        destination,
        source_left,
        source_right);
    ExecuteTilePartial(
        TilePartial_MAX,
        destination,
        source_left,
        source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow one; omitted LB2 selects physical Col equal to ValidCol.
- B.DATR, B.IOR, and B.IOS are absent. Both sources and the destination use the BSTART DataType and row-major layout.
- Each source rectangle is anchored at origin. A coordinate covered by exactly one source is copied bit-for-bit; a coordinate covered by both sources applies the selected typed operation. Physical padding is Null.

## Legality

- TPARTMAX uses the TEPL encoding carrier Mode 3 Function 19, canonically assembles with BSTART.SFU, and has no standalone opcode.
- Exactly two persistent nonempty Local sources and one newly allocated Local destination are supplied by a terminated B.IOT stream. B.DATR, B.IOR, and B.IOS are illegal.
- Source and destination DataType is exactly one of FP32, FP16, BF16, S32, S16, S8, U32, U16, or U8. All are row-major and use one PE_MASK.
- Both source valid rectangles are origin-anchored, fit within ValidRow by ValidCol, and at least one source covers the entire destination valid rectangle. Thus no valid destination coordinate is uncovered.
- Every valid source element is defined; floating encodings are valid.

## State effects

- At an overlap coordinate, typed maximum selection is applied with the common DataType's exact arithmetic, ordering, rounding, NaN, signed-zero, and status behavior.
- At a coordinate covered by only one source, that source element is copied bit-for-bit without arithmetic status.
- Every physical destination coordinate outside ValidRow by ValidCol is undefined Null padding.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, type, shape, capacity, coverage, mask, destination-name, source-definedness, source-encoding, and allocation preflight precedes both source snapshots.
- The sources persist. The result payload, sticky numeric flags, Null padding definedness, and renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- Missing, surplus, shared, scalar, data-attribute, malformed, unterminated, mixed-mask, type, layout, shape, undefined-source, or invalid-floating-encoding input raises Fault_TileLegality before effects.
- An unrepresentable destination shape, unavailable renamed destination, insufficient TSize, or exhausted Tile capacity raises Fault_TileAllocation before effects.
- PE_MASK zero completes as a strict no-op before descriptor reads, source reads, allocation, faults, numeric status, padding, or payload effects.

## Examples

- BSTART.SFU TPARTMAX, S16; B.DIM LB0=16; B.IOT Left, Right, mask=1111, <last>, ->Dst<1>; BSTOP
