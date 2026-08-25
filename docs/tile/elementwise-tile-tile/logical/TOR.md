<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TOR.asl -->
# TOR

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TOR.asl`

Compute the bitwise OR of corresponding integer elements.

## Normative identity {#PTO-INST-TILE-TOR}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tor-purpose role=purpose -->
## Purpose

`TOR` computes bitwise OR of corresponding integer elements.

<!-- PTO-READER-BLOCK: tile-tor-mechanism role=mechanism -->
## Execution mechanism

The ASL DOC contract selects `TileHandler_ExecuteTileBinary` through the instruction's selector-encoded block carrier.

Binding schema, dimensions, DataType, row-major layout, source definedness and encoding, PE_MASK, destination capacity, and applicable attributes are checked before source snapshots.

<!-- PTO-READER-BLOCK: tile-tor-inputs-outputs role=inputs-outputs -->
## Operands and descriptors

`destination0` is the new Local destination; `source0` is the ordered left Local source; `source1` is the ordered right Local source.

Sources remain persistent unless the current contract explicitly names a consumed or replaced state; destination descriptors are published only after complete preflight.

<!-- PTO-READER-BLOCK: tile-tor-effects role=effects -->
## Publication and ordering

Every valid coordinate applies the operation at the selected element type; all sources and private-GPR scalar operands are snapshotted before destination publication.

The valid payload, selected physical padding definedness, descriptor, and applicable sticky numeric flags publish atomically; rejection has no architectural effect.

<!-- PTO-READER-BLOCK: tile-tor-constraints role=constraints -->
## Legality, padding, and faults

Malformed bindings, unsupported types or layouts, invalid shapes, undefined consumed elements, illegal attributes, or insufficient destination capacity are rejected before source snapshots or publication.

`PE_MASK=0000` is a strict no-op before reads, allocation, faults, numeric status, padding, or descriptor effects. Allocation failure raises the owner-defined Tile allocation fault; other rejected schema or value conditions raise the owner-defined legality, bundle-control, or memory fault without partial effects.

<!-- PTO-READER-BLOCK: tile-tor-example role=example -->
## Non-normative contract sketch

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

Read `BSTART.VEC TOR, U8; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP` as a non-normative binding walkthrough, then use the generated contract below for exact dimensions, attributes, and fault behavior.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TOR <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TOR | TEPL | 0x007 | 7 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | ordered left Local source |
| source1 | ordered right Local source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TOR.asl -->
```asl
readonly func InstructionContractOperation_TOR() => TileOperation
begin
    return TileOperation_TOR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TOR, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TOR.asl -->
```asl
pure func InstructionContractDataTypeLegal_TOR(
    data_type: TileDataType) => boolean
begin
    return TileVecScalarIntegerDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TOR(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_OR,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TOR() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TOR(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_OR,
        destination,
        source_left,
        source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Physical Rows derive from TSize, Col, and DataType; Rows and Col are powers of two and contain ValidRow x ValidCol.

## Legality

- TOR is selected by TEPL carrier Mode 0 Function 7 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local sources and one newly allocated Local destination; B.IOR and B.IOS are not accepted.
- DataType is exactly S64, S32, S16, S8, U64, U32, U16, or U8; packed and floating formats reject before effects.
- Sources are fully defined and all three Tiles match physical shape, valid shape, row-major layout, DataType, and PE_MASK.
- PadValueOrByteId is the only applicable B.DATR field; PE_MASK=0000 is a strict no-op before reads, allocation, or faults.

## State effects

- Apply element-width bitwise OR to corresponding valid source elements; signedness does not change the bit operation and carrier bits above the selected width are zero.
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

- BSTART.VEC TOR, U8; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
