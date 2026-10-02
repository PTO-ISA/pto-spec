<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER_POPC.asl -->
# MSCATTER_POPC

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER_POPC.asl`

GM indexed mscatter.popc operation.

## Normative identity {#PTO-INST-TILE-MSCATTER-POPC}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mscatter-popc-purpose role=purpose -->
## What MSCATTER_POPC does

`MSCATTER_POPC` is TLSU Function 27, written `BSTART.MSCATTER.POPC DataType`. It is an indexed GM reduction: each active valid index contributes one `U32` increment at the address formed by the per-PE base address from `B.IOR.RegSrc0` plus that index's logical element index. It reads no value Tile and publishes no destination.

The body `GM_RED_POPC` fixes the transfer type to `TileDataType_U32`, and `ExecuteBundleGMAtomRedOperation` reaches it through the `popc` branch with `TileOperandsLegal_GM_RED_POPC`. NDF `PTO-ATOM-RED-POPC-SEMANTICS-001` states the same contract: one `U32` increment per valid effective GM address, with no ValueTile and no destination, and NDF `PTO-ATOM-RED-BODY-SCHEMA-001` adds that `mscatter.popc` has indices only.

Design point: with no ValueTile the increment amount cannot be programmed, and with no destination no observed value is returned. The observable effect is a count, per address, of the active indices that named it.

<!-- PTO-READER-BLOCK: tile-mscatter-popc-mechanism role=mechanism -->
## Preflight and increment commit

The body probes before it writes. For every active coordinate it probes the `U32` access for read and then for write, raises the probe fault at once, and rejects with `Fault_DataPage` when the read and the write translation differ. Only after that pass does the commit loop run.

The commit loop visits lanes in an order drawn from `ARBITRARY` choices. Each lane loads the old `U32` word, computes `old + Zeros{PTO_XLEN} + 1`, stores it at the four-byte element width, and records one atomic event carrying `CurrentBundleMemoryOrder()`.

Design point: the increment is a plain `old + 1` at `U32` width with no limit operand, so a word holding `0xFFFFFFFF` becomes `0x00000000`. The INC form differs: `GMIncValue` compares against a limit taken from its value Tile and returns zero at or above that limit (NDF `PTO-ATOM-RED-INC-DEC-SEMANTICS-001`).

Design point: NDF `PTO-ATOM-RED-ORDERING-001` makes every valid request one intrinsic atomic event and requires duplicate effective addresses to serialize in an implementation-defined order with all of them effective. Two lanes naming one address therefore add 2 whatever order is chosen, unlike `MSCATTER`, whose duplicate stores leave only one winner.

<!-- PTO-READER-BLOCK: tile-mscatter-popc-inputs role=inputs-outputs -->
## Operand roles and bindings

- `address` is the base address, read from the GPR named by `B.IOR.RegSrc0` in the executing PE's own register file; `B.IOR` is required and `RegSrc1`, `RegSrc2`, and `RegDst` must encode zero.
- `source0` is the index Tile: `S32`, `U32`, `S64`, or `U64` elements, with `LB1` valid rows, `LB0` valid columns, and the bundle layout.

The body binds one terminating Local `B.IOT` carrying only the index Tile; a destination field and a ValueTile are forbidden (NDF `PTO-ATOM-RED-BODY-SCHEMA-001`). `ExecuteBundleGMAtomRedOperation` expects exactly one binding for Function 27 and raises `Fault_BundleControl` for any other count.

There is no per-lane predicate operand here, so the only lane filter is a bundle ExecutionMask, and there is no destination for a merge-mode ExecutionMask to fill.

<!-- PTO-READER-BLOCK: tile-mscatter-popc-effects role=effects -->
## Effects, ordering, and fault visibility

On success each active lane has performed one read-modify-write of one `U32` word and recorded one atomic event. The index Tile keeps its descriptor and payload, and no Tile destination is allocated or published.

The GM writes stay visible; nothing rolls memory back after a lane's increment is stored. `Fault_DataPage` is also raised when a lane's read probe and write probe translate to different addresses, and that happens before the lane's increment.

Every read and write probe of every active lane completes before the first event (NDF `PTO-ATOM-RED-ORDERING-001`), so a bundle rejected by an alignment or page fault has changed no GM location.

Because the increment is stored at the four-byte element width, only the low 32 bits of the computed word reach memory.

<!-- PTO-READER-BLOCK: tile-mscatter-popc-constraints role=constraints -->
## Type, layout, and fault boundary

The bundle `DataType` must be `U32`: `GMReductionOperationDataTypeLegal(GMReduction_POPC, data_type)` accepts no other member of the `BSTART.MSCATTER.POPC` `DataType` field domain, and the body reads no transfer type from a Tile.

The index Tile is `S32`, `U32`, `S64`, or `U64` and must carry the bundle layout with the `LB1` and `LB0` valid shape. Every `B.DIM` value must be in `1..65535`, and with `RowMajor` the shape needs `ValidCol <= Col` and a `Col` that is a nonzero power of two.

The generated legality of this page excludes Shared, vector, packed, and U128 forms, because the operation is GM-only. `Fault_IllegalInstruction` covers an unknown TLSU code, `Fault_BundleControl` a wrong `B.IOT` count, and `Fault_TileLegality` a missing `B.IOR`, a Shared binding, a dimension, type, or layout mismatch, or an undefined active index element. Access faults are raised in the preflight pass.

A `B.DATR` may also set `PadValueOrByteId` for this form, whose pad union is `pad-value`; no destination consumes it.

`PE_MASK=0000` on the binding exits at the top of the dispatcher, before the decode, schema, GPR, dimension, descriptor, type, and memory checks.

<!-- PTO-READER-BLOCK: tile-mscatter-popc-example role=example -->
## Non-normative worked example

Take `U32`, `ValidRow=1`, `ValidCol=2`, `Col=4`, base `0x1000` in `a0`, and a 1 by 2 `U32` index Tile holding `0, 0`. GM holds the `U32` word `5` at `0x1000`.

- Both coordinates name displacement `0`, so both target `0x1000`.
- Both increments take effect, so `0x1000` ends at 5 + 1 + 1 = 7 whichever order the commit loop picks.
- Had the word at `0x1000` been `0xFFFFFFFF`, it would end at `0x00000001`, because each increment is stored at 32 bits.

The macro spelling is `MSCATTER_POPC <Col=4, ValidCol=2, U32>, [base=a0], T#1`, with `T#1` as the index Tile; this form has no destination operand, so no `->T<Size>` term appears.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER_POPC <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER_POPC | TLSU |  | 27 |  | GM_RED_POPC |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| address | base-address |
| source0 | indices |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER_POPC.asl -->
```asl
readonly func InstructionContractMatches_MSCATTER_POPC(operation: TileOperation) => boolean
begin
    return operation == TileOperation_MSCATTER_POPC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.POPC DataType
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col
B.IOT IndexTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER_POPC.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER_POPC() => TileSemanticHandler
begin
    return TileHandler_GM_RED_POPC;
end;
readonly func InstructionContractOperation_MSCATTER_POPC() => TileOperation
begin
    return TileOperation_MSCATTER_POPC;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.
- GM indexed operation uses logical-element-index addresses and complete preflight.

## Legality

- GM-only; Shared, vector, packed, and U128 forms are rejected.
- The body binds one terminating Local B.IOT carrying only IndexTile; ValueTile and destination fields are forbidden.
- ValidRow and ValidCol are nonzero and match every Tile source and any published destination; selected-layout legality requires ValidCol <= Col, with CUBE descriptor rules applied separately.

## State effects

- Every valid index contributes one U32 increment; no ValueTile or destination is read or published.

## Memory effects and ordering

### Memory effects

- One intrinsic atomic RMW per valid request.

### Ordering

- Duplicate-address events serialize in implementation-defined order.

## Exceptions

- Legality and access faults occur before effects.

## Examples

- BSTART.MSCATTER.POPC DataType
