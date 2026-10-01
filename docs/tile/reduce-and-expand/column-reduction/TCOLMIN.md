<!-- GENERATED FROM: asl/tile/reduce-and-expand/column-reduction/TCOLMIN.asl -->
# TCOLMIN

**Normative ASL source:** `asl/tile/reduce-and-expand/column-reduction/TCOLMIN.asl`

Reduce each valid column to its minimum with exact typed row-order semantics.

## Normative identity {#PTO-INST-TILE-TCOLMIN}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcolmin-purpose role=purpose -->
## What TCOLMIN does

`TCOLMIN` is a Tile reduce-and-expand operation executed by the `SFU` engine. It reduces every valid column of one Local source Tile to a single element. It is selected by `TEPL` Mode 2 Function 18 (selector `0x052`) and has no standalone opcode.

Design point: the axis belongs to the operation identity, not to a bundle field: `TEPL` fixes `TileAxis_Column` as a constant argument, and the destination shape repeats it as a logical dimension of one, so the direction follows from the mnemonic alone.

<!-- PTO-READER-BLOCK: tile-tcolmin-mechanism role=mechanism -->
## Element and Tile mechanism

Preflight checks the bundle schema, the source descriptor, source definedness, source encodings, the destination capacity, and the operand schema. Only then does `ExecuteTileReduction` walk every valid column: the accumulator is initialized from the first row of that column and the remaining rows are combined into it.

Each step is the typed `TMIN` operation, in strictly increasing row order. An integer result keeps only the element-width bits of the exact result, and a floating result follows the numeric profile of the selected type.

Design point: `TCOLMIN` is an ordered fold, not a tree. Reassociation changes a rounded floating result, so the ASL fixes the order in which the elements are combined.

<!-- PTO-READER-BLOCK: tile-tcolmin-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the persistent Local source Tile. Every coordinate of its valid region participates, and its stored backing type may differ from the operation type only through an equal-width, non-packed carrier view.

- `destination0` is a newly allocated Local Tile with the operation DataType and a logical shape of one valid row by 60 valid columns, one result per valid column; its other physical coordinates are padding coordinates, and for `RowMajor` the physical row count is derived from the destination capacity.

- The destination uses the source layout, and only `RowMajor`, `CUBE_M16`, and `CUBE_M32` are admitted.

- The operands share one `PE_MASK`. `PE_MASK=0000` is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

Design point: a reduction does not accept the shared Local CUBE ExecutionMask. Any valid mask state, encoded in the bundle or injected into the model, makes the operand check fail, so the bundle faults instead of reducing a subset; every valid source coordinate is defined, encoding-checked, and included.

<!-- PTO-READER-BLOCK: tile-tcolmin-effects role=effects -->
## Publication, definedness, and padding

The destination becomes visible as one unit: descriptor, results, definedness, padding outside the valid result rectangle, and accumulated numeric status publish together, and a rejected execution publishes none of them. The source persists unchanged and the operation has no GM memory effect.

Physical destination coordinates outside the `1 x 60` valid region receive the selected `PadValue`. `Zero`, `Max`, and `Min` define those coordinates; `Null` leaves them undefined.

Design point: omitting `B.DATR` selects `Null`, while an explicit `PadValue` code `00` selects `Zero`. Omission and encoded zero differ, so a program that reads the whole physical destination must ask for `Zero`, `Max`, or `Min`.

<!-- PTO-READER-BLOCK: tile-tcolmin-constraints role=constraints -->
## Type, layout, and fault boundary

The accepted operation types are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. The destination DataType equals the operation type. The source may be stored with a different same-width, non-packed backing type, but `RCPE6M2` must never be a reduction backing, and an active bundle must resolve the operation DataType from `BSTART` or reject.

- Exactly one terminating Local `B.IOT` supplies the source and the new destination, so `B.IOR`, `B.IOS`, a second `B.IOT`, a nonterminating binding, and a destination that names the source are illegal.

- A malformed binding stream, a missing or zero dimension, an unsupported DataType, a bad, mixed, or mismatched source layout, an undefined source element, or an invalid source encoding raises `Fault_TileLegality` before effects; a result shape, `TSize`, rename, or capacity failure raises `Fault_TileAllocation` before publication.

Design point: the comparison step compares floating values through the floating order key, which the architecture defines for `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, and `E5M2`. Every floating type admitted here therefore reaches a defined element result, so legality and the executable definition agree.

<!-- PTO-READER-BLOCK: tile-tcolmin-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `TCOLMIN` example, the column set `[[1, 4], [3, 2]]` reduces to `[1, 2]`: the left column keeps row 0 and the right column keeps row 1.

For an 8 x 64 `FP32` source whose valid region is 7 x 60 with `Zero` padding, the walk visits 60 valid columns and performs 6 combine steps in each, so the destination receives 60 results in a `1 x 60` valid region inside the 8 x 64 shape derived from a `2KB` `TSize`, where 452 of the 512 coordinates are padding that `Zero` defines.

In macro form the same operation is written `TCOLMIN <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero>, T#1, ->T<2KB>`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TCOLMIN <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCOLMIN | TEPL | 0x052 | 18 | 2 | ExecuteTileReduction |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### B.DATR.PadValueOrByteId (`PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID`)

Carries the operation-selected PadValue or ByteId union field.

**Encoded zero:** For PadValue operations code zero selects Zero; for ByteId operations it selects ByteId zero.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | Zero-or-ByteId0 |
| 1 | assigned | Max-or-ByteId1 |
| 2 | assigned | Min-or-ByteId2 |
| 3 | assigned | Null-or-ByteId3 |

**Reserved-value behavior:** All four encodings are assigned; the selected operation separately validates whether the field is PadValue, ByteId, or inapplicable.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local operation-type numeric destination |
| source0 | persistent Local numeric source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/column-reduction/TCOLMIN.asl -->
```asl
readonly func InstructionContractOperation_TCOLMIN() => TileOperation
begin
    return TileOperation_TCOLMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCOLMIN, DataType
B.DATR Layout, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/column-reduction/TCOLMIN.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCOLMIN(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCOLMIN(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileReduction(
        TileReduction_MIN,
        TileAxis_Column,
        destination,
        source);
end;

readonly func InstructionContractHandler_TCOLMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;

func InstructionContractExecute_TCOLMIN(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCOLMIN(
        destination,
        source);
    ExecuteTileReduction(
        TileReduction_MIN,
        TileAxis_Column,
        destination,
        source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- TCOLMIN computes a typed increasing-row TMIN fold initialized from row zero; the scan order is architectural and tree reassociation is not permitted.

## Legality

- TCOLMIN is selected by the TEPL raw encoding carrier Mode 2 Function 18; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent Local source and one newly allocated Local destination. B.IOR, B.IOS, a second B.IOT, or a nonterminating binding is illegal.
- The operation DataType selected by BSTART is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- The destination DataType equals the selected operation DataType.
- The source is a fully defined persistent numeric Tile with a legal descriptor in the selected RowMajor, CUBE_M16, or CUBE_M32 layout whose ValidRow, ValidCol, and physical Col exactly match the B.DIM-derived source geometry; its stored backing DataType MAY differ from the operation DataType only when the unchanged TileCarrierWidthCompatible relation admits equal-width, non-packed interpretation. RCPE6M2 MUST NOT be a reduction backing. Every valid source coordinate MUST be defined and encoding-valid under the operation DataType. All valid source coordinates are checked and included in the reduction; Local CUBE ExecutionMask is unsupported and MUST reject before effects, including when mask state is injected directly into the model. For a cross-type view, backing encodings are not independently validated. The source descriptor, backing DataType, and payload persist unchanged without retagging or numeric conversion. The source capacity is checked by generic allocation and the reduction operation imposes no additional 2048-byte ceiling.
- The destination has logical ValidRow equal to one and ValidCol equal to source.ValidCol. For RowMajor, Rows equals DerivedTileRows(DstCapacity, source physical Columns, DstDataType) and Columns equals source physical Columns. For CUBE_M16/M32, Rows equals source Rows and Columns equals align_up(Dst.ValidColumns, Dst CellCols), where Dst CellCols is computed from destination DataType.
- Layout and PadValueOrByteId are the only applicable nonzero B.DATR fields. Source and destination share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.
- An active bundle MUST resolve the operation DataType from BSTART or reject; a direct semantic call with no active bundle uses source backing DataType as the operation-type fallback.

## State effects

- For each valid column, compute a typed increasing-row TMIN fold initialized from row zero.
- Write the operation-typed reduction value without widening integer arithmetic or reassociating the fold.
- Apply the selected PadValue to physical destination coordinates outside the valid result rectangle, then publish the complete result atomically.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, name-allocation, and storage preflight precedes the source snapshot.
- The source is scanned in strictly increasing row order; the source persists and is never modified.
- Numeric status, all valid results, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType, unsupported, mixed, or mismatched source layout, undefined source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects.
- An unrepresentable result shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.
- Floating numeric status is accumulated across the architectural fold and publishes atomically with the result.

## Examples

- BSTART.SFU TCOLMIN, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
