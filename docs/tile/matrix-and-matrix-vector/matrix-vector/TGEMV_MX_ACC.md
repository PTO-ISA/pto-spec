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
## What TGEMV_MX_ACC does

`TGEMV_MX_ACC` is the matrix-vector form of the CUBE matrix product. M is fixed to 1, so the left operand A is one row of K elements, the right operand B is a matrix with K rows and N columns, and the destination D is one row of N elements.

The product is added to an explicit accumulator Tile C of the same shape, and C itself is not changed. Each input may use a narrow MX format; such a side carries a per-group scale Tile.

Design point: `TGEMV_MX_ACC` is selected by `BSTART.TGEMVMX.ACC` (CUBE Function 22) and has no standalone opcode. All twelve CUBE matrix instructions share one bundle handler; the function number selects whether a bias, an accumulator, MX scales, the M = 1 and Local-only rules, and CScale apply. The [matrix function table](../../model/legality/matrix-functions.md) lists every form.

<!-- PTO-READER-BLOCK: tile-tgemv-mx-acc-mechanism role=mechanism -->
## Element arithmetic

For each result row and column, the sum starts at the C element at the same position. The inner index then runs from 0 to K-1 in increasing order and adds one product per step.

The accumulator type is always FP32. When neither side has a scale, which means both inputs are FP16 or BF16, and the running sum and both elements are finite, each step rounds the product to FP32 and then rounds the sum to FP32. This path always uses RNE without saturation; the `B.DATR` `RMode` and `Sat` fields do not change it.

In every other case, each input whose side has a scale is first multiplied by its scale carrier with `MultiplyWord`, and the product of the two results is added to the raw accumulator carrier with 64-bit wrapping arithmetic. This is raw carrier arithmetic, not a decoded floating-point computation, and it records no flags.

Design point: the inner loop walks K in one fixed order, and the FP32 path rounds twice per step, so the result is not a fused multiply-add and the model gives one bit-exact result for each input. Accumulation discards flags; post-processing is the only step that records numeric status flags.

Exactly one `B.FPATR` then selects post-processing. With all fields zero, D keeps the accumulator type. A nonzero `PreQuantMode` converts every valid element to that mode's output type, `ReluMode` selects ReLU or a leaky slope for negative values, and `RowMaxEn` and `GroupMaxEn` add RowMaxOut and GroupMaxOut destinations computed from the final D values. [Matrix post-processing](../../model/execution/matrix-postprocess.md) and [post-processing commit](../../model/execution/postprocess.md) give the exact rules.

`CCTRL` is the `PadValueOrByteId` field of `B.DATR`, read as `00` when `B.DATR` is omitted. With bit 0 set, D is published as the raw accumulator-type result, and `PreQuantMode`, `ReluMode`, `GroupNCode`, `RowMaxEn`, `GroupMaxEn`, and `MaxAbsEn` must all be zero. Bit 1 asks the implementation to prefetch or reuse C; it is a non-binding hint and cannot change results.

<!-- PTO-READER-BLOCK: tile-tgemv-mx-acc-inputs-outputs role=inputs-outputs -->
## Operand roles and layouts

The Local mathematical sources are bound in this order:

- `source0` is the accumulator C: valid shape [M, N], the accumulator type, and the same M layout as D. Its capacity must equal D's unless `PreQuantMode` is nonzero. Mnemonic clause `PTO-TGEMV-MX-ACC-CONTRACT-001` and dispatch clause `PTO-CUBE-ACCUMULATOR-OUTPUT-001` require its encoded relative selector to differ from D's zero-extended `DstTile` hand before rename; the executable check differs as explained below.
- `source1` is the left vector A: valid shape [1, K], type AType, and layout `CUBE_M16` or `CUBE_M32`.
- `source2` is A's scale, bound only when AType is not FP16 or BF16: valid shape [1, G] in `CUBE_M32`, where G is K divided by the group size, rounded up. The carrier is `E8M0` with groups of 32, or `U32` with groups of 64 for HiF4X2.
- `source3` is the right matrix B: valid shape [K, N], type BType, and layout `CUBE_N8`.
- `source4` is B's scale, bound only when BType is not FP16 or BF16: valid shape [N, G] in `CUBE_M32`, with the same carrier rule. One `CUBE_M32` block holds at most 32 rows, so a Local B scale requires N at most 32.

When a side needs no scale, its scale source is not bound, and the later sources follow directly in the same order. Post-processing sources, such as RowMaxIn and parameter Tiles, come after all of these.

`destination0` is D: newly allocated, valid shape [1, N], the same M layout as A, and the accumulator type, or the output type of a nonzero `PreQuantMode`.

AType is the `BSTART` data type. BType is the `B.DATR` `DataType`, and equals AType when `B.DATR` is omitted. `B.DIM` LB0, LB1, and LB2 carry M, N, and K, and each defaults to 1 when omitted. The M = 1 rule is mandatory: any other LB0 value raises `Fault_TileLegality`.

AType and BType are chosen independently from FP16, BF16, E4M3, E5M2, E2M1X2, E1M2X2, and HiF4X2.

Design point: a side carries a scale exactly when it needs one. FP16 and BF16 need none, so a form with an FP16 left side and an E4M3 right side binds only the right scale, and a form with two FP16 sides takes the FP32 rounding path described above.

Design point: mnemonic clause `PTO-TGEMV-MX-ACC-CONTRACT-001` and dispatch clause `PTO-CUBE-ACCUMULATOR-OUTPUT-001` require C's encoded relative selector to differ from D's zero-extended `DstTile` hand before rename. The current executable model resolves C first, then compares its physical `TileIndex` with D's destination hand (`DstTile MOD 4`). Issue #367 tracks this conflict. C is read into a private copy before D is written and stays unchanged after success or rejection, but a later bundle is executable only when the resolved C index passes the current comparison.

`TGEMV_MX_ACC` is Local only. Every Shared binding and a nonzero `TransA` or `TransB` is rejected, and any common nonzero `PE_MASK` is legal.

<!-- PTO-READER-BLOCK: tile-tgemv-mx-acc-effects role=effects -->
## Publication and ordering

Complete preflight comes first: types, bindings, dimensions, masks, Local descriptors, aliases, the M layout, and post-processing sources. Only then is the destination group allocated and are the sources read. [CUBE TMATMUL dispatch](../../../block/model/dispatch/cube-tmatmul.md) lists the stages.

D and any enabled RowMaxOut and GroupMaxOut publish as one group. D is defined only in its valid region; its padding stays undefined, because no `PadValue` is applied. A rejected bundle publishes nothing, and every source persists unchanged.

Design point: allocation happens after every rule is checked and before the first source snapshot. A legality fault therefore leaves no allocated destination, and a fault after allocation rolls the destination group back.

The operation has no global-memory effect. Post-processing is the only source of numeric status; it ORs the flags of all its outputs and records them at commit.

<!-- PTO-READER-BLOCK: tile-tgemv-mx-acc-constraints role=constraints -->
## Legality and fault boundary

- After command-level encoding and size-code checks pass, `PE_MASK=0000` on every binding skips matrix-handler descriptor reads, faults, and allocation. Earlier command checks still apply.
- A missing `B.FPATR` raises `Fault_BundleControl`, and an undecodable CUBE selector raises `Fault_IllegalInstruction`.
- An illegal type pair, source or destination count, `B.DATR` field, `CCTRL` use, dimension, mask, descriptor, alias, layout, or post-processing source raises `Fault_TileLegality` before allocation.
- A full destination hand, a destination size too small for the CUBE storage of D, RowMaxOut, or GroupMaxOut, or a destination group that exceeds the remaining capacity, raises `Fault_TileAllocation`.
- Setting `CScaleEn` raises `Fault_TileLegality`, because only `TMATMUL_ACC` and `TMATMUL_MX_ACC` accept CScale.

Design point: M, N, and K are compared with the valid shapes of A, B, and D, not with a capacity-derived row count. The M layout only bounds M by 16 or 32, so the dimensions stay independent of the destination TSize.

<!-- PTO-READER-BLOCK: tile-tgemv-mx-acc-example role=example -->
## Non-normative worked example

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

With BF16 on both sides, no scale is bound, and the sources are C, A, and B. Take N = 1, K = 2, C = 1.5, a left vector 2.0, 3.0, and a right source column 0.5, 0.25. D is 1.5 + 1.0 + 0.75 = 3.25, computed with RNE.

With E4M3 on both sides and K = 64, the sources become C, A, A's scale [1, 2], B, and B's scale [16, 2].

The two non-normative macro sketches below are conditional on queue resolution mapping C to a physical `TileIndex` different from the destination hand, which is what the current executable model actually checks:

```text
TGEMV_MX_ACC <M=1, N=16, K=16, BF16>, T#2, T#1, T#3, ->T<1KB>
TGEMV_MX_ACC <M=1, N=16, K=64, E4M3>, T#3, T#1, T#2, T#4, T#5, ->T<1KB>
```
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
B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType)
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
- Omitted CCTRL selects 00: final D output and no transparent-cache hint.

## Legality

- The carrier selects exactly CUBE Function 22 and TileOperation_TGEMV_MX_ACC.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize. Required E8M0 scales remain ordinary row-major Tiles.
- C and D are both mandatory. In decoded blocks C's six-bit relative selector must differ from zero-extended DstTile before rename; direct Tile calls require destination TileIndex to differ from accumulator TileIndex.
- TGEMV is Local-only: TransA and TransB are zero and every effective Shared binding rejects before effects.
- Each matrix side independently requires an E8M0 scale exactly when its MX input type is not FP16 or BF16. C is one explicit Local MxN accumulator source and D is a distinct newly published destination; C's encoded relative selector and D's zero-extended DstTile hand must differ before rename. M is fixed to one and every Shared binding is illegal.
- Every common nonzero four-bit PE_MASK is legal; all four PEs complete cooperative Shared readiness while only selected PEs allocate and publish. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits BType, matrix CCTRL via PadValueOrByteId, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.
- For init=1 forms CCTRL[1] must be zero. CCTRL[0]=1 selects raw accumulator-type D and forbids final-output post-processing and auxiliary outputs except legal CScale; CCTRL[1] is an ACC-only non-binding explicit-C cache-use or prefetch hint. Every successful form allocates and publishes D.

## State effects

- Multiply the scaled matrix and vector and accumulate into the supplied Tile.
- After complete preflight, execute TGEMV_MX_ACC with the operand bindings listed above; destination definedness changes only as specified by that handler.
- For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; Bias uses Local CUBE_N8; RowMaxIn/Out and GroupMaxOut use the resolved M layout; vector quant/PReLU parameters use Local CUBE_N8/U64; MX scales keep their operation-owned layouts.
- C is snapshotted before multiplication and remains descriptor-and-payload unchanged after success or rejection.
- Always publish D; CCTRL[0]=1 publishes raw accumulator-type D and may hint cache replacement, while ACC CCTRL[1]=1 may hint cache use or prefetch of explicit C. Hint handling is not architecturally observable.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, field, type, dimension, descriptor, shape, capacity, readiness, alias, and allocation preflight precedes every source snapshot and destination effect.
- D and every enabled reduction output publish as one atomic group; rejection publishes none and successful sources persist.
- Transparent-cache hints occur only after complete preflight and cannot alter source snapshots, D allocation or publication, faults, or numeric status.

## Exceptions

- A reserved DataType or fixed-bit mismatch raises Fault_IllegalInstruction before block state changes.
- Missing, duplicate, or non-Matrix B.FPATR use raises Fault_BundleControl before allocation or payload effects.
- Illegal types, dimensions, masks, binding streams, descriptors, shapes, capacities, aliases, readiness, or postprocess values raise Fault_TileLegality before source snapshots and effects.

## Examples

- BSTART.TGEMVMX.ACC AType; B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M (optional, default 1; TGEMV permits only M=1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale; B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary
