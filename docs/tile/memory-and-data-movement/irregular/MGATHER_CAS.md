<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
# MGATHER_CAS

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl`

Atomically compare and conditionally replace GM elements at signed or unsigned byte displacements.

## Normative identity {#PTO-INST-TILE-MGATHER-CAS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MGATHER_CAS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MGATHER_CAS | TLSU |  | 8 |  | MGATHER_CAS |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | observed-old-values destination |
| address | base-address |
| source0 | byte-displacement indices |
| source1 | expected values |
| source2 | replacement values |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
```asl
readonly func InstructionContractOperation_MGATHER_CAS() => TileOperation
begin
    return TileOperation_MGATHER_CAS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MGATHER.CAS DataType
B.DATR PadValue, Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT IndexTile, ExpectedTile, mask=PE_MASK
B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MGATHER_CAS.asl -->
```asl
readonly func InstructionContractHandler_MGATHER_CAS() => TileSemanticHandler
begin
    return TileHandler_MGATHER_CAS;
end;

pure func InstructionContractUsesByteDisplacements_MGATHER_CAS()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MGATHER_CAS()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MGATHER_CAS()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractWritesMemory_MGATHER_CAS()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the byte-address base; zero selects architectural base address zero. Unused B.IOR fields must encode zero.
- LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.
- Omitted B.DATR selects PadValue=Null and Layout=NORM. The pad value defines every physical destination element outside ValidRow x ValidCol.
- Each IndexTile logical element is a signed or unsigned byte displacement. Comparison and replacement values use the selected transfer DataType.

## Legality

- MGATHER_CAS is selected only by BSTART.MGATHER.CAS function 8 in the TLSU selector space; it has no standalone opcode.
- Exactly two Local B.IOT bindings are required. The first supplies IndexTile and ExpectedTile without a destination and has L=0. The second supplies ReplacementTile and a newly allocated destination and has L=1. Both carry one common PE_MASK; B.IOS is not accepted.
- IndexTile must be allocated, fully defined, generically indexable, and use S32, U32, S64, or U64. Each logical element is sign- or zero-extended as a byte displacement.
- ExpectedTile and ReplacementTile must be allocated, fully defined, use the selected transfer DataType, and match the resolved ValidRow x ValidCol. Comparison uses their encoded element values.
- Packed four-bit transfer DataTypes E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 are rejected because the block carries no nibble selector.
- Destination physical Rows are derived from TSize, physical Col, and transfer DataType. Rows and Col are powers of two and the physical region contains ValidRow x ValidCol.
- B.IOT PE_MASK=0000 is a strict no-op before schema, GPR, source, dimension, allocation, address, or fault checks.
- B.DATR applicability allows only PadValueOrByteId as PadValue and Layout.

## State effects

- Allocate a new Local destination descriptor using B.IOT TSize, resolved dimensions, selected transfer DataType, selected Layout, and PE_MASK.
- On success the full physical destination is defined: valid coordinates contain the values observed by their atomic operations and all other physical coordinates contain the selected pad value.

## Memory effects and ordering

### Memory effects

- For each valid coordinate, atomically read the selected transfer-typed element at BaseGPR plus the corresponding signed or unsigned byte displacement, compare it with ExpectedTile, conditionally store ReplacementTile, and place the observed old value in the destination.
- All lane addresses are preflighted before the first atomic event. Duplicate addresses are legal and their per-lane atomic operations serialize in an implementation-defined order; no row-major or other fixed order is architectural.
- After every selected lane completes, publish the observed valid region and pad every remaining physical destination coordinate atomically.

### Ordering

- Each lane is one atomic read-modify-write governed by the block memory-order attributes.
- Duplicate-address lanes serialize in an implementation-defined order. No additional inter-PE order is guaranteed.

## Exceptions

- A missing B.IOR, missing LB0, malformed two-command B.IOT sequence, non-integer IndexTile, shape or type mismatch, packed four-bit transfer DataType, or invalid dimensions raises Fault_TileLegality before destination allocation, atomic events, or memory writes.
- Every valid-region read and write address is probed before the first compare-and-swap. Any access fault leaves the destination unallocated and produces no partial atomic event, memory write, or payload effect.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.MGATHER.CAS DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, ExpectedTile, mask=PE_MASK; B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
