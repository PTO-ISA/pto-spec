<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX_BIAS.asl -->
# TMATMUL_MX_BIAS

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX_BIAS.asl`

Multiply scaled matrices and add the bias Tile.

## Normative identity {#PTO-INST-TILE-TMATMUL-MX-BIAS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tmatmul-mx-bias-purpose role=purpose -->
## Purpose

`TMATMUL_MX_BIAS` multiplies scaled matrices and adds the Bias Tile.

<!-- PTO-READER-BLOCK: tile-tmatmul-mx-bias-mechanism role=mechanism -->
## Execution mechanism

The ASL DOC contract selects `TileHandler_TMATMUL_MX_BIAS` through the instruction's selector-encoded block carrier.

Matrix schema, M/K/N dimensions, operand layouts, DataTypes, descriptor shapes, aliases, masks, capacity, and every required Bias, accumulator, or E8M0 scale Tile are preflighted before source snapshots.

<!-- PTO-READER-BLOCK: tile-tmatmul-mx-bias-inputs-outputs role=inputs-outputs -->
## Operands and descriptors

`destination0` is the destination; `source0` is the left; `source1` is the row-scale; `source2` is the right; `source3` is the column-scale; `source4` is the bias.

Sources remain persistent unless the current contract explicitly names a consumed or replaced state; destination descriptors are published only after complete preflight.

<!-- PTO-READER-BLOCK: tile-tmatmul-mx-bias-effects role=effects -->
## Publication and ordering

All persistent inputs are snapshotted before computation; the destination and any enabled auxiliary output publish as one atomic group.

The destination uses this operation's CUBE layout and final output type; this mnemonic preserves its Bias input unchanged.

<!-- PTO-READER-BLOCK: tile-tmatmul-mx-bias-constraints role=constraints -->
## Legality, padding, and faults

Malformed bindings, unsupported types or layouts, invalid shapes, undefined consumed elements, illegal attributes, or insufficient destination capacity are rejected before source snapshots or publication.

Allocation failure raises the owner-defined Tile allocation fault; other rejected schema or value conditions raise the owner-defined legality, bundle-control, or memory fault without partial effects.

<!-- PTO-READER-BLOCK: tile-tmatmul-mx-bias-example role=example -->
## Non-normative contract sketch

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

Read `BSTART.TMATMULMX.BIAS AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M or cooperative group_M (optional, default 1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111); B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale, 1xN Bias; B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary` as a non-normative binding walkthrough, then use the generated contract below for exact dimensions, attributes, and fault behavior.
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TMATMUL_MX_BIAS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMATMUL_MX_BIAS | CUBE |  | 5 |  | TMATMUL_MX_BIAS |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | left |
| source1 | row-scale |
| source2 | right |
| source3 | column-scale |
| source4 | bias |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX_BIAS.asl -->
```asl
readonly func InstructionContractOperation_TMATMUL_MX_BIAS()
    => TileOperation
begin
    return TileOperation_TMATMUL_MX_BIAS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TMATMULMX.BIAS AType
B.DATR BType, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one)
B.DIM LB0 M or cooperative group_M (optional, default 1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111)
B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale, 1xN Bias
B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations
B.IOT/B.IOR postprocess operands selected by B.FPATR
BSTOP or the next BSTART completion boundary
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX_BIAS.asl -->
```asl
readonly func InstructionContractCubeFunction_TMATMUL_MX_BIAS()
    => integer {0..31}
begin
    return 5;
end;

readonly func InstructionContractSharedOperandsAllowed_TMATMUL_MX_BIAS()
    => boolean
begin
    return TRUE;
end;

readonly func InstructionContractOperandsLegal_TMATMUL_MX_BIAS(
    destination: TileIndex,
    left: TileIndex,
    row_scale: TileIndex,
    right: TileIndex,
    column_scale: TileIndex,
    bias: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL_MX_BIAS(
        destination,
        left,
        row_scale,
        right,
        column_scale,
        bias);
end;

readonly func InstructionContractHandler_TMATMUL_MX_BIAS()
    => TileSemanticHandler
begin
    return TileHandler_TMATMUL_MX_BIAS;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.
- Omitted LB0 defaults Local M or cooperative group_M to one; omitted LB1 and LB2 default N and K to one.
- Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize. Bias remains an ordinary row-major 1xN accumulator-type Tile. Each side uses group-32 E8M0 or HiF4X2 group-64 U32 scale; Local scales use CUBE_M32 and Shared scales remain ordinary Tiles.
- TransA=0 and TransB=0 select no logical transpose. Each nonzero control is legal only when the corresponding primary is Shared.

## Legality

- The carrier selects exactly CUBE Function 5 and TileOperation_TMATMUL_MX_BIAS.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize. Bias remains an ordinary row-major 1xN accumulator-type Tile. Each side uses group-32 E8M0 or HiF4X2 group-64 U32 scale; Local scales use CUBE_M32 and Shared scales remain ordinary Tiles.
- A Shared primary must satisfy hardware-maintained whole-parent readiness and publication before payload access; fixed-quarter allocation or initialization masks are not a prerequisite. Any cooperative Local-A/Shared-B or Shared-A/Shared-B TMATMUL interprets LB0 as Core-total group_M in 1..128; Shared A has shape group_MxK, Shared B has shape KxN, and PE i uses valid_M=clamp(group_M-i*M_per_PE,0,M_per_PE) with M_per_PE 16 for group_M<=64 and 32 for group_M>=65. TransA and TransB apply only to their corresponding Shared primary. Right-only Shared inherits Local A layout; all-Shared ACC inherits C layout; all-Shared non-ACC selects M16 through M=16 and M32 through M=32.
- Each non-FP16/BF16 side requires its assigned scale: group-32 E8M0 for MX FP8/FP4 or group-64 U32 for HiF4X2. Bias is one Local row-major 1xN accumulator-type source. Published Shared operands may replace the right group or both matrix groups; supplementary operands and destinations remain Local.
- Every cooperative nonzero PE_MASK must be 1111; all four PEs complete Shared readiness, while zero-row PEs suppress every compute-only Local resolution and effect. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits only BType, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.

## State effects

- Multiply scaled matrices and add the bias Tile.
- After complete preflight, execute TMATMUL_MX_BIAS with the operand bindings listed above; destination definedness changes only as specified by that handler.
- For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; ordinary Bias, MX scales, and enabled reduction auxiliaries keep their operation-owned layouts.
- Successful Shared primary reads leave every Shared descriptor, mask, publication state, payload, and lifetime unchanged.

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

- BSTART.TMATMULMX.BIAS AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M or cooperative group_M (optional, default 1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111); B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale, 1xN Bias; B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary
