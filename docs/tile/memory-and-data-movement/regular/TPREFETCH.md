<!-- GENERATED FROM: asl/tile/memory-and-data-movement/regular/TPREFETCH.asl -->
# TPREFETCH

**Normative ASL source:** `asl/tile/memory-and-data-movement/regular/TPREFETCH.asl`

Prefetches a typed, strided GM rectangle for all four PEs without producing a Tile destination.

## Normative identity {#PTO-INST-TILE-TPREFETCH}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tprefetch-purpose role=purpose -->
## What TPREFETCH does

`TPREFETCH` reads a typed, strided GM rectangle for all four PEs and produces no destination. It is TLSU Function 3, written `BSTART.TPREFETCH DataType`, and it has no standalone opcode.

The block has implicit PE participation `1111` and binds no Local or Shared Tile: any `B.IOT` or `B.IOS` in the block is a malformed schema and faults.

<!-- PTO-READER-BLOCK: tile-tprefetch-mechanism role=mechanism -->
## Footprint and ordering

For each of the four PEs the footprint is the same typed `ValidRow` by `ValidCol` rectangle that `TLOAD` would read from that PE's private base and row-stride GPR values. The address is built by `TileMemoryIndexedAddress`, so `scalar0` counts logical elements: that helper multiplies by `TileElementBytes` for ordinary types and shifts the index right by one bit for the packed four-bit types, where one logical element therefore advances half a byte.

`TPREFETCHCore` runs two passes. The first probes every typed element of every PE for read access; the second loads each translated address and records one typed load event for that PE with `CurrentBundleMemoryOrder()`.

Design point: all four PE footprints are probed before the first event, so a fault in any PE rejects the whole prefetch and leaves no partial event prefix. `TLOAD` behaves differently: it stops at the first fault and keeps the events it already recorded.

An omitted `B.IOR` gives base zero and the dense row stride, which is the resolved physical `Col` counted in elements, for every PE. An explicitly encoded zero selector is a real zero stride, so every row then aliases row 0.

<!-- PTO-READER-BLOCK: tile-tprefetch-inputs-outputs role=inputs-outputs -->
## Operand roles and bindings

- `address` is the per-PE GM base.
- `scalar0` is the per-PE logical row stride in elements.
- `positive0` is `ValidCol`.
- `positive1` is `ValidRow`.
- `positive2` is the physical `Col`.

`LB0`, `LB1`, and `LB2` supply these dimensions. An omitted `LB0` or `LB1` selects `1`, and an omitted `LB2` selects the resolved `ValidCol`.

Design point: each PE reads its base and stride from its own private GPR file, so one prefetch can cover four different GM regions while the shape stays common to all of them.

<!-- PTO-READER-BLOCK: tile-tprefetch-effects role=effects -->
## What changes

A successful prefetch changes no Tile, Shared, descriptor, payload, definedness, or allocation state. Its only architectural contribution is the typed memory-access and ordering event sequence.

Those events are the typed element load events that `TLOAD` would record for the same footprint, but no value is published anywhere.

Design point: `InstructionContractPublishesTileDestination_TPREFETCH` is `FALSE` and the contract states that cache placement and retention are not architecturally visible, so the observable result is the event sequence rather than the presence of data in any cache.

<!-- PTO-READER-BLOCK: tile-tprefetch-constraints role=constraints -->
## Types, shapes, and faults

`InstructionContractDataTypeLegal_TPREFETCH` accepts the types `TileCarrierOrPackedBaselineDataTypeSupported` admits: non-four-bit carriers up to 4 bytes wide, plus the packed four-bit types.

`ValidCol` and `ValidRow` are positive, `Col` is a nonzero power of two and at least `ValidCol`, and `ValidRow * ValidCol` may not exceed `PTO_MODEL_TILE_ELEMENTS`. `B.DATR` permits only `Layout` as a nonzero operation attribute and requires the pad union to remain zero.

A malformed dimension, an unsupported data attribute, any `B.IOT` or `B.IOS`, or a memory fault in the combined four-PE footprint rejects before the first event and changes no Tile, Shared, descriptor, payload, definedness, or allocation state.

Design point: participation is implicit `1111` and the schema accepts no Tile binding, so a block can neither restrict a prefetch to a subset of PEs nor attach a destination to it.

<!-- PTO-READER-BLOCK: tile-tprefetch-example role=example -->
## Non-normative contract sketch

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

Take `U8`, `Row=4`, `Col=16`, `ValidRow=4`, and `ValidCol=16`, with `a0` holding each PE's GM base and `a1` the dense row stride of `16` elements. The canonical macro spelling is `TPREFETCH <Row=4, Col=16, ValidCol=16, U8>, [base=a0, stride=a1]`.

- Per PE the footprint is `4 * 16 = 64` typed elements, so the four PEs together probe and record `256` element events.
- Omitting the `B.IOR` gives base `0` and stride `16` for every PE; an encoded zero selector supplies a real zero value instead.
- A fault at any element of any PE produces no event at all, because the probe pass over all four PEs runs first.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
TPREFETCH <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TPREFETCH | TLSU |  | 3 |  | TPREFETCH |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| address | per-PE GM base |
| scalar0 | per-PE logical row stride in elements |
| positive0 | ValidCol |
| positive1 | ValidRow |
| positive2 | physical Col |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/regular/TPREFETCH.asl -->
```asl
readonly func InstructionContractOperation_TPREFETCH() => TileOperation
begin
    return TileOperation_TPREFETCH;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TPREFETCH DataType
B.DATR Layout (optional)
B.DIM LB0/ValidCol, LB1/ValidRow, LB2/Col (optional)
B.IOR base,row_stride (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/regular/TPREFETCH.asl -->
```asl
pure func InstructionContractDataTypeLegal_TPREFETCH(
    code: bits(5)) => boolean
begin
    if !TileDataTypeEncodingValid(code as TileDataTypeEncoding) then
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(code as TileDataTypeEncoding);
    return TileCarrierOrPackedBaselineDataTypeSupported(data_type);
end;

readonly func InstructionContractHandler_TPREFETCH() => TileSemanticHandler
begin
    return TileHandler_TPREFETCH;
end;

pure func InstructionContractPublishesTileDestination_TPREFETCH()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUsesTLOADFootprint_TPREFETCH()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Omitted B.DATR selects NORM; omitted LB0 and LB1 each select one, and omitted LB2 selects resolved ValidCol.
- Omitted B.IOR supplies base zero and dense row stride equal to resolved Col for every PE. Explicit zero selectors remain actual zero values.

## Legality

- TPREFETCH is selected only by BSTART.TPREFETCH at TLSU Function 3 and has no standalone opcode.
- It has implicit participation 1111 and accepts no Local or Shared Tile binding.
- ValidCol and ValidRow are positive; Col is a nonzero power of two and is at least ValidCol.
- B.DATR permits only Layout as a nonzero operation attribute and requires the pad union to remain zero.

## State effects

- No destination Tile exists and no Tile or Shared state changes.
- A successful attempt contributes only its typed memory-access and ordering events.

## Memory effects and ordering

### Memory effects

- For each PE, prefetch the same typed, strided ValidRow x ValidCol GM footprint that TLOAD would read from that PE's private base and row-stride GPR values.
- The operation records TLOAD-equivalent typed-element load events but produces no destination. Cache placement and retention are not architecturally visible.

### Ordering

- Preflight all addresses and permissions for all four PEs before any event.
- Use CurrentBundleMemoryOrder so aq/rl and PTO-RC behavior match TLOAD.

## Exceptions

- Malformed dimensions, unsupported data attributes, any B.IOT or B.IOS, or any memory fault in the combined four-PE footprint rejects before the first request or event.
- A rejected or faulting attempt changes no Tile, Shared, descriptor, payload, definedness, or allocation state.

## Examples

- BSTART.TPREFETCH U8; B.DIM zero, 16, ->LB0; B.DIM zero, 4, ->LB1; B.DIM zero, 32, ->LB2; B.IOR zero, a0; BSTOP
