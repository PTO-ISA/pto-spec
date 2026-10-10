<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TCMP.asl -->
# TCMP

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TCMP.asl`

Compare two Local numeric Tiles and produce one legacy Predicate, CUBE PredicateCell, or GPR carrier.

## Normative identity {#PTO-INST-TILE-TCMP}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcmp-purpose role=purpose -->
## What TCMP does

`TCMP` compares corresponding elements of two Local numeric Tiles and produces one true-or-false result per element. The results form a predicate: a mask that a later operation such as `TSEL` can consume. The comparison mode, selected by `CMode`, is one of `EQ`, `NE`, `LT`, `GT`, `LE`, or `GE`.

Design point: `TCMP` has no standalone opcode. `BSTART.VEC` Mode 0 Function 13 (TEPL selector `0x00D`) selects it. `CMode` codes 0 to 5 select `EQ`, `NE`, `LT`, `GT`, `LE`, and `GE`; codes 6 and 7 are reserved. Omitting `B.DATR` leaves `CMode` at zero, so the default comparison is `EQ`.

<!-- PTO-READER-BLOCK: tile-tcmp-mechanism role=mechanism -->
## Element and Tile mechanism

After complete preflight, `TCMP` snapshots both sources and compares each coordinate of the valid rectangle `ValidRow x ValidCol` under the selected operation `DataType`.

- Signed integer types use signed order, and unsigned integer types use unsigned order.
- Floating-point types use numeric order. Positive and negative zero compare equal.
- If either floating operand is NaN, `NE` is true and every other mode is false. A signaling NaN also records the invalid condition.

Design point: unlike raw-carrier operations such as `TAND` or `TSEL`, `TCMP` must interpret values in order to rank them. Every source element it compares must therefore be a valid encoding of the operation `DataType`, and an invalid encoding is rejected before any effect.

Design point: the selected `BSTART.VEC` `DataType` is the comparison type, and each source's backing type is checked separately. A source may use a different same-width, non-packed backing type; its bits are then compared as the operation type. The source descriptors are not retagged.

<!-- PTO-READER-BLOCK: tile-tcmp-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `source0` is the left numeric source, and `source1` is the right numeric source. `LT` asks whether left is less than right.
- `comparison` is the `CMode` relation.
- `destination0` receives the predicate in the legacy and PredicateCell forms. It is absent in the GPR form.

The predicate is published in exactly one of three mutually exclusive carriers. `RowMajor` sources select the legacy form. `CUBE_M16` or `CUBE_M32` sources select the PredicateCell form when `B.IOT` names a destination, or the GPR form when a destination-only `B.IOR` is bound instead. The `B.DATR` `Layout` field must stay zero. A 64-bit CUBE operand requires the `CUBE_M32` double-CELL mapping; `CUBE_M16` rejects it.

| Form | Source layout | Result carrier |
| --- | --- | --- |
| Legacy | `RowMajor` | New packed Predicate Tile: one bit per element, with element `i` at bit `i mod 8` of byte `floor(i/8)` |
| PredicateCell | `CUBE_M16` or `CUBE_M32` | New `U8` PredicateCell Tile: one canonical byte, `0x00` or `0x01`, per element |
| GPR | `CUBE_M16` or `CUBE_M32` | One 64-bit GPR written through a destination-only `B.IOR` |

Design point: a PredicateCell records its basis type, the operation `DataType` of the comparison that produced it. A `TSEL` that consumes the PredicateCell as its selector requires that basis to equal its own operation `DataType`, so a selector built for one element type is rejected for data of another type. Generic ExecutionMask consumption does not apply this basis check.

In the GPR form, the operation type determines the bit-field geometry of the mask word. For an 8-bit operation type, `Sat` selects the Low or High half of the predicate columns; for wider types `Sat` must be zero.

<!-- PTO-READER-BLOCK: tile-tcmp-effects role=effects -->
## Publication, definedness, and padding

The payload, the predicate padding, the numeric status, the descriptor or GPR result, and definedness publish together. A rejected `TCMP` leaves all architectural state unchanged. Because both sources are snapshotted first, identical sources and a source that aliases the destination read old values.

Predicate positions outside the valid rectangle follow `PadValue`. `Zero` and `Min` write false, `Max` writes true, and `Null`, the default when `B.DATR` is omitted, leaves them undefined or unspecified according to the carrier.

A CUBE form may consume an explicit ExecutionMask. Active coordinates compare normally. Inactive coordinates keep their old predicate bit or cell under MERGE, or receive zero under ZERO, and contribute no numeric status. `TCMP` has no global-memory effect.

<!-- PTO-READER-BLOCK: tile-tcmp-constraints role=constraints -->
## Type, layout, and fault boundary

The operation type set is `FP64`, `FP32`, `TF32`, `HF32`, `FP16`, `BF16`, `E4M3`, `E5M2`, `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`. Legacy RowMajor accepts the full set. PredicateCell and GPR CUBE forms also admit `FP64`, `S64`, and `U64` when the numeric sources use `CUBE_M32` double-CELL descriptors; `CUBE_M16` rejects those 64-bit basis types. The GPR form additionally requires the valid shape to fit its type-derived mask geometry.

`PE_MASK=0000` is a strict no-op before any schema, source, allocation, GPR, or status check. Otherwise, a malformed or mixed carrier schema, a missing dimension, a reserved `CMode`, an unsupported `DataType`, a shape, layout, or width mismatch, undefined or invalid source data, insufficient destination capacity, or allocation failure rejects before source reads or effects. Nonzero `Canonicalize`, secondary `DataType`, `RMode`, or `Layout` is illegal.

<!-- PTO-READER-BLOCK: tile-tcmp-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `DataType=S32` and `CMode=LT`, a left source row `[1, 3, -5]` and a right source row `[2, 3, 4]` produce predicate values `[1, 0, 1]`. Under `DataType=U32`, the same bits compare `-5` as `0xFFFFFFFB`, so the third result becomes 0.

In macro form, `TCMP <Row=8, Col=64, FP32, LT>, T#1, T#2, ->U<512B>` compares two `RowMajor` `FP32` Tiles into a new packed Predicate Tile `U#1`. Its 512 predicate bits occupy 64 bytes.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TCMP <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCMP | TEPL | 0x00D | 13 | 0 | ExecuteTileCompare |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | legacy packed Predicate or CUBE PredicateCell destination; absent for GPR producer |
| source0 | ordered left Local numeric source |
| source1 | ordered right Local numeric source |
| comparison | EQ, NE, LT, GT, LE, or GE selected by CMode |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TCMP.asl -->
```asl
readonly func InstructionContractOperation_TCMP() => TileOperation
begin
    return TileOperation_TCMP;
end;

pure func InstructionContractComparisonCodeLegal_TCMP(
    comparison_code: bits(3)) => boolean
begin
    return UInt(comparison_code) <= 5;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TCMP, DataType
B.DATR CMode, PadValue, SatMode (U8 GPR form only)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->PredicateCell<TSize> OR no destination
B.IOR predicate-GPR destination (GPR form only)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TCMP.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCMP(
    data_type: TileDataType) => boolean
begin
    return TileCompareDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCMP(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    comparison: TileComparison) => boolean
begin
    return TileOperandsLegal_ExecuteTileCompare(
        destination,
        source_left,
        source_right,
        comparison);
end;

readonly func InstructionContractHandler_TCMP() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileCompare;
end;

func InstructionContractExecute_TCMP(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    comparison: TileComparison)
begin
    assert InstructionContractOperandsLegal_TCMP(
        destination,
        source_left,
        source_right,
        comparison);
    ExecuteTileCompare(
        destination,
        source_left,
        source_right,
        comparison);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- CMode codes 0, 1, 2, 3, 4, and 5 select EQ, NE, LT, GT, LE, and GE. Codes 6 and 7 are reserved. Omitted B.DATR retains CMode zero and therefore selects EQ.
- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every present dimension must be nonzero.
- Omitted B.DATR selects predicate PadValue=Null. Explicit PadValue 00 and 10 write zero padding bits, 01 writes one padding bits, and 11 leaves padding bits undefined.

## Legality

- TCMP selects VEC Mode 0 Function 13. PE_MASK=0000 is a strict no-op before schema, descriptor, source, allocation, GPR, status, or payload checks.
- Legacy RowMajor form uses one terminating B.IOT with two numeric sources and one new packed Predicate destination; B.IOR is absent, the existing sixteen-type operation domain remains unchanged, and each source backing DataType is checked independently; exact backing/operation type identity is legal, while cross-type source/backing pairs require equal width and non-four-bit carriers.
- CUBE_M16/M32 PredicateCell form uses one terminating B.IOT with two numeric sources and one new U8 PredicateCell destination tagged with the operation DataType; B.IOR is absent, each source backing DataType is checked independently; exact backing/operation type identity is legal, while cross-type source/backing pairs require equal width and non-four-bit carriers, and the operation type is exactly one of FP64, S64, U64 (these three only for CUBE_M32), FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S32, S16, S8, U32, U16, or U8.
- CUBE_M16/M32 GPR form uses one terminating source-only B.IOT plus one destination-only B.IOR. The operation type is a 32-bit or 16-bit type from the closed CUBE domain, plus U8, or FP64/S64/U64 for CUBE_M32; each source backing DataType is checked independently; exact backing/operation type identity is legal, while cross-type source/backing pairs require equal width and non-four-bit carriers; one 64-bit GPR is written atomically, and U8 Sat selects Low or High predicate columns derived from the operation type.
- Legacy, PredicateCell, and GPR carriers are complete and mutually exclusive. CMode and PadValue apply to every form; Sat is nonzero only for U8 GPR selection; Canonicalize, secondary DataType, RMode, and Layout remain zero.
- Predicate padding is Zero/Min=0, Max=1, and Null unspecified or undefined according to the selected GPR/PredicateCell carrier.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- Compare corresponding valid source elements under the selected operation type's signed, unsigned, or floating relation.
- Publish exactly one selected predicate carrier: legacy packed bits, canonical PredicateCell bytes 0x00/0x01 with basis tag, or one 64-bit GPR predicate word.
- Payload, predicate padding, numeric status, descriptor/GPR result, and definedness publish atomically; rejection leaves all architectural state unchanged.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, field, type, geometry, layout, definedness, encoding, mask, and packed-capacity preflight precedes source snapshots and destination allocation.
- Both source payloads are snapshotted before comparison, so identical sources and logical source/destination aliases observe read-old values.

## Exceptions

- Malformed or mixed carrier schemas, missing dimensions, reserved CMode, unsupported DataType, mismatched CUBE physical shape/layout or incompatible source width, undefined or invalid source data, insufficient destination capacity, or allocation failure rejects before source reads or effects.
- A signaling floating NaN records invalid status only with the atomically published GPR or PredicateCell result.

## Examples

- BSTART.VEC TCMP, U64; B.DATR EQ, Null (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->Predicate<TSize>; BSTOP
