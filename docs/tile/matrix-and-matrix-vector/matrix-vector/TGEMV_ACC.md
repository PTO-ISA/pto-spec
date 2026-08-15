<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_ACC.asl -->
# TGEMV_ACC

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_ACC.asl`

Multiply the matrix by the vector and accumulate into the supplied Tile.

## Normative identity {#PTO-INST-TILE-TGEMV-ACC}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TGEMV_ACC <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGEMV_ACC | CUBE |  | 18 |  | TGEMV_ACC |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | accumulator |
| source1 | left-vector |
| source2 | right-matrix |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_ACC.asl -->
```asl
readonly func InstructionContractOperation_TGEMV_ACC()
    => TileOperation
begin
    return TileOperation_TGEMV_ACC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TGEMV.ACC AType
B.DATR BType, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one)
B.DIM LB0 M (optional, default 1; TGEMV permits only M=1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOT ordered Local mathematical sources: C accumulator, A matrix, B matrix
B.IOT D, optional RowMaxOut, optional GroupMaxOut destinations
B.IOT/B.IOR postprocess operands selected by B.FPATR
BSTOP or the next BSTART completion boundary
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_ACC.asl -->
```asl
readonly func InstructionContractCubeFunction_TGEMV_ACC()
    => integer {0..31}
begin
    return 18;
end;

readonly func InstructionContractSharedOperandsAllowed_TGEMV_ACC()
    => boolean
begin
    return FALSE;
end;

readonly func InstructionContractOperandsLegal_TGEMV_ACC(
    destination: TileIndex,
    accumulator: TileIndex,
    left_vector: TileIndex,
    right_matrix: TileIndex) => boolean
begin
    return TileOperandsLegal_TGEMV_ACC(
        destination,
        accumulator,
        left_vector,
        right_matrix);
end;

readonly func InstructionContractHandler_TGEMV_ACC()
    => TileSemanticHandler
begin
    return TileHandler_TGEMV_ACC;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.
- Omitted LB0, LB1, and LB2 default M, N, and K independently to one; TGEMV fixes M to one.
- Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.

## Legality

- The carrier selects exactly CUBE Function 18 and TileOperation_TGEMV_ACC.
- AType and BType must be supported ordinary Matrix types from one numeric class. C is one explicit Local MxN accumulator source and D is a newly published destination; C and D may use one architectural Tile name. M is fixed to one and every Shared binding is illegal.
- Every executing Local or Shared binding uses PE_MASK=1111; mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits only BType, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.

## State effects

- Multiply the matrix by the vector and accumulate into the supplied Tile.
- After complete preflight, execute TGEMV_ACC with the operand bindings listed above; destination definedness changes only as specified by that handler.

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

- BSTART.TGEMV.ACC AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one); B.DIM LB0 M (optional, default 1; TGEMV permits only M=1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOT ordered Local mathematical sources: C accumulator, A matrix, B matrix; B.IOT D, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
