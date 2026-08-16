<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER.asl -->
# MSCATTER

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER.asl`

Scatter the valid source region to GM at signed or unsigned byte displacements.

## Normative identity {#PTO-INST-TILE-MSCATTER}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER | TLSU |  | 5 |  | MSCATTER |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| address | base-address |
| source0 | source data |
| source1 | byte-displacement indices |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER.asl -->
```asl
readonly func InstructionContractOperation_MSCATTER() => TileOperation
begin
    return TileOperation_MSCATTER;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER DataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT DataTile, IndexTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER() => TileSemanticHandler
begin
    return TileHandler_MSCATTER;
end;

pure func InstructionContractUsesByteDisplacements_MSCATTER()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MSCATTER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MSCATTER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MSCATTER()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the byte-address base; zero selects architectural base address zero. Unused B.IOR fields must encode zero.
- LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.
- Omitted B.DATR selects Layout=NORM. PadValueOrByteId and every other B.DATR field must remain zero.
- Each IndexTile logical element is a signed or unsigned byte displacement added directly to BaseGPR.

## Legality

- MSCATTER is selected only by BSTART.MSCATTER function 5 in the TLSU selector space; it has no standalone opcode.
- Exactly one terminating Local B.IOT supplies DataTile and IndexTile with no destination or TSize. B.IOS and additional Tile bindings are not accepted.
- DataTile and IndexTile must be allocated and fully defined. DataTile DataType must equal the BSTART transfer DataType. IndexTile must use a signed or unsigned integer DataType.
- DataTile physical Col equals resolved LB2. Both sources have resolved ValidRow x ValidCol and selected Layout; IndexTile may use a different physical shape outside that valid rectangle.
- Packed four-bit transfer DataTypes E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 are rejected because the block carries no nibble selector.
- B.IOT PE_MASK=0000 is a strict no-op before schema, GPR, source, dimension, address, permission, event, or memory checks.
- B.DATR applicability allows only Layout.

## State effects

- Source Tile descriptors and payloads persist unchanged after success or rejection.
- On success only memory and memory-event state change; MSCATTER allocates no destination Tile.

## Memory effects and ordering

### Memory effects

- For every valid coordinate, store the corresponding DataTile element to BaseGPR plus the sign- or zero-extended byte displacement in the IndexTile coordinate.
- Only ValidRow x ValidCol is written; source physical elements outside the valid rectangle have no memory effect.
- All valid-lane addresses are preflighted before stores. Duplicate or overlapping target addresses have an implementation-defined final winner.

### Ordering

- No lane or inter-PE issue order is architecturally guaranteed.
- B.CATR.atomic=1 makes the complete block memory effect non-interleavable but does not define an internal lane order or a duplicate-address winner.

## Exceptions

- A missing B.IOR, missing LB0, malformed B.IOT, undefined source, source DataType mismatch, non-integer IndexTile, shape or layout mismatch, invalid dimensions, or packed four-bit transfer DataType raises Fault_TileLegality before memory events or writes.
- Every valid-region address is generated and probed before the first store or event; any access fault produces no partial memory or event effect.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.MSCATTER DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK, <last>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
