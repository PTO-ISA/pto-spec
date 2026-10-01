<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_ACC.asl -->
# TMATMUL_ACC

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_ACC.asl`

Multiply matrices and accumulate into the supplied accumulator Tile.

## Normative identity {#PTO-INST-TILE-TMATMUL-ACC}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tmatmul-acc-purpose role=purpose -->
## What TMATMUL_ACC does

`TMATMUL_ACC` multiplies a left matrix A with M rows and K columns by a right matrix B with K rows and N columns. It publishes the M x N result D in a newly allocated Local CUBE Tile.

The product is added to an explicit accumulator Tile C of the same shape, and C itself is not changed.

Design point: `TMATMUL_ACC` is selected by `BSTART.TMATMUL.ACC` (CUBE Function 2) and has no standalone opcode. All twelve CUBE matrix instructions share one bundle handler; the function number selects whether a bias, an accumulator, MX scales, the M = 1 and Local-only rules, and CScale apply. The [matrix function table](../../model/legality/matrix-functions.md) lists every form.

<!-- PTO-READER-BLOCK: tile-tmatmul-acc-mechanism role=mechanism -->
## Element arithmetic

For each result row and column, the sum starts at the C element at the same position. When `CScaleEn` is set, that C value is first halved once per step of the row's U8 CScale exponent and rounded to FP32 with RNE; NaN, infinity, and zeros pass through unchanged. The inner index then runs from 0 to K-1 in increasing order and adds one product per step.

The accumulator type is FP32 for floating inputs, S32 for signed integer inputs, and U32 for unsigned integer inputs. When the accumulator is FP32, both inputs are FP32, TF32, HF32, FP16, or BF16, and the running sum and both elements are finite, each step rounds the product to FP32 and then rounds the sum to FP32. It uses the `RMode` and `Sat` of `B.DATR`, or RNE without saturation when `B.DATR` is omitted.

In every other case, including integer inputs, 8-bit and 4-bit floating inputs, and NaN or infinite values, the step adds `MultiplyWord(left, right)` to the raw accumulator carrier with 64-bit wrapping arithmetic. That path is exact bit arithmetic, not IEEE arithmetic, and it records no flags.

Design point: the inner loop walks K in one fixed order, and the FP32 path rounds twice per step, so the result is not a fused multiply-add and the model gives one bit-exact result for each input. Accumulation discards flags; CScale and post-processing are the only steps that record numeric status flags.

Exactly one `B.FPATR` then selects post-processing. With all fields zero, D keeps the accumulator type. A nonzero `PreQuantMode` converts every valid element to that mode's output type, `ReluMode` selects ReLU or a leaky slope for negative values, and `RowMaxEn` and `GroupMaxEn` add RowMaxOut and GroupMaxOut destinations computed from the final D values. [Matrix post-processing](../../model/execution/matrix-postprocess.md) and [post-processing commit](../../model/execution/postprocess.md) give the exact rules.

`CCTRL` is the `PadValueOrByteId` field of `B.DATR`, read as `00` when `B.DATR` is omitted. With bit 0 set, D is published as the raw accumulator-type result, and `PreQuantMode`, `ReluMode`, `GroupNCode`, `RowMaxEn`, `GroupMaxEn`, and `MaxAbsEn` must all be zero. Bit 1 asks the implementation to prefetch or reuse C; it is a non-binding hint and cannot change results.

<!-- PTO-READER-BLOCK: tile-tmatmul-acc-inputs-outputs role=inputs-outputs -->
## Operand roles and layouts

The Local mathematical sources are bound in this order:

- `source0` is the accumulator C: valid shape [M, N], the accumulator type, and the same M layout as D. Its capacity must equal D's unless `PreQuantMode` is nonzero. Mnemonic clause `PTO-TMATMUL-ACC-CONTRACT-001` permits C and D to use one architectural Tile name, while dispatch clause `PTO-CUBE-ACCUMULATOR-OUTPUT-001` requires C's encoded relative selector to differ from D's zero-extended `DstTile` hand before rename. The executable check differs from both descriptions as explained below.
- `source1` is the left matrix A: valid shape [M, K], type AType, and layout `CUBE_M16` (M at most 16) or `CUBE_M32` (M at most 32).
- `source2` is the right matrix B: valid shape [K, N], type BType, and layout `CUBE_N8`.
- When `CScaleEn` is set, one more source follows: a `U8` `CUBE_M32` Tile with valid shape [M, 1] that holds one exponent per row. CScale requires an FP32 accumulator.

Post-processing sources, such as RowMaxIn and parameter Tiles, come after all of these.

`destination0` is D: newly allocated, valid shape [M, N], the resolved M layout (A's layout when A is Local), and the accumulator type, or the output type of a nonzero `PreQuantMode`.

AType is the `BSTART` data type. BType is the `B.DATR` `DataType`, and equals AType when `B.DATR` is omitted. `B.DIM` LB0, LB1, and LB2 carry M, N, and K, and each defaults to 1 when omitted.

AType and BType must both be ordinary Matrix types of one numeric class: both floating, both signed integer, or both unsigned integer. HiF4X2 is not an ordinary Matrix type; it is accepted only by the MX forms.

Design point: the mnemonic NDF allows C and D to use one architectural Tile name, while dispatch clause `PTO-CUBE-ACCUMULATOR-OUTPUT-001` requires their encoded selector and destination hand to differ before rename. The current executable model resolves C first, then compares its physical `TileIndex` with D's destination hand (`DstTile MOD 4`). Issue #367 tracks this three-way source conflict. C is read into a private copy before D is written and stays unchanged after success or rejection, but an accumulating chain is executable only when the resolved C index passes the current comparison.

Cooperative execution: `B.IOS` may replace the complete right group (B), or both groups, with published Shared Tiles. LB0 then holds the Core-total group M, from 1 to 128, N and K must be powers of two, and every binding needs `PE_MASK` 1111. Each PE takes 16 rows when group M is at most 64 and 32 rows otherwise; PE i starts at row i times that count, and a PE with no rows allocates nothing. [Shared CUBE matrix](../../../block/model/dispatch/shared-cube-matrix.md) defines the split.

A Shared A is stored [group M, K], or [K, group M] with `TransA`. A Shared B is stored [N, K], or [K, N] with `TransB`. Each transpose control is legal only for a Shared primary. C, CScale, and every destination stay Local.

<!-- PTO-READER-BLOCK: tile-tmatmul-acc-effects role=effects -->
## Publication and ordering

Complete preflight comes first: types, bindings, dimensions, masks, Shared readiness and schemas, Local descriptors, aliases, the M layout, and post-processing sources. Only then is the destination group allocated and are the sources read. [CUBE TMATMUL dispatch](../../../block/model/dispatch/cube-tmatmul.md) lists the stages.

D and any enabled RowMaxOut and GroupMaxOut publish as one group. D is defined only in its valid region; its padding stays undefined, because no `PadValue` is applied. A rejected bundle publishes nothing, and every source persists unchanged.

Design point: allocation happens after every rule is checked and before the first source snapshot. A legality fault therefore leaves no allocated destination, and a fault after allocation rolls the destination group back.

The operation has no global-memory effect. CScale records the flags of each scaled C element as it computes them. Post-processing ORs the flags of all its outputs and records them at commit.

A cooperative bundle waits, without a fault, until every Shared source is whole-ready and published. Successful Shared reads leave every Shared descriptor, payload, and lifetime unchanged.

<!-- PTO-READER-BLOCK: tile-tmatmul-acc-constraints role=constraints -->
## Legality and fault boundary

- After command-level encoding and size-code checks pass, `PE_MASK=0000` on every binding skips matrix-handler descriptor reads, faults, and allocation. Earlier command checks still apply.
- A missing `B.FPATR` raises `Fault_BundleControl`, and an undecodable CUBE selector raises `Fault_IllegalInstruction`.
- An illegal type pair, source or destination count, `B.DATR` field, `CCTRL` use, dimension, mask, descriptor, alias, layout, or post-processing source raises `Fault_TileLegality` before allocation.
- A full destination hand, a destination size too small for the CUBE storage of D, RowMaxOut, or GroupMaxOut, or a destination group that exceeds the remaining capacity, raises `Fault_TileAllocation`.
- `CScaleEn` is legal here because CScale is accepted only by Function 2 (`TMATMUL_ACC`) and Function 6 (`TMATMUL_MX_ACC`); `TGEMV_ACC` rejects it. It still requires an FP32 accumulator, and the CScale source must not share an index with any destination hand.

Design point: M, N, and K are compared with the valid shapes of A, B, and D, not with a capacity-derived row count. The M layout only bounds M by 16 or 32, so the dimensions stay independent of the destination TSize.

<!-- PTO-READER-BLOCK: tile-tmatmul-acc-example role=example -->
## Non-normative worked example

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

Take FP16 inputs and an FP32 accumulator with M = 1, N = 1, and K = 2. The accumulator element is 10.0, the left source row is 1.0, 2.0, and the right source column is 3.0, 4.0.

The sum starts at 10.0, adds 1.0 x 3.0 = 3.0 to reach 13.0, and adds 2.0 x 4.0 = 8.0 to reach 21.0. With CScale enabled and exponent 1, the start value is 10.0 / 2 = 5.0 and D is 16.0. C still holds 10.0 afterwards.

In the non-normative macro sketches below, `T#2` is C, `T#1` is A, `T#3` is B, and `T#4` is the CScale Tile in the second line. They are conditional on queue resolution mapping C to a physical `TileIndex` different from the destination hand, which is what the current executable model actually checks:

```text
TMATMUL_ACC <M=16, N=16, K=16, FP16>, T#2, T#1, T#3, ->T<1KB>
TMATMUL_ACC <M=16, N=16, K=16, FP16, CScale>, T#2, T#1, T#3, T#4, ->T<1KB>
```
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TMATMUL_ACC <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMATMUL_ACC | CUBE |  | 2 |  | TMATMUL_ACC |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | accumulator |
| source1 | left |
| source2 | right |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_ACC.asl -->
```asl
readonly func InstructionContractOperation_TMATMUL_ACC()
    => TileOperation
begin
    return TileOperation_TMATMUL_ACC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TMATMUL.ACC AType
B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one)
B.DIM LB0 M or cooperative group_M (optional, default 1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111)
B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, B CUBE_N8 primary, optional U8 CScale CUBE_M32 [M,1]
B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations
B.IOT/B.IOR postprocess operands selected by B.FPATR
BSTOP or the next BSTART completion boundary
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_ACC.asl -->
```asl
readonly func InstructionContractCubeFunction_TMATMUL_ACC()
    => integer {0..31}
begin
    return 2;
end;

readonly func InstructionContractSharedOperandsAllowed_TMATMUL_ACC()
    => boolean
begin
    return TRUE;
end;

readonly func InstructionContractOperandsLegal_TMATMUL_ACC(
    destination: TileIndex,
    accumulator: TileIndex,
    left: TileIndex,
    right: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL_ACC(
        destination,
        accumulator,
        left,
        right);
end;

readonly func InstructionContractHandler_TMATMUL_ACC()
    => TileSemanticHandler
begin
    return TileHandler_TMATMUL_ACC;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.
- Omitted LB0 defaults Local M or cooperative group_M to one; omitted LB1 and LB2 default N and K to one.
- Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize.
- TransA=0 and TransB=0 select no logical transpose. Each nonzero control is legal only when the corresponding primary is Shared.
- C and D are both mandatory. CScaleEn accepts one final U8 CUBE_M32 [M,1] Local mathematical source only with FP32 C; omission defaults CScaleEn to zero. In decoded blocks C's six-bit relative selector must differ from zero-extended DstTile before rename; direct Tile calls require destination TileIndex to differ from accumulator TileIndex.
- Omitted CCTRL selects 00: final D output and no transparent-cache hint.

## Legality

- The carrier selects exactly CUBE Function 2 and TileOperation_TMATMUL_ACC.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize.
- C and D are both mandatory. CScaleEn accepts one final U8 CUBE_M32 [M,1] Local mathematical source only with FP32 C; omission defaults CScaleEn to zero. In decoded blocks C's six-bit relative selector must differ from zero-extended DstTile before rename; direct Tile calls require destination TileIndex to differ from accumulator TileIndex.
- A Shared primary must satisfy hardware-maintained whole-parent readiness and publication before payload access; fixed-quarter allocation or initialization masks are not a prerequisite. Any cooperative Local-A/Shared-B or Shared-A/Shared-B TMATMUL interprets LB0 as Core-total group_M in 1..128; Shared A has exact physical valid shape [group_M,K] with physical index m*pitch+k (K-major) for TransA=0 or [K,group_M] with physical index k*pitch+m (M-major) for TransA=1; Shared B has exact physical valid shape [N,K] with physical index n*pitch+k (K-major, ordinary dense column-major/DN-equivalent) for TransB=0 or [K,N] with physical index k*pitch+n (N-major, ordinary dense row-major) for TransB=1; physical columns may be legally padded, and PE i uses valid_M=clamp(group_M-i*M_per_PE,0,M_per_PE) with M_per_PE 16 for group_M<=64 and 32 for group_M>=65. TransA and TransB apply only to their corresponding Shared primary. Right-only Shared inherits Local A layout; all-Shared ACC inherits C layout; all-Shared non-ACC selects M16 through M=16 and M32 through M=32.
- AType and BType must be supported ordinary Matrix types from one numeric class. C is one explicit Local MxN accumulator source and D is a distinct newly published destination; C's encoded relative selector and D's zero-extended DstTile hand must differ before rename. Published Shared operands may replace the right group or both matrix groups; supplementary operands and destinations remain Local.
- Every cooperative nonzero PE_MASK must be 1111; all four PEs complete Shared readiness, while zero-row PEs suppress every compute-only Local resolution and effect. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits BType, matrix CCTRL via PadValueOrByteId, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.
- For init=1 forms CCTRL[1] must be zero. CCTRL[0]=1 selects raw accumulator-type D and forbids final-output post-processing and auxiliary outputs except legal CScale; CCTRL[1] is an ACC-only non-binding explicit-C cache-use or prefetch hint. Every successful form allocates and publishes D.

## State effects

- Multiply matrices and accumulate into the supplied accumulator Tile.
- After complete preflight, execute TMATMUL_ACC with the operand bindings listed above; destination definedness changes only as specified by that handler.
- For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; Bias uses Local CUBE_N8; RowMaxIn/Out and GroupMaxOut use the resolved M layout; vector quant/PReLU parameters use Local CUBE_N8/U64; MX scales keep their operation-owned layouts.
- Successful Shared primary reads leave every Shared descriptor, mask, publication state, payload, and lifetime unchanged.
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

- BSTART.TMATMUL.ACC AType; B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M or cooperative group_M (optional, default 1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111); B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, B CUBE_N8 primary; B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary
