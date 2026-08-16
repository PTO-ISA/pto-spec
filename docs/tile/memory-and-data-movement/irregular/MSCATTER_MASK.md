<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl -->
# MSCATTER_MASK

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl`

Scatter exact-one source lanes to GM at signed or unsigned byte displacements.

## Normative identity {#PTO-INST-TILE-MSCATTER-MASK}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER_MASK <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER_MASK | TLSU |  | 7 |  | MSCATTER_MASK |

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
| source2 | exact zero-or-one predicate mask |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl -->
```asl
readonly func InstructionContractOperation_MSCATTER_MASK() => TileOperation
begin
    return TileOperation_MSCATTER_MASK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER.MASK DataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT DataTile, IndexTile, mask=PE_MASK
B.IOT MaskTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER_MASK.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER_MASK() => TileSemanticHandler
begin
    return TileHandler_MSCATTER_MASK;
end;

pure func InstructionContractUsesByteDisplacements_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MSCATTER_MASK()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the byte-address base; zero selects architectural base address zero. Unused B.IOR fields must encode zero.
- LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.
- Omitted B.DATR selects Layout=NORM; every other B.DATR field must remain zero.
- Each IndexTile element is a signed or unsigned byte displacement. Each MaskTile element must be exactly zero or one.

## Legality

- MSCATTER_MASK is selected only by BSTART.MSCATTER.MASK function 7 in the TLSU selector space; it has no standalone opcode.
- Exactly two Local B.IOT records supply DataTile plus IndexTile and then MaskTile with the sole last marker. Neither record has a destination or TSize; B.IOS and additional bindings are illegal.
- All three sources are allocated and fully defined, share ValidRow x ValidCol and Layout, and persist after execution. DataTile DataType equals BSTART DataType; IndexTile is integer; MaskTile valid elements are exactly zero or one.
- DataTile physical Col equals LB2. IndexTile and MaskTile may use different physical shapes outside the common valid rectangle.
- Packed four-bit transfer DataTypes E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 reject because the block carries no nibble selector.
- PE_MASK is common across both B.IOT records. PE_MASK=0000 is a strict no-op before schema, predicate, GPR, address, permission, event, or memory checks.
- B.DATR applicability allows only Layout.

## State effects

- All three source descriptors and payloads persist unchanged after success or rejection.
- On success only enabled-lane memory and event state changes; MSCATTER_MASK allocates no destination Tile.

## Memory effects and ordering

### Memory effects

- For each valid coordinate whose MaskTile value is one, store the corresponding DataTile element to BaseGPR plus the sign- or zero-extended byte displacement in IndexTile.
- A zero mask value performs no address generation, translation, permission check, store, or memory event. Physical source elements outside ValidRow x ValidCol also have no effect.
- All enabled lanes are preflighted before stores. Duplicate or overlapping enabled targets have an implementation-defined final winner.

### Ordering

- Enabled stores participate in the common memory-order domain; no lane or inter-PE issue order is guaranteed.
- B.CATR.atomic=1 makes the complete block effect non-interleavable but does not define an internal enabled-lane order or duplicate-address winner.

## Exceptions

- A missing B.IOR or LB0, malformed or unterminated B.IOT stream, undefined source, source DataType mismatch, non-integer IndexTile, mask value other than zero or one, shape or layout mismatch, invalid dimensions, or packed transfer DataType raises Fault_TileLegality before effects.
- Only exact-one lanes generate addresses. Every enabled address is probed before the first store or event; an enabled-lane fault produces no partial write or event, while a disabled lane cannot fault from its ignored index.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.MSCATTER.MASK DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK; B.IOT MaskTile, mask=PE_MASK, <last>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
