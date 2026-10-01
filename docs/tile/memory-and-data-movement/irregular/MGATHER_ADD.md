<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MGATHER_ADD.asl -->
# MGATHER_ADD

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MGATHER_ADD.asl`

GM indexed mgather.add operation.

## Normative identity {#PTO-INST-TILE-MGATHER-ADD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mgather-add-purpose role=purpose -->
## What MGATHER_ADD does

`MGATHER_ADD` performs one atomic read-modify-write per lane on global memory (GM) and returns every old value in a Local destination Tile. A lane is one active valid coordinate of the index Tile; its address is a base address plus that lane's index value in bytes.

It is TLSU Function 12, written `BSTART.MGATHER.ADD DataType`. `GMAtomicOperationFromFunction` maps Function 12 to the atom operation `GMAtomic_ADD`, and the block dispatcher `ExecuteBundleGMAtomRedOperation` calls `GM_ATOM_VALUE`, which runs the shared atom body `GMRunAtomic` with the destination Tile's data type. The operation has no standalone opcode.

Design point: atom forms bind a destination-bearing `B.IOT`, while the reduction forms bind only source tiles (NDF `PTO-ATOM-RED-BODY-SCHEMA-001`). The matching reduction form `MSCATTER_ADD` is Function 21, so it applies the ADD update to the same addressed GM locations without publishing a result. A program that needs the value each lane observed must use `MGATHER_ADD`.

<!-- PTO-READER-BLOCK: tile-mgather-add-mechanism role=mechanism -->
## Addressing and update mechanism

Each lane address is `base + displacement`. `TileIndexByteDisplacement` makes the displacement the full index value in bytes: `S32` sign-extends, `U32` zero-extends, and `S64` and `U64` are used as they are. It is not multiplied by the element size, so software scales indices itself.

Preflight comes first. For every active lane the body probes the address for read and then for write, at natural alignment for the element width: a misaligned address raises `Fault_DataAlignment`, an address whose translated form is not permitted raises `Fault_DataPage`, and probes that translate read and write differently raise `Fault_DataPage` again. It snapshots every lane's operand value in the same pass.

The commit phase then visits lanes in an order chosen by `ARBITRARY` choices. Each lane loads the old value, computes the new value, stores it at element width, writes the old value into its destination element, and records one atomic event.

For an integer type, `GMAtomicResult` adds the element-width raw values of the old value and the lane value; the element-width store truncates the sum, so it wraps. For `FP16`, `BF16`, `FP32`, and `FP64` the sum comes from `GMFloatingAddPTX`, an implementation-defined hook whose comment names a PTX-derived profile (round to nearest even, no flush-to-zero for `FP16` and `BF16`, flush-to-zero for `FP32`); its model body only adds the raw words, so the ASL gives no floating result of its own.

Design point: every probe finishes before the first atomic event (NDF `PTO-ATOM-RED-ORDERING-001`). A faulting request therefore changes no GM location and records no event, so a retry after the fault is fixed cannot apply any update twice.

Design point: lanes with the same address serialize in an implementation-defined order, and all of them take effect. Each lane is atomic by itself; the request as a whole is not one atomic transaction, and its events carry `CurrentBundleMemoryOrder()` from the bundle acquire and release attributes.

<!-- PTO-READER-BLOCK: tile-mgather-add-inputs role=inputs-outputs -->
## Operand roles and bindings

- `destination0` is the Local destination Tile. It takes the bundle `DataType` and the `B.DIM` shape and receives the old values.
- `address` is the base address, read from the GPR named by `B.IOR.RegSrc0` in the current memory agent's register file. `B.IOR` is required, and `RegSrc1`, `RegSrc2`, and `RegDst` must be zero.
- `source0` is the index Tile: `S32`, `U32`, `S64`, or `U64`, with the bundle layout and the `B.DIM` valid rows and valid columns.
- `source1` is the value Tile. It must have the bundle `DataType`, the bundle layout, and the same valid shape as the index Tile.

Without a predicate-Tile ExecutionMask, one terminating `B.IOT` carries the index Tile, the value Tile, and the destination. With one, the first `B.IOT` carries the two Tiles with no destination and no `last`, and a second `B.IOT` carries the predicate Tile as its only source, together with the destination and `last`.

Design point: the base register is read from each PE's own GPR file, so PEs selected by one `PE_MASK` can address different GM regions with the same index Tile.

<!-- PTO-READER-BLOCK: tile-mgather-add-effects role=effects -->
## GM, destination, and fault effects

Before the commit phase, every physical destination element is initialized. Inactive valid coordinates under an ExecutionMask receive the mask's zero or merge value; every other element receives the bundle `PadValue`, where an omitted `B.DATR` gives `Null` and `Null` writes zero bits. Active lanes then overwrite their element with the old value, and the whole physical region is marked defined.

On success each active lane has written GM once and recorded exactly one atomic event. These GM writes stay visible; there is no rollback of memory.

If any probe faults, the body returns before its first event, and the dispatcher calls `RollBackBundleTileDestinations`, which releases the destination when this bundle allocated it. No old value is published.

<!-- PTO-READER-BLOCK: tile-mgather-add-constraints role=constraints -->
## Types, shape, and fault boundary

The bundle `DataType` must be one of `FP16`, `BF16`, `FP32`, `FP64`, `S32`, `U32`, `U64`: `GMAtomicOperationDataTypeLegal` admits exactly those for `GMAtomic_ADD`, so `S64` is rejected even though `MGATHER_MAX` and `MGATHER_MIN` accept it. NDF `PTO-ATOM-RED-TYPE-LEGALITY-001` states the matrix is explicit and excludes Shared operands, vectors, packed FP16x2 and BF16x2, and U128.

Every `B.DIM` value must be in `1..65535`, and valid rows times valid columns may not exceed `PTO_MODEL_TILE_ELEMENTS`. For RowMajor, valid columns may not exceed physical columns, which must be a nonzero power of two. The layout is RowMajor, CUBE_M16, or CUBE_M32.

An unknown TLSU code raises `Fault_IllegalInstruction`. Once the bundle's operand bindings are complete, a `B.IOT` count the schema does not accept raises `Fault_BundleControl`. A missing `B.IOR`, a Shared binding, a bad dimension, type, shape, or layout, or an undefined element at an active index or value coordinate raises `Fault_TileLegality`. All of these happen before any probe (NDF `PTO-ATOM-RED-FAULTS-001`), and a destination allocation failure raises `Fault_TileAllocation`.

`PE_MASK=0000` exits the GM atom/red dispatcher before every schema, GPR, descriptor, type, and memory check, so the bundle performs no probe and no atomic event.

<!-- PTO-READER-BLOCK: tile-mgather-add-example role=example -->
## Non-normative worked example

Treat the generated `MGATHER_ADD` example as a spelling and navigation aid. Substitute operands only within the legality and state contracts owned below.

Take `U32`, base `0x1000` in `a0`, a 1 by 3 `U64` index Tile holding `0, 4, 0`, and a value Tile holding `5, 7, 1`. GM holds 10 at `0x1000` and 20 at `0x1004`.

- Lanes 0 and 2 both target `0x1000`. Either order ends with 10 + 5 + 1 = 16 there.
- Lane 1 adds 7 at `0x1004`, which ends at 27.
- The old values returned are `10, 20, 15` if lane 0 runs first, or `11, 20, 10` if lane 2 runs first.

In macro form this is `MGATHER_ADD <Col=4, ValidCol=3, U32>, [base=a0], T#1, T#2, ->T<128B>`, with `T#1` as the index Tile and `T#2` as the value Tile. The 128-byte destination holds 32 physical elements: 3 receive old values and the other 29 receive the pad value, which is zero bits for the default `Null`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MGATHER_ADD <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MGATHER_ADD | TLSU |  | 12 |  | GM_ATOM_VALUE |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| address | base-address |
| source0 | indices |
| source1 | value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MGATHER_ADD.asl -->
```asl
readonly func InstructionContractMatches_MGATHER_ADD(operation: TileOperation) => boolean
begin
    return operation == TileOperation_MGATHER_ADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.ADD DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MGATHER_ADD.asl -->
```asl
readonly func InstructionContractHandler_MGATHER_ADD() => TileSemanticHandler
begin
    return TileHandler_GM_ATOM_VALUE;
end;
readonly func InstructionContractOperation_MGATHER_ADD() => TileOperation
begin
    return TileOperation_MGATHER_ADD;
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

- BSTART.MGATHER.ADD DataType
