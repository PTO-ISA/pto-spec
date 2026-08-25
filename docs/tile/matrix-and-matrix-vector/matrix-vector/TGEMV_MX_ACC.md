<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_MX_ACC.asl -->
# TGEMV_MX_ACC

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_MX_ACC.asl`

Multiply the scaled matrix and vector and accumulate into the supplied Tile.

## Normative identity {#PTO-INST-TILE-TGEMV-MX-ACC}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tgemv-mx-acc-purpose role=purpose -->
## Purpose

`TGEMV_MX_ACC` multiplies the scaled matrix and vector and accumulates into the supplied Tile.

<!-- PTO-READER-BLOCK: tile-tgemv-mx-acc-mechanism role=mechanism -->
## Execution mechanism

The ASL DOC contract selects `TileHandler_TGEMV_MX_ACC` through the instruction's selector-encoded block carrier.

Matrix schema, M/K/N dimensions, operand layouts, DataTypes, descriptor shapes, aliases, masks, capacity, and every required Bias, accumulator, or E8M0 scale Tile are preflighted before source snapshots.

<!-- PTO-READER-BLOCK: tile-tgemv-mx-acc-inputs-outputs role=inputs-outputs -->
## Operands and descriptors

`destination0` is the destination; `source0` is the accumulator; `source1` is the left-vector; `source2` is the row-scale; `source3` is the right-matrix; `source4` is the column-scale.

Sources remain persistent unless the current contract explicitly names a consumed or replaced state; destination descriptors are published only after complete preflight.

<!-- PTO-READER-BLOCK: tile-tgemv-mx-acc-effects role=effects -->
## Publication and ordering

All persistent inputs are snapshotted before computation; the destination and any enabled auxiliary output publish as one atomic group.

The destination uses this operation's CUBE layout and final output type; this mnemonic snapshots its accumulator input before computation and preserves that input after success or rejection.

<!-- PTO-READER-BLOCK: tile-tgemv-mx-acc-constraints role=constraints -->
## Legality, padding, and faults

Malformed bindings, unsupported types or layouts, invalid shapes, undefined consumed elements, illegal attributes, or insufficient destination capacity are rejected before source snapshots or publication.

Allocation failure raises the owner-defined Tile allocation fault; other rejected schema or value conditions raise the owner-defined legality, bundle-control, or memory fault without partial effects.

<!-- PTO-READER-BLOCK: tile-tgemv-mx-acc-example role=example -->
## Non-normative contract sketch

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

Read `BSTART.TGEMVMX.ACC AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M (optional, default 1; TGEMV permits only M=1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale; B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary` as a non-normative binding walkthrough, then use the generated contract below for exact dimensions, attributes, and fault behavior.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TGEMV_MX_ACC <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGEMV_MX_ACC | CUBE |  | 22 |  | TGEMV_MX_ACC |

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
| source2 | row-scale |
| source3 | right-matrix |
| source4 | column-scale |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_MX_ACC.asl -->
```asl
readonly func InstructionContractOperation_TGEMV_MX_ACC()
    => TileOperation
begin
    return TileOperation_TGEMV_MX_ACC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TGEMVMX.ACC AType
B.DATR BType, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one)
B.DIM LB0 M (optional, default 1; TGEMV permits only M=1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale
B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations
B.IOT/B.IOR postprocess operands selected by B.FPATR
BSTOP or the next BSTART completion boundary
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_MX_ACC.asl -->
```asl
readonly func InstructionContractCubeFunction_TGEMV_MX_ACC()
    => integer {0..31}
begin
    return 22;
end;

readonly func InstructionContractSharedOperandsAllowed_TGEMV_MX_ACC()
    => boolean
begin
    return FALSE;
end;

readonly func InstructionContractOperandsLegal_TGEMV_MX_ACC(
    destination: TileIndex,
    accumulator: TileIndex,
    left_vector: TileIndex,
    row_scale: TileIndex,
    right_matrix: TileIndex,
    column_scale: TileIndex) => boolean
begin
    return TileOperandsLegal_TGEMV_MX_ACC(
        destination,
        accumulator,
        left_vector,
        row_scale,
        right_matrix,
        column_scale);
end;

readonly func InstructionContractHandler_TGEMV_MX_ACC()
    => TileSemanticHandler
begin
    return TileHandler_TGEMV_MX_ACC;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.
- Omitted LB0, LB1, and LB2 default M, N, and K independently to one; TGEMV fixes M to one.
- Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize. Required E8M0 scales remain ordinary row-major Tiles.
- TransA=0 and TransB=0 select no logical transpose. TGEMV requires both controls to remain zero.
- C and D are both mandatory. In decoded blocks C's six-bit relative selector must differ from zero-extended DstTile before rename; direct Tile calls require destination TileIndex to differ from accumulator TileIndex.

## Legality

- The carrier selects exactly CUBE Function 22 and TileOperation_TGEMV_MX_ACC.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize. Required E8M0 scales remain ordinary row-major Tiles.
- C and D are both mandatory. In decoded blocks C's six-bit relative selector must differ from zero-extended DstTile before rename; direct Tile calls require destination TileIndex to differ from accumulator TileIndex.
- TGEMV is Local-only: TransA and TransB are zero and every effective Shared binding rejects before effects.
- Each matrix side independently requires an E8M0 scale exactly when its MX input type is not FP16 or BF16. C is one explicit Local MxN accumulator source and D is a distinct newly published destination; C's encoded relative selector and D's zero-extended DstTile hand must differ before rename. M is fixed to one and every Shared binding is illegal.
- Every common nonzero four-bit PE_MASK is legal; all four PEs complete cooperative Shared readiness while only selected PEs allocate and publish. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits only BType, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.

## State effects

- Multiply the scaled matrix and vector and accumulate into the supplied Tile.
- After complete preflight, execute TGEMV_MX_ACC with the operand bindings listed above; destination definedness changes only as specified by that handler.
- For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; ordinary Bias, MX scales, and enabled reduction auxiliaries keep their operation-owned layouts.
- C is snapshotted before multiplication and remains descriptor-and-payload unchanged after success or rejection.

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

- BSTART.TGEMVMX.ACC AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M (optional, default 1; TGEMV permits only M=1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale; B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary
