<!-- GENERATED FROM: asl/tile/memory-and-data-movement/pe-movement/GMOV.asl -->
# GMOV

**Normative ASL source:** `asl/tile/memory-and-data-movement/pe-movement/GMOV.asl`

Copies peer-resolved Local fragments within a Core4 collective.

## Normative identity {#PTO-INST-TILE-GMOV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
