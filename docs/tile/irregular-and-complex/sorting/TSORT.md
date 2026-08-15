<!-- GENERATED FROM: asl/tile/irregular-and-complex/sorting/TSORT.asl -->
# TSORT

**Normative ASL source:** `asl/tile/irregular-and-complex/sorting/TSORT.asl`

Stably sort independent row groups and return values with original within-group U32 indices.

## Normative identity {#PTO-INST-TILE-TSORT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TSORT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSORT | TEPL | 0x06C | 12 | 3 | TSORT |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### B.IOR.RegDst (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

### B.IOR.RegSrc0 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

### B.IOR.RegSrc1 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

### B.IOR.RegSrc2 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local sorted-value destination |
| destination1 | new Local U32 original-index destination |
| source0 | persistent Local source |
| sort_width | LB0 row-group width |
| flag0 | ascending or descending selection |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/sorting/TSORT.asl -->
```asl
readonly func InstructionContractOperation_TSORT() => TileOperation
begin
    return TileOperation_TSORT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TSORT, FP32|FP16
B.DATR all-zero (optional)
B.DIM LB0=sort_width (optional; zero or omission defaults to 32)
B.IOR Descending (optional; omission defaults to ascending)
B.IOT Local source and two new Local destinations, common PE_MASK, <last>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/sorting/TSORT.asl -->
```asl
pure func InstructionContractDataTypeLegal_TSORT(
    data_type: TileDataType) => boolean
begin
    return TileSortDataTypeSupported(data_type);
end;

pure func InstructionContractDefaultSortWidth_TSORT()
    => integer {1..64}
begin
    return 32;
end;

pure func InstructionContractDefaultDescending_TSORT() => boolean
begin
    return FALSE;
end;

readonly func InstructionContractOperandsLegal_TSORT(
    destination: TileIndex,
    destination_indices: TileIndex,
    source: TileIndex,
    sort_width: integer {1..64},
    descending: boolean) => boolean
begin
    return TileOperandsLegal_TSORT(
        destination,
        destination_indices,
        source,
        sort_width,
        descending);
end;

readonly func InstructionContractHandler_TSORT() => TileSemanticHandler
begin
    return TileHandler_TSORT;
end;

func InstructionContractExecute_TSORT(
    destination: TileIndex,
    destination_indices: TileIndex,
    source: TileIndex,
    sort_width: integer {1..64},
    descending: boolean)
begin
    assert InstructionContractOperandsLegal_TSORT(
        destination,
        destination_indices,
        source,
        sort_width,
        descending);
    TSORT(
        destination,
        destination_indices,
        source,
        sort_width,
        descending);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Omitted LB0 and encoded LB0 zero both select sort_width 32; values 1 through 64 select that exact group width.
- Omitted B.IOR selects ascending order. A present RegSrc0 must contain exactly zero for ascending or one for descending; every unused selector is zero.
- Omitted B.DATR selects the operation defaults. A present B.DATR is legal only when every encoded field is zero. Physical padding is Null.

## Legality

- TSORT uses the TEPL encoding carrier Mode 3 Function 12, canonically assembles with BSTART.SFU, and has no standalone opcode.
- The complete Local binding stream supplies exactly one persistent source and two distinct newly allocated destinations. Value source and value destination are FP32 or FP16; the index destination is U32. All use the same nonzero valid shape and row-major layout.
- LB1 and LB2 are absent. B.DATR is all zero. B.IOS is illegal. All B.IOT bindings use one PE_MASK.
- Every valid source element is defined and has a valid encoding. Signaling NaN is a legal sortable value and records numeric invalid status rather than causing a Tile legality fault.

## State effects

- Sort every independent row group in the selected ascending or descending direction.
- Publish reordered values and matching original within-group column indices. Signaling-NaN observation ORs NV into the sticky numeric status.
- The source persists. Rejection publishes no destination, descriptor, or numeric status effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Each valid row is split from column zero into consecutive groups of sort_width; the final short group never reads padding.
- Sort is stable. Numeric values precede NaNs in both directions; NaNs retain source order; signed zeros compare equal. Each U32 result is the original zero-based column offset within its group.
- Complete schema, control, type, descriptor, shape, capacity, mask, allocation, definedness, and encoding preflight precedes one source snapshot. Both destinations, Null padding, numeric status, and descriptors publish atomically.

## Exceptions

- Malformed or unterminated Local bindings, B.IOS, unsupported DataType, non-row-major layout, nonzero inapplicable B.DATR fields, LB1 or LB2, sort_width above 64, descending other than zero or one, undefined source data, or invalid source encoding raises Fault_TileLegality before effects.
- Unrepresentable destination shape, insufficient TSize, unavailable renamed destinations, or exhausted Tile capacity raises Fault_TileAllocation before effects.
- PE_MASK zero completes as a strict no-op before control reads, descriptor reads, allocation, faults, numeric status, or payload effects.

## Examples

- BSTART.SFU TSORT, FP32; B.DIM LB0=16; B.IOR a0; B.IOT T0, mask=1111, ->T0<TSize>; B.IOT mask=1111, <last>, ->T1<TSize>; BSTOP

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
