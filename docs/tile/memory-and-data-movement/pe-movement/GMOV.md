<!-- GENERATED FROM: asl/tile/memory-and-data-movement/pe-movement/GMOV.asl -->
# GMOV

**Normative ASL source:** `asl/tile/memory-and-data-movement/pe-movement/GMOV.asl`

Copies peer-resolved Local fragments within a Core4 collective.

## Normative identity {#PTO-INST-TILE-GMOV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-gmov-purpose role=purpose -->
## What GMOV does

`GMOV` copies one peer-selected Local fragment from inside a Core4 PE group into newly allocated Local destinations. It is TLSU Function 13, written `BSTART.GMOV DataType`, and it has no standalone opcode.

Each PE supplies its own `peer_tid`, the identity of the PE whose Local fragment it wants, and receives that fragment's bytes. `PE_MASK` decides which PEs receive a destination. The operation records no memory effects: it never translates an address, checks a permission, or emits a load, store, atomic, or fence event.

<!-- PTO-READER-BLOCK: tile-gmov-mechanism role=mechanism -->
## Peer resolution and readiness

The dispatcher `ExecuteBundleGMOVOperation` reads one absolute `peer_tid` per PE from the GPR named by the bundle scalar binding. An omitted `B.IOR` supplies `peer_tid` zero in every PE; an explicitly encoded zero selector reads the zero GPR, which also names PE 0 but is a different schema state.

No destination write starts before `BundleGMOVCore4SourceReady` accepts the source snapshot. That helper requires the source to be content-defined and allocated in all four PEs, because it checks `_TileAllocationMasks[[source]] == '1111'`. Every PE also checks its own `peer_tid` against the range `0..3`.

The model `GMOV` then copies the source payload, the defined elements, the packed defined elements, the defined valid element count, and the `contents_defined` flag, so bytes and definedness travel together.

Design point: readiness is a property of the whole Core4 group. A single PE whose Local fragment is not allocated or not fully defined holds back the whole rendezvous, so a partial `PE_MASK` cannot read a fragment that another PE has not produced yet.

<!-- PTO-READER-BLOCK: tile-gmov-inputs role=inputs-outputs -->
## Operand roles and bindings

- `destination0` is the selected Local destination fragment. The bundle allocates it under its `B.IOT` with the source's valid rows, valid columns, physical columns, and data type.
- `source0` is the Core4 peer-resolved read-old Local source snapshot. The destination `TSize` must equal this source's per-PE capacity.
- `scalar0` is each PE's absolute `peer_tid`.

Exactly one terminating `B.IOT` carries the source and the destination, with `L=1`. The bundle takes no second Tile source and no `B.IOS`, and a Shared binding is rejected.

Design point: `GMOV` has no independent shape operands. Every resolved `B.DIM` value must equal `1` and the destination descriptor comes from the source, so a copy cannot reshape the payload.

<!-- PTO-READER-BLOCK: tile-gmov-effects role=effects -->
## What changes

On success each selected PE's newly allocated destination holds a byte-preserving copy of the resolved source fragment, with the same defined elements and the same `contents_defined` flag. Unselected destinations and all Shared and GM state stay unchanged.

Design point: definedness is copied rather than recomputed, so a later consumer inherits the source fragment's definedness boundary instead of re-deriving it.

<!-- PTO-READER-BLOCK: tile-gmov-constraints role=constraints -->
## Types, layouts, and faults

`InstructionContractDataTypeLegal_GMOV` accepts exactly the types `TileCarrierOrPackedBaselineDataTypeSupported` admits: non-four-bit carriers up to 4 bytes wide, plus the packed four-bit types. `B64` carriers such as `U64` and `FP64` are outside that set.

Source and destination must agree on data type, layout, storage kind, rows, columns, valid rows, and valid columns (`TileOperandsLegal_GMOV`). The layout must be `RowMajor`, `CUBE_M16`, or `CUBE_M32`; `CUBE_N8` and Shared operands are illegal.

A `peer_tid` outside `0..3` in any PE, an incomplete Core4 source, a `B.DIM` value other than `1`, a `TSize` mismatch, a surplus or nonterminating binding, or a `B.IOS` raises `Fault_TileLegality` before the copy, and a failed collective preflight allocates and writes no destination.

`PE_MASK` may be any nonzero value, and a partial mask selects only those PEs' destinations. A zero mask selects no PE. Unlike the atom/red, gather, and scatter dispatchers, `ExecuteBundleGMOVOperation` has no zero-mask early return, so the readiness, peer-range, type, layout, and dimension checks still run and can still fault.

Design point: the `peer_tid` range test runs for every PE, including PEs that `PE_MASK` does not select, because peer identities are validated as one collective step before the destination exists.

<!-- PTO-READER-BLOCK: tile-gmov-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

Take `U8`, a source `T#1` with a 1 KB per-PE capacity and a fully defined payload, `PE_MASK` naming PE 0 and PE 1, and `peer_tid` 1 in every PE.

- Preflight: `T#1` must be allocated and fully defined in all four PEs, and the `peer_tid` in `a2` must be in `0..3` in every PE.
- Every resolved `B.DIM` value must be `1`, and the destination `TSize` must equal the 1 KB per-PE capacity of `T#1`.
- The canonical macro spelling is `GMOV <U8, PE0_1>, T#1, a2, ->T<1KB>`. PE 0 and PE 1 each receive a new destination whose bytes and definedness are copies of the resolved PE 1 fragment; PE 2 and PE 3 are unchanged.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
GMOV <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| GMOV | TLSU |  | 13 |  | GMOV |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | selected Local destination fragments |
| source0 | Core4 peer-resolved read-old Local source snapshot |
| scalar0 | each PE's absolute peer_tid |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/pe-movement/GMOV.asl -->
```asl
readonly func InstructionContractOperation_GMOV() => TileOperation
begin
    return TileOperation_GMOV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.GMOV DataType
B.DATR Layout (optional)
B.IOT source, destination, PE_MASK, TSize, L=1
B.IOR peer_tid (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/pe-movement/GMOV.asl -->
```asl
pure func InstructionContractDataTypeLegal_GMOV(
    data_type: TileDataType) => boolean
begin
    return TileCarrierOrPackedBaselineDataTypeSupported(data_type);
end;

readonly func InstructionContractHandler_GMOV() => TileSemanticHandler
begin
    return TileHandler_GMOV;
end;

pure func InstructionContractRequiresCoreFourReadiness_GMOV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractPartialMaskWritesSelectedPEs_GMOV()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Omitted B.DATR selects NORM.
- Omitted B.IOR supplies peer_tid zero in each PE; an explicit zero selector reads the zero GPR and is not absence.

## Legality

- GMOV is TLSU Function 13 and has no standalone opcode.
- Exactly one terminating Local source-plus-destination B.IOT is required. Its destination TSize equals the source per-PE capacity.
- Any nonzero PE_MASK is legal; it selects destination writes but not rendezvous or source readiness. Mask zero is a strict no-op.
- All four peer-resolved source fragments are ready before any selected request; each private peer_tid is 0..3 and may repeat. Local RowMajor, CUBE_M16, and CUBE_M32 forms preserve one selected layout; CUBE_N8 and Shared are illegal.

## State effects

- Copies the byte-preserving resolved source fragment into each selected PE's newly allocated Local destination and copies definedness.
- Unselected destinations and all Shared/GM state remain unchanged.

## Memory effects and ordering

### Memory effects

- none; GMOV neither accesses global memory nor emits load, store, atomic, or fence events

### Ordering

- Combined Core4 rendezvous, descriptor, readiness, and peer validation precedes destination allocation and payload publication.
- The source payload and definedness are snapshotted before any destination write.

## Exceptions

- Reject incompatible source/destination capacity, shape, type, or layout, incomplete Core4 source readiness, peer_tid outside 0..3 in any PE, nonterminating or surplus bindings, any resolved B.DIM value other than one, or B.IOS before effects.
- A failed collective preflight allocates and writes no destination.

## Examples

- BSTART.GMOV U8; B.IOT T#1, mask=0101, size=1, ->T; B.IOR zero, a0; BSTOP
