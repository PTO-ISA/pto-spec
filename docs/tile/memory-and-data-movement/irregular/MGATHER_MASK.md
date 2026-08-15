<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MGATHER_MASK.asl -->
# MGATHER_MASK

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MGATHER_MASK.asl`

Gather enabled GM elements at byte displacements and pad disabled destination lanes.

## Normative identity {#PTO-INST-TILE-MGATHER-MASK}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MGATHER_MASK <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MGATHER_MASK | TLSU |  | 6 |  | MGATHER_MASK |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| address | base-address |
| source0 | byte-displacement indices |
| source1 | exact zero-or-one predicate mask |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MGATHER_MASK.asl -->
```asl
readonly func InstructionContractOperation_MGATHER_MASK() => TileOperation
begin
    return TileOperation_MGATHER_MASK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.MASK DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MGATHER_MASK.asl -->
```asl
readonly func InstructionContractHandler_MGATHER_MASK() => TileSemanticHandler
begin
    return TileHandler_MGATHER_MASK;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the byte-address base; zero selects architectural base address zero. Unused B.IOR fields must encode zero.
- LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.
- Omitted B.DATR selects PadValue=Null and Layout=NORM. PadValue is written to disabled valid lanes and every physical destination element outside ValidRow x ValidCol.
- Each IndexTile logical element is a signed or unsigned byte displacement. Each MaskTile logical element must be exactly zero or one.

## Legality

- MGATHER_MASK is selected only by BSTART.MGATHER.MASK function 6 in the TLSU selector space; it has no standalone opcode.
- Exactly one terminating Local B.IOT supplies IndexTile, MaskTile, destination, TSize, and PE_MASK. B.IOS and additional Tile bindings are not accepted.
- IndexTile must be allocated, fully defined, generically indexable, and use S4X2, U4X2, S8, U8, S16, U16, S32, U32, S64, or U64. Each logical element is sign- or zero-extended as a byte displacement.
- MaskTile must be allocated and fully defined. Its logical shape and layout must match IndexTile and destination; every valid element is exactly zero or one.
- Packed four-bit transfer DataTypes E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 are rejected because the block carries no nibble selector.
- Destination physical Rows are derived from TSize, physical Col, and transfer DataType. Rows and Col are powers of two and the physical region contains ValidRow x ValidCol.
- B.IOT PE_MASK=0000 is a strict no-op before schema, GPR, source, predicate, dimension, allocation, address, or fault checks.
- B.DATR applicability allows only PadValueOrByteId as PadValue and Layout.

## State effects

- Allocate a new Local destination descriptor using B.IOT TSize, resolved dimensions, selected transfer DataType, selected Layout, and PE_MASK.
- On success the full physical destination is defined: enabled valid lanes contain loaded values and every disabled or non-valid coordinate contains PadValue.

## Memory effects and ordering

### Memory effects

- For each valid coordinate whose MaskTile value is one, load one transfer-typed element from BaseGPR plus the corresponding sign- or zero-extended byte displacement and record one load event.
- A valid coordinate whose mask is zero performs no address generation, translation, permission check, memory access, or memory event and receives PadValue.
- After complete enabled-lane preflight, publish enabled loads, disabled-lane padding, and all non-valid physical padding atomically.

### Ordering

- Enabled-lane loads participate in the PTO memory-order domain through the block aq/rl attributes.
- No additional lane or inter-PE issue order is guaranteed.

## Exceptions

- A missing B.IOR, missing LB0, malformed B.IOT, non-integer IndexTile, mask value other than zero or one, shape or layout mismatch, packed four-bit transfer DataType, or invalid dimensions raises Fault_TileLegality before destination allocation, memory events, or memory reads.
- Only enabled-lane addresses are generated and probed. Every enabled lane is preflighted before the first load; any enabled-lane fault leaves the destination unallocated and produces no partial event or payload effect. Disabled lanes cannot fault from their ignored IndexTile value.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.MGATHER.MASK DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
