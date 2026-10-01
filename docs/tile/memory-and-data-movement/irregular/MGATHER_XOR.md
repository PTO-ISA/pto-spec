<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MGATHER_XOR.asl -->
# MGATHER_XOR

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MGATHER_XOR.asl`

GM indexed mgather.xor operation.

## Normative identity {#PTO-INST-TILE-MGATHER-XOR}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mgather-xor-purpose role=purpose -->
## What MGATHER_XOR does

`MGATHER_XOR` performs one atomic read-modify-write per lane on global memory (GM) and returns every observed old value in a Local Tile. A lane is one active valid coordinate of the index Tile; its address is a base address plus that lane's index value.

It is TLSU Function 18, written `BSTART.MGATHER.XOR DataType`. The block dispatcher `ExecuteBundleGMAtomRedOperation` maps Function 18 to the atom operation XOR and calls `GM_ATOM_VALUE`, which runs the shared atom body `GMRunAtomic`. The page has no standalone opcode.

Design point: the reduction form `MSCATTER_XOR` performs the same update but has no destination. Use `MGATHER_XOR` when the program needs the value each lane observed; that old value is the only result the atom form adds.

<!-- PTO-READER-BLOCK: tile-mgather-xor-mechanism role=mechanism -->
## Addressing and update mechanism

Each lane address is `base + displacement`. The displacement is the full index value in bytes: `S32` sign-extends, `U32` zero-extends, and `S64` and `U64` are used as is. It is not multiplied by the element size, so software scales indices itself.

Preflight comes first. For every active lane the body probes the address for read and then for write, with natural alignment for the element width, and raises `Fault_DataPage` if the two translations differ. It snapshots every lane's operand value in the same pass.

The commit phase then visits lanes in an order chosen by `ARBITRARY` choices. Each lane loads the old value, computes the new value, stores it at element width, writes the old value into its destination element, and records one atomic event.

The new value is `old XOR value`, computed bitwise over the whole element width. The operands have no sign interpretation.

Design point: every probe finishes before the first atomic event (NDF `PTO-ATOM-RED-ORDERING-001`). A faulting request therefore changes no GM location and records no event, so a retry after the fault is fixed cannot apply any update twice.

Design point: lanes with the same address serialize in an implementation-defined order, and all of them take effect. Each lane is atomic by itself; the request as a whole is not one atomic transaction, and its events carry `CurrentBundleMemoryOrder()` from the bundle acquire and release attributes.

<!-- PTO-READER-BLOCK: tile-mgather-xor-inputs role=inputs-outputs -->
## Operand roles and bindings

- `destination0` is the Local Tile result allocated by this bundle, with the bundle `DataType` and the `B.DIM` shape. It receives the old values.
- `address` is the base address, read from the GPR named by `B.IOR.RegSrc0` in the current memory agent's register file. `B.IOR` is required, and `RegSrc1`, `RegSrc2`, and `RegDst` must encode zero as the block composition requires. The dispatcher reaches `BundleOperationScalarBindingSchemaLegal` through `BundleOperationBindingsComplete`, so a nonzero `RegSrc1`, `RegSrc2`, or `RegDst` makes that check return false and the block raises `Fault_TileLegality` before any probe.
- `source0` is the index Tile: `S32`, `U32`, `S64`, or `U64`, with the bundle layout and the `B.DIM` valid rows and valid columns.
- `source1` is the value Tile. It must have the bundle `DataType`, the bundle layout, and the same valid shape as the index Tile.

Without a predicate-Tile ExecutionMask, one terminating `B.IOT` carries the index Tile, the second source, and the destination. With one, the first `B.IOT` carries the two sources with no destination and no `last`, and a second `B.IOT` carries one source, the destination, and `last`.

Design point: the base register is read from each PE's own GPR file, so PEs selected by one `PE_MASK` can address different GM regions with the same index Tile.

<!-- PTO-READER-BLOCK: tile-mgather-xor-effects role=effects -->
## GM, destination, and fault effects

Before the commit phase, every physical destination element is initialized. Inactive valid coordinates under an ExecutionMask receive the mask's zero or merge value; every other element receives the bundle `PadValue`, where an omitted `B.DATR` gives `Null` and `Null` writes zero bits. Active lanes then overwrite their element with the old value, and the whole physical region is marked defined.

On success each active lane has written GM once, and each of those writes counts as one atomic event under NDF `PTO-ATOM-RED-ORDERING-001`. Those GM writes stay visible; the body performs no rollback of memory.

If any probe faults, the body returns before its first event, and the dispatcher calls `RollBackBundleTileDestinations`, which releases the destination this bundle allocated. No old value is published.

<!-- PTO-READER-BLOCK: tile-mgather-xor-constraints role=constraints -->
## Types, shape, and fault boundary

The bundle `DataType` must be one of `U32`, `U64`. No packed four-bit type is in the operation/type matrix, and NDF `PTO-ATOM-RED-TYPE-LEGALITY-001` also excludes Shared operands, vectors, packed FP16x2 and BF16x2, and U128.

Every `B.DIM` value must be in `1..65535`, and valid rows times valid columns may not exceed `PTO_MODEL_TILE_ELEMENTS`. For RowMajor, valid columns may not exceed physical columns, which must be a nonzero power of two. The layout is RowMajor, CUBE_M16, or CUBE_M32.

An unknown TLSU code raises `Fault_IllegalInstruction`. A wrong number of `B.IOT` commands raises `Fault_BundleControl`. A missing `B.IOR`, a Shared binding, a bad dimension, type, shape, layout, or undefined active index or value element raises `Fault_TileLegality`. All of these happen before any probe, and a destination allocation failure raises `Fault_TileAllocation`.

`PE_MASK=0000` exits at the start of the GM atom/red dispatcher, before its schema, GPR, descriptor, type, and memory checks.

<!-- PTO-READER-BLOCK: tile-mgather-xor-example role=example -->
## Non-normative worked example

Treat the generated `MGATHER_XOR` example as a spelling and navigation aid. Substitute operands only within the legality and state contracts owned below.

Take `U32`, base `0x2000` in `a0`, a 1 by 2 `S32` index Tile holding `0, 4`, and a value Tile holding `0x000F, 0x000F`. GM holds `0x00FF` at `0x2000` and `0x0000` at `0x2004`.

- Lane 0 computes `0x00FF` XOR `0x000F` = `0x00F0` and stores `0x00F0` at `0x2000`.
- Lane 1 computes `0x0000` XOR `0x000F` = `0x000F` and stores `0x000F` at `0x2004`.
- The destination receives the old values `0x00FF, 0x0000`.

In macro form this is `MGATHER_XOR <Col=2, U32>, [base=a0], T#1, T#2, ->T<128B>`, with `T#1` as the index Tile and `T#2` as the value Tile. The 128-byte destination holds 32 physical elements: 2 receive old values and the other 30 receive the pad value, which is zero bits for the default `Null`.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MGATHER_XOR <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MGATHER_XOR | TLSU |  | 18 |  | GM_ATOM_VALUE |

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MGATHER_XOR.asl -->
```asl
readonly func InstructionContractMatches_MGATHER_XOR(operation: TileOperation) => boolean
begin
    return operation == TileOperation_MGATHER_XOR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.XOR DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MGATHER_XOR.asl -->
```asl
readonly func InstructionContractHandler_MGATHER_XOR() => TileSemanticHandler
begin
    return TileHandler_GM_ATOM_VALUE;
end;
readonly func InstructionContractOperation_MGATHER_XOR() => TileOperation
begin
    return TileOperation_MGATHER_XOR;
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

- BSTART.MGATHER.XOR DataType
