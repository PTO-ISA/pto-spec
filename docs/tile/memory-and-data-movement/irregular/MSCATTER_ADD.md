<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER_ADD.asl -->
# MSCATTER_ADD

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER_ADD.asl`

GM indexed mscatter.add operation.

## Normative identity {#PTO-INST-TILE-MSCATTER-ADD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mscatter-add-purpose role=purpose -->
## What MSCATTER_ADD does

`MSCATTER_ADD` performs one atomic read-modify-write per lane on global memory (GM) and returns nothing. A lane is one active valid coordinate of the index Tile; its address is a base address plus that lane's index value.

It is TLSU Function 21, written `BSTART.MSCATTER.ADD DataType`. The block dispatcher `ExecuteBundleGMAtomRedOperation` maps Function 21 to the reduction operation ADD and calls `GM_RED_VALUE`. The page has no standalone opcode.

Design point: a reduction has no destination Tile, so it allocates nothing and a fault has nothing to release. The atom form `MGATHER_ADD` performs the same update and also returns the old values.

<!-- PTO-READER-BLOCK: tile-mscatter-add-mechanism role=mechanism -->
## Addressing and update mechanism

Each lane address is `base + displacement`. The displacement is the full index value in bytes: `S32` sign-extends, `U32` zero-extends, and `S64` and `U64` are used as is. It is not multiplied by the element size, so software scales indices itself.

Preflight comes first. For every active lane the body probes the address for read and then for write, with natural alignment for the element width, and raises `Fault_DataPage` if the two translations differ. It snapshots every lane's operand value in the same pass.

The commit phase then visits lanes in an order chosen by `ARBITRARY` choices. Each lane loads the old value, computes the new value, stores it at element width, and records one atomic event.

For an integer type, `GMReductionResult` adds the old value and the lane value as raw words; the element-width store truncates the sum, so it wraps. For `FP16`, `BF16`, `FP32`, and `FP64` the sum comes from `GMFloatingAddPTX`, an implementation-defined hook whose comment names a PTX-derived profile (round to nearest even, no flush-to-zero for `FP16` and `BF16`, flush-to-zero for `FP32`); its model body only adds the two words as integers, so the ASL derives no floating result of its own.

Design point: every probe finishes before the first atomic event (NDF `PTO-ATOM-RED-ORDERING-001`). A faulting request therefore changes no GM location and records no event, so a retry after the fault is fixed cannot apply any update twice.

Design point: lanes with the same address serialize in an implementation-defined order, and all of them take effect. Each lane is atomic by itself; the request as a whole is not one atomic transaction, and its events carry `CurrentBundleMemoryOrder()` from the bundle acquire and release attributes.

<!-- PTO-READER-BLOCK: tile-mscatter-add-inputs role=inputs-outputs -->
## Operand roles and bindings

- `address` is the base address, read from the GPR named by `B.IOR.RegSrc0` in the current memory agent's register file. `B.IOR` is required, and `RegSrc1`, `RegSrc2`, and `RegDst` must encode zero as the block composition requires. The dispatcher reaches `BundleOperationScalarBindingSchemaLegal` through `BundleOperationBindingsComplete`, so a nonzero `RegSrc1`, `RegSrc2`, or `RegDst` makes that check return false and the block raises `Fault_TileLegality` before any probe.
- `source0` is the index Tile: `S32`, `U32`, `S64`, or `U64`, with the bundle layout and the `B.DIM` valid rows and valid columns.
- `source1` is the value Tile. It must have the bundle `DataType`, the bundle layout, and the same valid shape as the index Tile.

Without a predicate-Tile ExecutionMask, one terminating `B.IOT` carries the index Tile and the second source, with no destination. With one, the first `B.IOT` carries the two sources without `last`, and a second `B.IOT` carries one source and `last`, with no destination.

Design point: the base register is read from each PE's own GPR file, so PEs selected by one `PE_MASK` can address different GM regions with the same index Tile.

<!-- PTO-READER-BLOCK: tile-mscatter-add-effects role=effects -->
## GM, destination, and fault effects

No Tile is written. The index and value Tiles are only read, and inactive lanes under an ExecutionMask form no address and make no access.

On success each active lane has written GM once, and each of those writes counts as one atomic event under NDF `PTO-ATOM-RED-ORDERING-001`. Those GM writes stay visible; the body performs no rollback of memory.

If any probe faults, the body returns before its first event. GM, the event stream, and every Tile are unchanged.

<!-- PTO-READER-BLOCK: tile-mscatter-add-constraints role=constraints -->
## Types, shape, and fault boundary

The bundle `DataType` must be one of `FP16`, `BF16`, `FP32`, `FP64`, `S32`, `U32`, `U64`. No packed four-bit type is in the operation/type matrix, and NDF `PTO-ATOM-RED-TYPE-LEGALITY-001` also excludes Shared operands, vectors, packed FP16x2 and BF16x2, and U128.

Every `B.DIM` value must be in `1..65535`, and valid rows times valid columns may not exceed `PTO_MODEL_TILE_ELEMENTS`. For RowMajor, valid columns may not exceed physical columns, which must be a nonzero power of two. The layout is RowMajor, CUBE_M16, or CUBE_M32.

An unknown TLSU code raises `Fault_IllegalInstruction`. A wrong number of `B.IOT` commands raises `Fault_BundleControl`. A missing `B.IOR`, a Shared binding, a bad dimension, type, shape, layout, or undefined active index or value element raises `Fault_TileLegality`. All of these happen before any probe.

`PE_MASK=0000` exits at the start of the GM atom/red dispatcher, before its schema, GPR, descriptor, type, and memory checks.

<!-- PTO-READER-BLOCK: tile-mscatter-add-example role=example -->
## Non-normative worked example

Treat the generated `MSCATTER_ADD` example as a spelling and navigation aid. Substitute operands only within the legality and state contracts owned below.

Take `U32`, base `0x1000` in `a0`, a 1 by 3 `U64` index Tile holding `0, 4, 0`, and a value Tile holding `5, 7, 1`. GM holds 10 at `0x1000` and 20 at `0x1004`.

- Lanes 0 and 2 both target `0x1000`. Either order ends with 10 + 5 + 1 = 16 there.
- Lane 1 adds 7 at `0x1004`, which ends at 27.
- Three atomic events are recorded, and no Tile is written.

In macro form this is `MSCATTER_ADD <Col=4, ValidCol=3, U32>, [base=a0], T#1, T#2`, with `T#1` as the index Tile and `T#2` as the value Tile. It has no destination operand.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER_ADD <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER_ADD | TLSU |  | 21 |  | GM_RED_VALUE |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER_ADD.asl -->
```asl
readonly func InstructionContractMatches_MSCATTER_ADD(operation: TileOperation) => boolean
begin
    return operation == TileOperation_MSCATTER_ADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.ADD DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER_ADD.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER_ADD() => TileSemanticHandler
begin
    return TileHandler_GM_RED_VALUE;
end;
readonly func InstructionContractOperation_MSCATTER_ADD() => TileOperation
begin
    return TileOperation_MSCATTER_ADD;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.
- GM indexed operation uses byte-displacement addresses and complete preflight.

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

- BSTART.MSCATTER.ADD DataType
