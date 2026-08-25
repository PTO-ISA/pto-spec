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
## Purpose

`TPREFETCH` prefetches a typed, strided GM rectangle for all four PEs without a Tile destination.

<!-- PTO-READER-BLOCK: tile-tprefetch-mechanism role=mechanism -->
## Execution mechanism

The ASL DOC contract selects `TileHandler_TPREFETCH` through the instruction's selector-encoded block carrier.

All four PE address footprints are preflighted before the first request or event; no Tile or Shared destination exists.

<!-- PTO-READER-BLOCK: tile-tprefetch-inputs-outputs role=inputs-outputs -->
## Operands and descriptors

`address` is the per-PE GM base; `scalar0` is the per-PE logical row stride in elements; `positive0` is the ValidCol; `positive1` is the ValidRow; `positive2` is the physical Col.

`TPREFETCH` produces no destination descriptor or Tile state; its only successful architectural contribution is the typed memory-event sequence.

<!-- PTO-READER-BLOCK: tile-tprefetch-effects role=effects -->
## Publication and ordering

Success emits TLOAD-equivalent typed load events for the strided rectangle but exposes no architectural cache placement or retention state.

The block aq/rl attributes provide the same PTO-TSO ordering used by TLOAD.

<!-- PTO-READER-BLOCK: tile-tprefetch-constraints role=constraints -->
## Legality, padding, and faults

Dimensions, data attributes, and the combined four-PE memory footprint are validated before the first request or event.

Any memory fault rejects the whole prefetch without a partial event sequence and without changing Tile, Shared, descriptor, payload, definedness, or allocation state.

<!-- PTO-READER-BLOCK: tile-tprefetch-example role=example -->
## Non-normative contract sketch

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

Read `BSTART.TPREFETCH U8; B.DIM zero, 16, ->LB0; B.DIM zero, 4, ->LB1; B.DIM zero, 32, ->LB2; B.IOR zero, a0; BSTOP` as a non-normative binding walkthrough, then use the generated contract below for exact dimensions, attributes, and fault behavior.
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
- Use CurrentBundleMemoryOrder so aq/rl and PTO-TSO behavior match TLOAD.

## Exceptions

- Malformed dimensions, unsupported data attributes, any B.IOT or B.IOS, or any memory fault in the combined four-PE footprint rejects before the first request or event.
- A rejected or faulting attempt changes no Tile, Shared, descriptor, payload, definedness, or allocation state.

## Examples

- BSTART.TPREFETCH U8; B.DIM zero, 16, ->LB0; B.DIM zero, 4, ->LB1; B.DIM zero, 32, ->LB2; B.IOR zero, a0; BSTOP
