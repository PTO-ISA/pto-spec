<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TSEL.asl -->
# TSEL

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TSEL.asl`

Select exact element encodings under one legacy Predicate, CUBE PredicateCell, or GPR mask carrier.

## Normative identity {#PTO-INST-TILE-TSEL}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tsel-purpose role=purpose -->
## What TSEL does

`TSEL` builds a new Local Tile by choosing each element from one of two source Tiles under a predicate. Where the predicate is 1 it takes the `SrcTrue` element, and where it is 0 it takes the `SrcFalse` element. The predicate is normally produced by `TCMP`.

Design point: `TSEL` has no standalone opcode. `BSTART.VEC` Mode 0 Function 26 (TEPL selector `0x01A`) selects it. `PadValueOrByteId` is the only applicable `B.DATR` field.

<!-- PTO-READER-BLOCK: tile-c-tsel-mechanism role=mechanism -->
## Operation mechanism

After complete preflight, `TSEL` snapshots the predicate and both data sources. For each coordinate of the valid rectangle `ValidRow x ValidCol`, it reads the predicate and copies the exact bits of the chosen source element into the destination.

Design point: `TSEL` is a raw-carrier operation. It does not require selected payloads to be valid encodings of the operation `DataType`, and it performs no conversion, rounding, saturation, canonicalization, or numeric-status update. A selected NaN keeps its payload, and a signaling NaN does not raise invalid. Choosing between two values needs no arithmetic, so the destination holds exactly the bits that were chosen.

Design point: the selected operation `DataType` still matters. It is the destination backing type and sets the element width that each source's backing type must match. In the PredicateCell form it must equal the PredicateCell basis, and in the GPR form it sets the mask-word geometry. Validating numeric encodings is left to any later operation that interprets the values.

<!-- PTO-READER-BLOCK: tile-c-tsel-inputs-outputs role=inputs-outputs -->
## Operands, shape, and type

- `source0` is the predicate: a packed Predicate Tile, a CUBE PredicateCell Tile, or the first mask GPR.
- `source1` is `SrcTrue`, the Tile selected where the predicate is 1.
- `source2` is `SrcFalse`, the Tile selected where the predicate is 0.
- `destination0` is a newly allocated `RowMajor` or CUBE numeric Tile. Its `DataType` is the selected operation `DataType`.

`TSEL` consumes exactly one of three mutually exclusive predicate carriers.

| Form | Data layout | Bindings |
| --- | --- | --- |
| Legacy | `RowMajor` | `B.IOT` Predicate, SrcTrue; then `B.IOT` SrcFalse and the new destination |
| PredicateCell | `CUBE_M16` or `CUBE_M32` | The same two `B.IOT` records, with a PredicateCell as the predicate |
| GPR | `CUBE_M16` or `CUBE_M32` | One `B.IOT` with SrcTrue, SrcFalse, and the new destination, plus one source-only `B.IOR` carrying the mask |

The legacy predicate is a packed Tile with one bit per element, and every predicate bit in its valid region must be defined. A PredicateCell holds one byte per element, and its basis type must equal the operation `DataType`. A PredicateCell byte is checked and read at every valid coordinate, or only at active coordinates when an ExecutionMask is in force, and each such byte must be defined and canonical: `0x00` or `0x01`. In the GPR form, an 8-bit operation type uses two mask GPRs, and 16- and 32-bit types use one.

Each data source may use a different same-width, non-packed backing type. Its bits are copied unchanged into a destination tagged with the operation `DataType`.

<!-- PTO-READER-BLOCK: tile-c-tsel-effects role=effects -->
## Definedness, padding, and publication

The predicate and both data payloads are snapshotted before the first destination write. Both data sources may name the same Tile, and either may alias the destination; each read sees old values.

The selected payload, the padding definedness, and the destination descriptor publish together. A rejected `TSEL` has no architectural effect, and all three sources persist either way.

Elements outside `ValidRow x ValidCol` receive the selected `PadValue`. `Zero`, `Max`, and `Min` are defined, and `Null`, selected when `B.DATR` is omitted, leaves them undefined.

In the CUBE forms, an ExecutionMask may be in force. Inactive coordinates then receive the mask's zero or merge value instead of a selected element. `TSEL` has no global-memory effect.

<!-- PTO-READER-BLOCK: tile-c-tsel-constraints role=constraints -->
## Legality, fault, and order boundaries

The operation `DataType` set is `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`. The CUBE forms further restrict it to the CUBE predicate types, which exclude the 64-bit types.

Source data must be defined (at every active coordinate, in the CUBE forms), even though its encoding is not validated. `PE_MASK=0000` is a strict no-op before GPR, predicate, source, allocation, or payload checks.

A malformed or mixed carrier schema, a missing dimension, an unsupported `DataType`, a PredicateCell basis that differs from the operation `DataType`, a noncanonical or undefined active predicate byte, undefined active source data, a shape or layout mismatch, insufficient destination capacity, or allocation failure rejects before any effect.

<!-- PTO-READER-BLOCK: tile-c-tsel-example role=example -->
## Non-normative example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

With `DataType=S32`, predicate bits `[1, 0, 1]`, a `SrcTrue` row `[10, 20, 30]`, and a `SrcFalse` row `[-1, -2, -3]` produce `[10, -2, 30]`. With `DataType=FP32`, a selected `0x7FC00001` NaN is copied as `0x7FC00001`, and no status is recorded.

In macro form, `TSEL <Row=8, Col=64, FP32>, U#1, T#1, T#2, ->T<2KB>` uses the packed Predicate Tile `U#1` to choose between `T#1` and `T#2` for all 8 x 64 elements.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TSEL <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSEL | TEPL | 0x01A | 26 | 0 | ExecuteTileSelect |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new RowMajor or CUBE numeric destination |
| source0 | legacy packed Predicate, CUBE PredicateCell, or first GPR-mask role |
| source1 | persistent source selected by predicate one |
| source2 | persistent source selected by predicate zero |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TSEL.asl -->
```asl
readonly func InstructionContractOperation_TSEL() => TileOperation
begin
    return TileOperation_TSEL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TSEL, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT PredicateCell, SrcTrue, mask=PE_MASK, <last>, ->DstTile<TSize> OR GPR predicate form without PredicateCell
B.IOT SrcFalse, <last>, ->DstTile<TSize> (CellReg form only)
B.IOR predicate-GPR source (GPR form only)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TSEL.asl -->
```asl
pure func InstructionContractDataTypeLegal_TSEL(
    data_type: TileDataType) => boolean
begin
    return TileSelectDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TSEL(
    destination: TileIndex,
    predicate: TileIndex,
    source_true: TileIndex,
    source_false: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileSelect(
        destination,
        predicate,
        source_true,
        source_false);
end;

readonly func InstructionContractHandler_TSEL() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileSelect;
end;

func InstructionContractExecute_TSEL(
    destination: TileIndex,
    predicate: TileIndex,
    source_true: TileIndex,
    source_false: TileIndex)
begin
    assert InstructionContractOperandsLegal_TSEL(
        destination,
        predicate,
        source_true,
        source_false);
    ExecuteTileSelect(
        destination,
        predicate,
        source_true,
        source_false);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- A zero predicate bit selects SrcFalse and a one predicate bit selects SrcTrue. TSEL is a raw-carrier operation: it copies the chosen source backing bits, publishes the destination with the selected operation DataType, does not require TileNumericEncodingValid for selected payloads, and performs no conversion or numeric-status update.

## Legality

- TSEL selects VEC Mode 0 Function 26. PE_MASK=0000 is a strict no-op before GPR, predicate, source, allocation, or payload checks.
- Legacy RowMajor form uses two ordered B.IOT records: packed Predicate plus SrcTrue, then SrcFalse plus one new destination; B.IOR is absent, each source backing is checked independently; exact backing/operation type identity is legal, while cross-type source/backing pairs require equal width and non-four-bit carriers, and selected bits are copied raw.
- CUBE_M16/M32 PredicateCell form uses the same two-record Tile structure with a descriptor-valid PredicateCell whose basis equals the operation DataType and whose ExecutionMask-active bytes are defined and canonical, while valid shape/layout and physical geometry match the numeric sources. Each source backing is checked independently; exact backing/operation type identity is legal, while cross-type source/backing pairs require equal width and non-four-bit carriers; B.IOR is absent.
- CUBE_M16/M32 GPR form uses one B.IOT with SrcTrue, SrcFalse, and one new CUBE destination plus one source-only B.IOR carrying the complete mask. The operation type is a 32-bit or 16-bit type from the closed CUBE domain, plus U8; each source backing is checked independently; exact backing/operation type identity is legal, while cross-type source/backing pairs require equal width and non-four-bit carriers; U8 consumes two mask GPRs and other accepted types consume one.
- Legacy, PredicateCell, and GPR forms are complete and mutually exclusive. PadValueOrByteId is the only applicable B.DATR field.

## State effects

- For each logical element, read the selected carrier predicate and copy the exact SrcTrue encoding when one or SrcFalse encoding when zero.
- Perform no rounding, saturation, canonicalization, arithmetic, or floating-status update.
- Publish selected payload, padding definedness, and destination descriptor atomically. Rejection has no architectural effect and all three sources persist.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, field, type, geometry, layout, definedness, predicate-kind, mask, and destination-capacity preflight precedes all source snapshots and allocation.
- Predicate bits and both data payloads are snapshotted before the first destination write, so equal sources and source/destination aliases observe read-old values.

## Exceptions

- Malformed or mixed carrier schemas, missing dimensions, unsupported DataType, wrong operation-type PredicateCell basis, noncanonical or undefined ExecutionMask-active predicate bytes, undefined active source data, shape/layout mismatch, insufficient destination capacity, or allocation failure rejects before effects.
- TSEL is a raw-carrier select and does not raise floating invalid solely because a selected source payload encodes NaN.

## Examples

- BSTART.VEC TSEL, U8; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT Predicate, SrcTrue, mask=PE_MASK; B.IOT SrcFalse, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
