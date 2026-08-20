<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_BIAS.asl -->
# TGEMV_BIAS

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_BIAS.asl`

Multiply the matrix by the vector and add the bias Tile.

## Normative identity {#PTO-INST-TILE-TGEMV-BIAS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TGEMV_BIAS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGEMV_BIAS | CUBE |  | 17 |  | TGEMV_BIAS |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | left-vector |
| source1 | right-matrix |
| source2 | bias |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_BIAS.asl -->
```asl
readonly func InstructionContractOperation_TGEMV_BIAS()
    => TileOperation
begin
    return TileOperation_TGEMV_BIAS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TGEMV.BIAS AType
B.DATR BType, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one)
B.DIM LB0 M (optional, default 1; TGEMV permits only M=1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, B CUBE_N8 primary, 1xN Bias
B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations
B.IOT/B.IOR postprocess operands selected by B.FPATR
BSTOP or the next BSTART completion boundary
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_BIAS.asl -->
```asl
readonly func InstructionContractCubeFunction_TGEMV_BIAS()
    => integer {0..31}
begin
    return 17;
end;

readonly func InstructionContractSharedOperandsAllowed_TGEMV_BIAS()
    => boolean
begin
    return FALSE;
end;

readonly func InstructionContractOperandsLegal_TGEMV_BIAS(
    destination: TileIndex,
    left_vector: TileIndex,
    right_matrix: TileIndex,
    bias: TileIndex) => boolean
begin
    return TileOperandsLegal_TGEMV_BIAS(
        destination,
        left_vector,
        right_matrix,
        bias);
end;

readonly func InstructionContractHandler_TGEMV_BIAS()
    => TileSemanticHandler
begin
    return TileHandler_TGEMV_BIAS;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.
- Omitted LB0, LB1, and LB2 default M, N, and K independently to one; TGEMV fixes M to one.
- Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize. Bias remains an ordinary row-major 1xN accumulator-type Tile.

## Legality

- The carrier selects exactly CUBE Function 17 and TileOperation_TGEMV_BIAS.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize. Bias remains an ordinary row-major 1xN accumulator-type Tile.
- AType and BType must be supported ordinary Matrix types from one numeric class. Bias is one Local row-major 1xN accumulator-type source. M is fixed to one and every Shared binding is illegal.
- Every executing Local or Shared binding uses PE_MASK=1111; mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits only BType, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.

## State effects

- Multiply the matrix by the vector and add the bias Tile.
- After complete preflight, execute TGEMV_BIAS with the operand bindings listed above; destination definedness changes only as specified by that handler.
- For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; ordinary Bias, MX scales, and enabled reduction auxiliaries keep their operation-owned layouts.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, field, type, dimension, descriptor, shape, capacity, readiness, alias, and allocation preflight precedes every source snapshot and destination effect.
- D and every enabled reduction output publish as one atomic group; rejection publishes none and successful sources persist.

## Exceptions

- A reserved DataType or fixed-bit mismatch raises Fault_IllegalInstruction before block state changes.
- Missing, duplicate, or non-Matrix B.FPATR use raises Fault_BundleControl before allocation or payload effects.
- Illegal types, dimensions, masks, binding streams, descriptors, shapes, capacities, aliases, readiness, or postprocess values raise Fault_TileLegality before source snapshots and effects.

## Examples

- BSTART.TGEMV.BIAS AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one); B.DIM LB0 M (optional, default 1; TGEMV permits only M=1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, B CUBE_N8 primary, 1xN Bias; B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
