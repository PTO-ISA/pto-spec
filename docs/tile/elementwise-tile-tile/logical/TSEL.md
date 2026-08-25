<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TSEL.asl -->
# TSEL

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TSEL.asl`

Select exact element encodings from two Local Tiles under one packed predicate Tile.

## Normative identity {#PTO-INST-TILE-TSEL}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tsel-purpose role=purpose -->
## What TSEL does

`TSEL` selects exact carrier bits from two Tile sources under a packed predicate Tile.

<!-- PTO-READER-BLOCK: tile-c-tsel-mechanism role=mechanism -->
## Operation mechanism

Predicate bit zero selects the false input and bit one selects the true input; selected carrier bits are copied without numeric conversion.

<!-- PTO-READER-BLOCK: tile-c-tsel-inputs-outputs role=inputs-outputs -->
## Operands, shape, and type

- `destination0` identifies a newly allocated destination.

- `source0` supplies the packed predicate Tile.

- `source1` supplies a persistent source Tile.

- `source2` supplies a persistent source Tile.

- The closed applicable DataType set is `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`.

- Data Tiles use row-major layout unless this mnemonic explicitly selects another permitted layout.

- `LB0`, `LB1`, and `LB2` complete the valid and physical shape according to this mnemonic’s contract; every required valid extent is nonzero.

<!-- PTO-READER-BLOCK: tile-c-tsel-effects role=effects -->
## Definedness, padding, and publication

All source descriptors and payloads are validated and snapshotted before destination publication.

The complete destination payload, descriptor, definedness, padding state, and applicable numeric status publish atomically; rejection publishes none.

Null padding leaves physical coordinates outside the valid rectangle undefined; an explicit non-Null PadValue defines those coordinates with the selected typed value.

Source Tiles persist and are not modified by successful execution.

<!-- PTO-READER-BLOCK: tile-c-tsel-constraints role=constraints -->
## Legality, fault, and order boundaries

Complete binding schema, dimensions, DataType, layout, source definedness, numeric encoding, destination capacity, and allocation are preflighted before effects.

A failed legality or allocation check raises the applicable Tile fault without partial destination, status, or memory effects.

`PE_MASK=0000` is a strict no-op before operand reads, allocation, faults, numeric status, or payload effects.

<!-- PTO-READER-BLOCK: tile-c-tsel-example role=example -->
## Non-normative example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

`TSEL <bundle operands>` performs complete preflight and source snapshotting before atomically publishing the mnemonic-defined result and padding state.
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
| destination0 | new Local numeric destination |
| source0 | packed one-bit Local predicate mask |
| source1 | persistent Local source selected by one |
| source2 | persistent Local source selected by zero |

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
B.IOT Predicate, SrcTrue, mask=PE_MASK
B.IOT SrcFalse, mask=PE_MASK, <last>, ->DstTile<TSize>
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
- A zero predicate bit selects SrcFalse and a one predicate bit selects SrcTrue. TSEL is a raw-carrier operation: it copies the chosen source carrier bits, preserves the concrete DataType, does not require TileNumericEncodingValid for selected payloads, and performs no conversion or numeric-status update.

## Legality

- TSEL is selected only by VEC Mode 0 Function 26 and has no standalone opcode.
- Exactly two ordered Local B.IOT bindings are required. The first supplies packed Predicate and SrcTrue without Last or a destination; the second supplies SrcFalse and one new terminating destination. B.IOR, B.IOS, and additional bindings are illegal.
- The data DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8; every other type rejects before effects.
- SrcTrue, SrcFalse, and destination match physical shape, valid shape, row-major layout, and DataType; every valid element of both data sources is defined, and numeric encoding validity is not required for selected carrier payloads.
- Predicate uses predicate-kind storage, has the same Row, Col, ValidRow, and ValidCol as the data Tiles, and defines every valid predicate bit. An ordinary numeric Tile is not a legal mask.
- PadValueOrByteId is the only applicable B.DATR field. Explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.
- Both B.IOT bindings use one PE_MASK. PE_MASK=0000 is a strict no-op before schema, source, allocation, or payload checks.

## State effects

- For logical element i, read bit i mod 8 of byte floor(i/8), selecting the exact SrcTrue encoding when one and SrcFalse encoding when zero.
- Perform no rounding, saturation, canonicalization, arithmetic, or floating-status update.
- Publish selected payload, padding definedness, and destination descriptor atomically. Rejection has no architectural effect and all three sources persist.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, field, type, geometry, layout, definedness, predicate-kind, mask, and destination-capacity preflight precedes all source snapshots and allocation.
- Predicate bits and both data payloads are snapshotted before the first destination write, so equal sources and source/destination aliases observe read-old values.

## Exceptions

- Malformed binding order, B.IOR or B.IOS presence, missing or zero dimensions, ordinary numeric mask storage, undefined predicate or data elements, unsupported DataType, shape, type or layout mismatch, unequal masks, or insufficient destination capacity raises Fault_TileLegality or Fault_TileAllocation before architectural effects.
- TSEL performs no conversion and therefore raises no floating invalid condition solely because a selected source encoding represents NaN.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion behavior after an accepted operation.

## Examples

- BSTART.VEC TSEL, E3M2; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT Predicate, SrcTrue, mask=PE_MASK; B.IOT SrcFalse, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
