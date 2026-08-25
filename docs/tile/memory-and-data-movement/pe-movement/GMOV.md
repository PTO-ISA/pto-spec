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

`GMOV` is a selector-encoded Tile operation executed by `TLSU`. It resolves one peer-selected read-old Local fragment for each PE and byte-copies it into the selected new Local fragments; its current instruction contract owns the exact bundle form and publication boundary.

<!-- PTO-READER-BLOCK: tile-gmov-mechanism role=mechanism -->
## Element and Tile mechanism

After all descriptor and operand checks succeed, the owning ASL handler resolves one peer-selected read-old Local fragment for each PE and byte-copies it into the selected new Local fragments. Source payloads are snapshotted before destination writes whenever the contract permits aliasing.

The handler uses the resolved valid region rather than treating physical padding as input data. Its operation-specific dtype, layout, rounding, saturation, and profile hooks remain the executable definition.

<!-- PTO-READER-BLOCK: tile-gmov-inputs role=inputs-outputs -->
## Operand roles and descriptors

- `destination0` has the exact contract role **selected Local destination fragments**.
- `source0` has the exact contract role **Core4 peer-resolved read-old Local source snapshot**.
- `scalar0` has the exact contract role **each PE's absolute peer_tid**.

`PE_MASK=0000` is a strict no-op before descriptor, allocation, payload, numeric-status, or memory effects.

<!-- PTO-READER-BLOCK: tile-gmov-effects role=effects -->
## Publication, definedness, and padding

Destination-visible state is published only after complete preflight; where the contract names atomic publication, payload, descriptor, definedness, padding, and status become visible together.

No padding behavior beyond the current handler contract is implied.

The collective changes selected Local destination fragments only; Shared and GM state remain unchanged.

<!-- PTO-READER-BLOCK: tile-gmov-constraints role=constraints -->
## Type, layout, and fault boundary

The exact accepted type or type-pair set is owned by the generated legality section below; this guide does not widen it.

The generated legality and exception sections below are authoritative for dtype pairs, layout, dimensions, capacity, definedness, padding controls, profile behavior, and fault class. Legality and allocation failures occur before partial architectural effects.

<!-- PTO-READER-BLOCK: tile-gmov-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `GMOV` example, if PE 1 resolves `peer_tid=0`, the selected destination fragment receives PE 0 source bytes and the same definedness.
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
- All four peer-resolved source fragments are ready before any selected request; each private peer_tid is 0..3 and may repeat.

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

- Reject incompatible source/destination capacity, shape, type, layout, location, incomplete Core4 source readiness, peer_tid outside 0..3 in any PE, nonterminating or surplus bindings, B.DIM, or B.IOS before effects.
- A failed collective preflight allocates and writes no destination.

## Examples

- BSTART.GMOV U8; B.IOT T#1, mask=0101, size=1, ->T; B.IOR zero, a0; BSTOP
