<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER_OR.asl -->
# MSCATTER_OR

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER_OR.asl`

GM indexed mscatter.or operation.

## Normative identity {#PTO-INST-TILE-MSCATTER-OR}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mscatter-or-purpose role=purpose -->
## What MSCATTER_OR does

`MSCATTER_OR` performs one atomic read-modify-write per lane in global memory (GM) and returns no value. A lane is one active valid coordinate of the index Tile; its address is the base address plus that lane's index value.

It is TLSU Function 25, written `BSTART.MSCATTER.OR DataType`. The block dispatcher `ExecuteBundleGMAtomRedOperation` maps Function 25 to the reduction operation OR and calls `GM_RED_VALUE`. The page has no standalone opcode.

Design point: a reduction has no destination Tile, so it allocates nothing and a fault has nothing to release. The atom form `MGATHER_OR` applies the same OR update and also returns the old values.

<!-- PTO-READER-BLOCK: tile-mscatter-or-mechanism role=mechanism -->
## Addressing and update mechanism

Each lane address is `base + displacement`. The displacement is the full index value used as a byte count: `S32` sign-extends, `U32` zero-extends, and `S64` and `U64` are used as is. It is not multiplied by the element size, so software scales indices itself.

Preflight comes first. For every active lane the body probes the address for read and then for write, at natural alignment for the element width, raises `Fault_DataPage` if the two translations differ, and snapshots that lane's operand value. The commit phase then visits lanes in an order chosen by `ARBITRARY` choices; each lane loads the old value, computes the new value, stores it at element width, and records one atomic event with `write_performed` TRUE.

The new value is `old OR value`, computed bitwise, so every bit of the old word that the lane value does not set keeps its old value.

Design point: every probe finishes before the first atomic event (NDF `PTO-ATOM-RED-ORDERING-001`). A faulting request therefore changes no GM location and records no event, so a retry after the fault is fixed cannot apply any update twice.

Design point: lanes with the same address serialize in an implementation-defined order, and all of them take effect. Each lane is atomic by itself; the request as a whole is not one atomic transaction, and its events carry the order selected by the bundle acquire and release attributes.

<!-- PTO-READER-BLOCK: tile-mscatter-or-inputs role=inputs-outputs -->
## Operand roles and bindings

- `address` is the base address, read from the GPR named by `B.IOR.RegSrc0` in the current memory agent's register file. `B.IOR` is required, and `RegSrc1`, `RegSrc2`, and `RegDst` must be zero.
- `source0` is the index Tile: `S32`, `U32`, `S64`, or `U64`, with the bundle layout and the `B.DIM` valid rows and valid columns.
- `source1` is the value Tile. It must have the bundle `DataType`, the bundle layout, and the same valid shape as the index Tile.

Without a predicate-Tile ExecutionMask, one terminating `B.IOT` carries both sources, with no destination. With one, the first `B.IOT` carries both sources without `last`, and a second terminating `B.IOT` carries the mask's predicate Tile as its single source, with no destination.

Design point: the base register is read from each PE's own GPR file, so the PEs selected by one `PE_MASK` can address different GM regions with the same index Tile.

<!-- PTO-READER-BLOCK: tile-mscatter-or-effects role=effects -->
## GM, destination, and fault effects

No Tile is written. The index and value Tiles are only read, and inactive lanes under an ExecutionMask form no address and make no access.

On success each active lane has written GM once and recorded exactly one atomic event. These GM writes stay visible; there is no rollback of memory. If any probe faults, the body returns before its first event, so GM, the event stream, and every Tile are unchanged.

<!-- PTO-READER-BLOCK: tile-mscatter-or-constraints role=constraints -->
## Types, shape, and fault boundary

The bundle `DataType` must be one of `U32`, `U64`, exactly the set `GMReductionOperationDataTypeLegal` admits for OR. NDF `PTO-ATOM-RED-TYPE-LEGALITY-001` also excludes Shared operands, vectors, packed f16x2 and bf16x2, and U128.

Every selected `B.DIM` value must be in `1..65535`, and `BundleMGATHERDimensionsLegal`, which `ExecuteBundleGMAtomRedOperation` runs before the body, additionally requires valid rows times valid columns to stay within `PTO_MODEL_TILE_ELEMENTS` and, for RowMajor, valid columns not to exceed the physical columns, which must be a nonzero power of two. The index Tile and the value Tile must both use the bundle layout, which is RowMajor, CUBE_M16, or CUBE_M32.

An unknown TLSU code raises `Fault_IllegalInstruction`. A wrong number of `B.IOT` commands raises `Fault_BundleControl`. A missing `B.IOR`, a surplus GPR binding, a Shared binding, or a bad dimension, type, shape, layout, or undefined active index or value element raises `Fault_TileLegality`. All of these happen before any probe; a misaligned or disallowed address raises `Fault_DataAlignment` or `Fault_DataPage` during probing. `PE_MASK=0000` exits at the start of the GM atom/red dispatcher, before its schema, GPR, descriptor, type, and memory checks.

<!-- PTO-READER-BLOCK: tile-mscatter-or-example role=example -->
## Non-normative worked example

Treat the generated `MSCATTER_OR` example as a spelling and navigation aid. Substitute operands only within the legality and state contracts owned below.

Take `U32`, base `0x2000` in `a0`, a 1 by 2 `S32` index Tile holding `0, 4`, and a value Tile holding `0x00F0, 0x00F0`. GM holds `0x000F` at `0x2000` and `0x0000` at `0x2004`. Lane 0 computes `0x000F` OR `0x00F0` = `0x00FF` at `0x2000`; lane 1 computes `0x0000` OR `0x00F0` = `0x00F0` at `0x2004`. Two atomic events are recorded, each with `write_performed` TRUE, and no Tile is written.

In macro form this is `MSCATTER_OR <Col=2, ValidRow=1, ValidCol=Col, U32>, [BaseGPR], T#1, T#2`, with `T#1` as the index Tile and `T#2` as the value Tile. It has no destination operand.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER_OR <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER_OR | TLSU |  | 25 |  | GM_RED_VALUE |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| address | base-address |
| source0 | indices |
| source1 | value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER_OR.asl -->
```asl
readonly func InstructionContractMatches_MSCATTER_OR(operation: TileOperation) => boolean
begin
    return operation == TileOperation_MSCATTER_OR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.OR DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER_OR.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER_OR() => TileSemanticHandler
begin
    return TileHandler_GM_RED_VALUE;
end;
readonly func InstructionContractOperation_MSCATTER_OR() => TileOperation
begin
    return TileOperation_MSCATTER_OR;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.
- GM indexed operation uses logical-element-index addresses and complete preflight.

## Legality

- GM-only; Shared, vector, packed, and U128 forms are rejected.
- ValidRow and ValidCol are nonzero and match every Tile source and any published destination; selected-layout legality requires ValidCol <= Col, with CUBE descriptor rules applied separately.

## State effects

- All valid requests take effect; atom forms publish observed old values.

## Memory effects and ordering

### Memory effects

- One intrinsic atomic RMW per valid request.

### Ordering

- Duplicate-address events serialize in implementation-defined order.

## Exceptions

- Legality and access faults occur before effects.

## Examples

- BSTART.MSCATTER.OR DataType
