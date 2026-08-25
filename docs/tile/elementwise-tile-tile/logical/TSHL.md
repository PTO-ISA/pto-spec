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

`TSHL` left-shifts each integer element by the corresponding masked count and publishes a new Local destination.

<!-- PTO-READER-BLOCK: tile-c-tshl-mechanism role=mechanism -->
## Operation mechanism

The operation evaluates only the valid rectangle using the mnemonic-selected typed element rule.

<!-- PTO-READER-BLOCK: tile-c-tshl-inputs-outputs role=inputs-outputs -->
## Operands, shape, and type

- `destination0` identifies a newly allocated destination.

- `source0` supplies a persistent source Tile.

- `source1` supplies a persistent source Tile.

- The closed applicable DataType set is `S64`, `S32`, `S16`, `S8`, `U64`, `U32`, `U16`, `U8`.

- Data Tiles use row-major layout unless this mnemonic explicitly selects another permitted layout.

- `LB0`, `LB1`, and `LB2` complete the valid and physical shape according to this mnemonic’s contract; every required valid extent is nonzero.

<!-- PTO-READER-BLOCK: tile-c-tshl-effects role=effects -->
## Definedness, padding, and publication

All source descriptors and payloads are validated and snapshotted before destination publication.

The complete destination payload, descriptor, definedness, padding state, and applicable numeric status publish atomically; rejection publishes none.

Null padding leaves physical coordinates outside the valid rectangle undefined; an explicit non-Null PadValue defines those coordinates with the selected typed value.

Source Tiles persist and are not modified by successful execution.

<!-- PTO-READER-BLOCK: tile-c-tshl-constraints role=constraints -->
## Legality, fault, and order boundaries

Complete binding schema, dimensions, DataType, layout, source definedness, numeric encoding, destination capacity, and allocation are preflighted before effects.

A failed legality or allocation check raises the applicable Tile fault without partial destination, status, or memory effects.

`PE_MASK=0000` is a strict no-op before operand reads, allocation, faults, numeric status, or payload effects.

<!-- PTO-READER-BLOCK: tile-c-tshl-example role=example -->
## Non-normative example

This example illustrates the current ASL-bound contract and is not a second instruction definition.

`TSHL <bundle operands>` performs complete preflight and source snapshotting before atomically publishing the mnemonic-defined result and padding state.
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
B.DATR PadValue (optional)
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
- Sources are fully defined and all three Tiles match physical shape, valid shape, row-major layout, DataType, and PE_MASK.
- PadValueOrByteId is the only applicable B.DATR field; PE_MASK=0000 is a strict no-op before reads, allocation, or faults.

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

- Malformed bindings, missing or zero dimensions, undefined or mismatched sources, a non-row-major layout, an unsupported DataType, or invalid destination capacity raises Fault_TileLegality before effects.
- Explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal before source snapshots or destination allocation.

## Examples

- BSTART.VEC TSHL, U8; B.DIM LB0=ValidCol; B.IOT Value, ShiftCount, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
