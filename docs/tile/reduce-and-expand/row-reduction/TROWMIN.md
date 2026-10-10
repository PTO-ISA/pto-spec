<!-- GENERATED FROM: asl/tile/reduce-and-expand/row-reduction/TROWMIN.asl -->
# TROWMIN

**Normative ASL source:** `asl/tile/reduce-and-expand/row-reduction/TROWMIN.asl`

Reduce each valid row to its minimum with exact typed column-order semantics.

## Normative identity {#PTO-INST-TILE-TROWMIN}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-trowmin-purpose role=purpose -->
## What TROWMIN does

`TROWMIN` is a Tile reduce-and-expand operation executed by the `SFU` engine. It reduces every valid row of one Local source Tile to a single element. It is selected by `TEPL` Mode 2 Function 2 (selector `0x042`) and has no standalone opcode.

Design point: the axis belongs to the operation identity, not to a bundle field: `TEPL` fixes `TileAxis_Row` as a constant argument, and the destination shape repeats it as a logical dimension of one, so the direction follows from the mnemonic alone.

<!-- PTO-READER-BLOCK: tile-c-trowmin-mechanism role=mechanism -->
## Operation mechanism

Preflight checks the bundle schema, the source descriptor, source definedness, source encodings, the destination capacity, and the operand schema. Only then does `ExecuteTileReduction` walk every valid row: the accumulator is initialized from the first column of that row and the remaining columns are combined into it.

Each step is the typed `TMIN` operation, in strictly increasing column order. An integer result keeps only the element-width bits of the exact result, and a floating result follows the numeric profile of the selected type.

Design point: `TROWMIN` is an ordered fold, not a tree. Reassociation changes a rounded floating result, so the ASL fixes the order in which the elements are combined.

<!-- PTO-READER-BLOCK: tile-c-trowmin-inputs-outputs role=inputs-outputs -->
## Operands, shape, and type

- `source0` is the persistent Local source Tile. Every coordinate of its valid region participates, and its stored backing type may differ from the operation type only through an equal-width, non-packed carrier view.

- `destination0` is a newly allocated Local Tile with the operation DataType and a logical shape of 7 valid rows by one valid column, one result per valid row; its other physical coordinates are padding coordinates, and for `RowMajor` the physical row count is derived from the destination capacity.

- The destination uses the source layout, and only `RowMajor`, `CUBE_M16`, and `CUBE_M32` are admitted. A 64-bit CUBE operand requires the `CUBE_M32` double-CELL mapping; `CUBE_M16` rejects it.

- The operands share one `PE_MASK`. `PE_MASK=0000` is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

Design point: a reduction does not accept the shared Local CUBE ExecutionMask. Any valid mask state, encoded in the bundle or injected into the model, makes the operand check fail, so the bundle faults instead of reducing a subset; every valid source coordinate is defined, encoding-checked, and included.

<!-- PTO-READER-BLOCK: tile-c-trowmin-effects role=effects -->
## Definedness, padding, and publication

The destination becomes visible as one unit: descriptor, results, definedness, padding outside the valid result rectangle, and accumulated numeric status publish together, and a rejected execution publishes none of them. The source persists unchanged and the operation has no GM memory effect.

Physical destination coordinates outside the `7 x 1` valid region receive the selected `PadValue`. `Zero`, `Max`, and `Min` define those coordinates; `Null` leaves them undefined.

Design point: omitting `B.DATR` selects `Null`, while an explicit `PadValue` code `00` selects `Zero`. Omission and encoded zero differ, so a program that reads the whole physical destination must ask for `Zero`, `Max`, or `Min`.

<!-- PTO-READER-BLOCK: tile-c-trowmin-constraints role=constraints -->
## Legality, fault, and order boundaries

The accepted operation types are `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, and `U8`. The destination DataType equals the operation type. The source may be stored with a different same-width, non-packed backing type, but `RCPE6M2` must never be a reduction backing, and an active bundle must resolve the operation DataType from `BSTART` or reject.

- Exactly one terminating Local `B.IOT` supplies the source and the new destination, so `B.IOR`, `B.IOS`, a second `B.IOT`, a nonterminating binding, and a destination that names the source are illegal.

- A malformed binding stream, a missing or zero dimension, an unsupported DataType, a bad, mixed, or mismatched source layout, an undefined source element, or an invalid source encoding raises `Fault_TileLegality` before effects; a result shape, `TSize`, rename, or capacity failure raises `Fault_TileAllocation` before publication.

Design point: the comparison step compares floating values through the floating order key, which the architecture defines for `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, and `E5M2`. Every floating type admitted here therefore reaches a defined element result, so legality and the executable definition agree.

<!-- PTO-READER-BLOCK: tile-c-trowmin-example role=example -->
## Non-normative example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `TROWMIN` example, the rows `[1, 4]` and `[3, 2]` reduce to `[1, 2]`: the first row keeps column 0 and the second row keeps column 1.

For an 8 x 64 `FP32` source whose valid region is 7 x 60 with `Zero` padding, the walk visits 7 valid rows and performs 59 combine steps in each, so the destination receives 7 results in a `7 x 1` valid region inside the 512 x 1 shape derived from a `2KB` `TSize`, where 505 of the 512 coordinates are padding that `Zero` defines.

In macro form the same operation is written `TROWMIN <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero>, T#1, ->T<2KB>`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TROWMIN <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TROWMIN | TEPL | 0x042 | 2 | 2 | ExecuteTileReduction |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/row-reduction/TROWMIN.asl -->
```asl
readonly func InstructionContractOperation_TROWMIN() => TileOperation
begin
    return TileOperation_TROWMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TROWMIN, DataType
B.DATR Layout, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/row-reduction/TROWMIN.asl -->
```asl
pure func InstructionContractDataTypeLegal_TROWMIN(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TROWMIN(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileReduction(
        TileReduction_MIN,
        TileAxis_Row,
        destination,
        source);
end;

readonly func InstructionContractHandler_TROWMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;

func InstructionContractExecute_TROWMIN(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TROWMIN(
        destination,
        source);
    ExecuteTileReduction(
        TileReduction_MIN,
        TileAxis_Row,
        destination,
        source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- TROWMIN computes a typed increasing-column TMIN fold initialized from column zero; the scan order is architectural and tree reassociation is not permitted.

## Legality

- TROWMIN is selected by the TEPL raw encoding carrier Mode 2 Function 2; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent Local source and one newly allocated Local destination. B.IOR, B.IOS, a second B.IOT, or a nonterminating binding is illegal.
- The operation DataType selected by BSTART is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- The destination DataType equals the selected operation DataType.
- The source is a fully defined persistent numeric Tile with a legal descriptor in the selected RowMajor, CUBE_M16, or CUBE_M32 layout whose ValidRow, ValidCol, and physical Col exactly match the B.DIM-derived source geometry; its stored backing DataType MAY differ from the operation DataType only when the unchanged TileCarrierWidthCompatible relation admits equal-width, non-packed interpretation. RCPE6M2 MUST NOT be a reduction backing. Every valid source coordinate MUST be defined and encoding-valid under the operation DataType. All valid source coordinates are checked and included in the reduction; Local CUBE ExecutionMask is unsupported and MUST reject before effects, including when mask state is injected directly into the model. For a cross-type view, backing encodings are not independently validated. The source descriptor, backing DataType, and payload persist unchanged without retagging or numeric conversion. The source capacity is checked by generic allocation and the reduction operation imposes no additional 2048-byte ceiling.
- The destination has ValidRow equal to source.ValidRow and logical ValidCol equal to one. For RowMajor, Rows equals DerivedTileRows(DstCapacity, 1, DstDataType) and Columns equals one. For CUBE_M16/M32, Columns equals source Columns and Rows equals the minimum legal physical Rows covering Dst.ValidRows (16 for M16, 32 for M32).
- Layout and PadValueOrByteId are the only applicable nonzero B.DATR fields. Source and destination share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.
- An active bundle MUST resolve the operation DataType from BSTART or reject; a direct semantic call with no active bundle uses source backing DataType as the operation-type fallback.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- For each valid row, compute a typed increasing-column TMIN fold initialized from column zero.
- Write the operation-typed reduction value without widening integer arithmetic or reassociating the fold.
- Apply the selected PadValue to physical destination coordinates outside the valid result rectangle, then publish the complete result atomically.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, name-allocation, and storage preflight precedes the source snapshot.
- The source is scanned in strictly increasing column order; the source persists and is never modified.
- Numeric status, all valid results, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType, unsupported, mixed, or mismatched source layout, undefined source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects.
- An unrepresentable result shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.
- Floating numeric status is accumulated across the architectural fold and publishes atomically with the result.

## Examples

- BSTART.SFU TROWMIN, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
