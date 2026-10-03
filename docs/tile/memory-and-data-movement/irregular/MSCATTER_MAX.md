<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER_MAX.asl -->
# MSCATTER_MAX

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER_MAX.asl`

GM indexed mscatter.max operation.

## Normative identity {#PTO-INST-TILE-MSCATTER-MAX}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mscatter-max-purpose role=purpose -->
## What `MSCATTER_MAX` does

`MSCATTER_MAX` is one atomic read-modify-write per lane on global memory (GM) and returns nothing. A lane is one active valid coordinate of the index Tile. Its address is the base address plus that lane's index value used as a byte displacement.

It is TLSU Function 19, written `BSTART.MSCATTER.MAX DataType`. The block dispatcher `ExecuteBundleGMAtomRedOperation` maps Function 19 to the reduction operation MAX and calls `GM_RED_VALUE`. The page has no standalone opcode.

Design point: a reduction form binds no destination Tile, so nothing is allocated and no Tile is published. The atom form `MGATHER_MAX` computes the same new value and also returns the old values in a destination Tile.

<!-- PTO-READER-BLOCK: tile-mscatter-max-mechanism role=mechanism -->
## Addressing, comparison, and the update mechanism

Each lane address is `base + displacement`, where the displacement is a byte count, not an element count. The index Tile element supplies it: `S32` sign-extends, `U32` zero-extends, and `S64` and `U64` are used as they are (`TileIndexByteDisplacement`). Software scales indices to bytes itself. The atomic element at that address has the bundle `DataType` width.

Preflight comes first. For each active lane, in index Tile order, the body probes the address for reading and then for writing, with the element width as the alignment, and raises the probe fault if either probe fails. If the read and write probes translate to different addresses, it raises `Fault_DataPage`. In the same pass it snapshots each lane's address and the value Tile element that belongs to that coordinate.

The commit phase then visits the lanes in an order chosen by `ARBITRARY` choices. Each lane loads the old element, computes the new value, stores it at element width, and records one atomic event with `write_performed` TRUE and `CurrentBundleMemoryOrder()` as its order.

The new value is the larger of the old value and the lane's value. `GMReductionResult` compares with `SInt` for the signed types `S32` and `S64` and with `UInt` for the unsigned types `U32` and `U64`, deciding between them with `TileDataTypeIsSigned`.

Design point: MAX selects a comparison domain from the element type instead of comparing the raw words. The same bit pattern `0xFFFFFFFF` is -1 in `S32` and 4294967295 in `U32`, so a `U32` GM location keeps it and an `S32` location overwrites it. A caller that wants a negative operand to win must select a signed `DataType`.

Design point: every probe finishes before the first atomic event (NDF `PTO-ATOM-RED-ORDERING-001`). A request that faults on a probe therefore stores nothing and records no event, so repeating it cannot apply an update twice.

Design point: lanes that resolve to the same address serialize in an implementation-defined order, so the last of them to run sets the final value, and every lane is still effective. One lane is one atomic event; the request as a whole is not one atomic transaction.

<!-- PTO-READER-BLOCK: tile-mscatter-max-inputs role=inputs-outputs -->
## Operand roles, bindings, and the mask

- `address` is the base address. It comes from the GPR named by `B.IOR.RegSrc0`, read in the current memory agent's register file, and it must be complete: `RegSrc1`, `RegSrc2` and `RegDst` are zero.
- `source0` is the index Tile. Its type must be `S32`, `U32`, `S64` or `U64`, and it must have the bundle layout.
- `source1` is the value Tile. Its type must be the bundle `DataType`, it must have the bundle layout, and its valid rows and valid columns must equal the index Tile's.

Without an ExecutionMask carried by a predicate Tile, one terminating `B.IOT` carries both sources, and that binding has no destination. With one, the first `B.IOT` carries the two sources and is not last, and a second `B.IOT` carries the predicate Tile as its single source and is last.

Design point: this group needs two tile sources but the predicate Tile still needs a carrier, and a reduction has no destination slot to put it in. So the mask takes the only free position, as a second source-only binding.

Design point: the base register is read in each PE's own register file, so PEs selected by one `PE_MASK` can address different GM regions with the same index Tile. `PE_MASK` selects the participating PEs; the ExecutionMask predicate Tile selects the active coordinates, and an inactive coordinate forms no address at all.

<!-- PTO-READER-BLOCK: tile-mscatter-max-effects role=effects -->
## Memory, Tile, and fault effects

No Tile is written or published. The index Tile and the value Tile are read only.

On success, each active lane has stored once in GM and recorded exactly one atomic event. Those stores stay visible: there is no rollback of GM.

When a probe faults, the body returns before its first event, so GM, the event stream, and every Tile are unchanged.

<!-- PTO-READER-BLOCK: tile-mscatter-max-constraints role=constraints -->
## Types, shape, and fault boundary

The bundle `DataType` must be one of `S32`, `S64`, `U32`, `U64`, and the value Tile must carry that same type. `GMReductionOperationDataTypeLegal` accepts that set for MAX, and NDF `PTO-ATOM-RED-TYPE-LEGALITY-001` also excludes Shared operands, vectors, packed FP16x2 and BF16x2, and U128.

Every `B.DIM` value must be in `1..65535`, and valid rows times valid columns may not exceed `PTO_MODEL_TILE_ELEMENTS`. For RowMajor, valid columns may not exceed the physical columns, which must be a nonzero power of two. The accepted layouts are RowMajor, CUBE_M16, and CUBE_M32.

An unknown TLSU code raises `Fault_IllegalInstruction`. The dispatcher's binding-count check raises `Fault_BundleControl`. A binding group whose operand count does not match the contract, a missing `B.IOR`, a Shared binding, a bad dimension, a missing or mismatched value Tile, a mismatched layout, or an undefined element at an active coordinate raises `Fault_TileLegality`. Every one of those checks finishes before the first GM probe; alignment and page faults surface only from the probes.

`PE_MASK=0000` returns at the start of the GM atom/red dispatcher and is a strict no-effect case; `B.IOR` and valid dimensions are required otherwise.

<!-- PTO-READER-BLOCK: tile-mscatter-max-example role=example -->
## Non-normative worked example

Treat the generated `MSCATTER_MAX` example as a spelling and navigation aid. Substitute operands only within the legality and state contracts owned below.

Take `S32`, the base address `0x3000` in `a0`, a 1 by 2 `U32` index Tile holding `0, 4`, and a value Tile holding `1, 1`. GM holds `0xFFFFFFFF` (-1) at `0x3000` and 5 at `0x3004`.

- Lane 0 compares -1 with 1 as signed values and stores 1 at `0x3000`. With `U32` the same bits would keep `0xFFFFFFFF`.
- Lane 1 compares 5 with 1 and stores 5 back at `0x3004`.
- Both lanes store, even when the value does not change, and both atomic events record `write_performed` TRUE.

The canonical macro spelling is `MSCATTER_MAX <Col=2, S32>, [base=a0], SrcTile0, SrcTile1`, where `SrcTile0` is the index Tile and `SrcTile1` is the value Tile. The macro has no destination operand.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER_MAX <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER_MAX | TLSU |  | 19 |  | GM_RED_VALUE |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER_MAX.asl -->
```asl
readonly func InstructionContractMatches_MSCATTER_MAX(operation: TileOperation) => boolean
begin
    return operation == TileOperation_MSCATTER_MAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.MAX DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER_MAX.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER_MAX() => TileSemanticHandler
begin
    return TileHandler_GM_RED_VALUE;
end;
readonly func InstructionContractOperation_MSCATTER_MAX() => TileOperation
begin
    return TileOperation_MSCATTER_MAX;
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

- BSTART.MSCATTER.MAX DataType
