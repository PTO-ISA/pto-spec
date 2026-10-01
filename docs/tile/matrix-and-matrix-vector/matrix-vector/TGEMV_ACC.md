<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_ACC.asl -->
# TGEMV_ACC

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_ACC.asl`

Multiply the matrix by the vector and accumulate into the supplied Tile.

## Normative identity {#PTO-INST-TILE-TGEMV-ACC}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tgemv-acc-purpose role=purpose -->
## What TGEMV_ACC does

`TGEMV_ACC` is the matrix-vector form of the CUBE matrix product. M is fixed to 1, so the left operand A is one row of K elements, the right operand B is a matrix with K rows and N columns, and the destination D is one row of N elements.

The product is added to an explicit accumulator Tile C of the same shape, and C itself is not changed.

Design point: `TGEMV_ACC` is selected by `BSTART.TGEMV.ACC` (CUBE Function 18) and has no standalone opcode. All twelve CUBE matrix instructions share one bundle handler; the function number selects whether a bias, an accumulator, MX scales, the M = 1 and Local-only rules, and CScale apply. The [matrix function table](../../model/legality/matrix-functions.md) lists every form.

<!-- PTO-READER-BLOCK: tile-tgemv-acc-mechanism role=mechanism -->
## Element arithmetic

For each result row and column, the sum starts at the C element at the same position. The inner index then runs from 0 to K-1 in increasing order and adds one product per step.

The accumulator type is FP32 for floating inputs, S32 for signed integer inputs, and U32 for unsigned integer inputs. When the accumulator is FP32, both inputs are FP32, TF32, HF32, FP16, or BF16, and the running sum and both elements are finite, each step rounds the product to FP32 and then rounds the sum to FP32. It uses the `RMode` and `Sat` of `B.DATR`, or RNE without saturation when `B.DATR` is omitted.

In every other case, including integer inputs, 8-bit and 4-bit floating inputs, and NaN or infinite values, the step adds `MultiplyWord(left, right)` to the raw accumulator carrier with 64-bit wrapping arithmetic. That path is exact bit arithmetic, not IEEE arithmetic, and it records no flags.

Design point: the inner loop walks K in one fixed order, and the FP32 path rounds twice per step, so the result is not a fused multiply-add and the model gives one bit-exact result for each input. Accumulation discards flags; post-processing is the only step that records numeric status flags.

Exactly one `B.FPATR` then selects post-processing. With all fields zero, D keeps the accumulator type. A nonzero `PreQuantMode` converts every valid element to that mode's output type, `ReluMode` selects ReLU or a leaky slope for negative values, and `RowMaxEn` and `GroupMaxEn` add RowMaxOut and GroupMaxOut destinations computed from the final D values. [Matrix post-processing](../../model/execution/matrix-postprocess.md) and [post-processing commit](../../model/execution/postprocess.md) give the exact rules.

`CCTRL` is the `PadValueOrByteId` field of `B.DATR`, read as `00` when `B.DATR` is omitted. With bit 0 set, D is published as the raw accumulator-type result, and `PreQuantMode`, `ReluMode`, `GroupNCode`, `RowMaxEn`, `GroupMaxEn`, and `MaxAbsEn` must all be zero. Bit 1 asks the implementation to prefetch or reuse C; it is a non-binding hint and cannot change results.

<!-- PTO-READER-BLOCK: tile-tgemv-acc-inputs-outputs role=inputs-outputs -->
## Operand roles and layouts

The Local mathematical sources are bound in this order:

- `source0` is the accumulator C: valid shape [M, N], the accumulator type, and the same M layout as D. Its capacity must equal D's unless `PreQuantMode` is nonzero. Mnemonic clause `PTO-TGEMV-ACC-CONTRACT-001` permits C and D to use one architectural Tile name, while dispatch clause `PTO-CUBE-ACCUMULATOR-OUTPUT-001` requires C's encoded relative selector to differ from D's zero-extended `DstTile` hand before rename. The executable check differs from both descriptions as explained below.
- `source1` is the left vector A: valid shape [1, K], type AType, and layout `CUBE_M16` or `CUBE_M32`.
- `source2` is the right matrix B: valid shape [K, N], type BType, and layout `CUBE_N8`.

Post-processing sources, such as RowMaxIn and parameter Tiles, come after all of these.

`destination0` is D: newly allocated, valid shape [1, N], the same M layout as A, and the accumulator type, or the output type of a nonzero `PreQuantMode`.

AType is the `BSTART` data type. BType is the `B.DATR` `DataType`, and equals AType when `B.DATR` is omitted. `B.DIM` LB0, LB1, and LB2 carry M, N, and K, and each defaults to 1 when omitted. The M = 1 rule is mandatory: any other LB0 value raises `Fault_TileLegality`.

AType and BType must both be ordinary Matrix types of one numeric class: both floating, both signed integer, or both unsigned integer. HiF4X2 is not an ordinary Matrix type; it is accepted only by the MX forms.

Design point: the mnemonic NDF allows C and D to use one architectural Tile name, while dispatch clause `PTO-CUBE-ACCUMULATOR-OUTPUT-001` requires their encoded selector and destination hand to differ before rename. The current executable model resolves C first, then compares its physical `TileIndex` with D's destination hand (`DstTile MOD 4`). Issue #367 tracks this three-way source conflict. C is read into a private copy before D is written and stays unchanged after success or rejection, but a later bundle is executable only when the resolved C index passes the current comparison.

`TGEMV_ACC` is Local only. Every Shared binding and a nonzero `TransA` or `TransB` is rejected, and any common nonzero `PE_MASK` is legal.

<!-- PTO-READER-BLOCK: tile-tgemv-acc-effects role=effects -->
## Publication and ordering

Complete preflight comes first: types, bindings, dimensions, masks, Local descriptors, aliases, the M layout, and post-processing sources. Only then is the destination group allocated and are the sources read. [CUBE TMATMUL dispatch](../../../block/model/dispatch/cube-tmatmul.md) lists the stages.

D and any enabled RowMaxOut and GroupMaxOut publish as one group. D is defined only in its valid region; its padding stays undefined, because no `PadValue` is applied. A rejected bundle publishes nothing, and every source persists unchanged.

Design point: allocation happens after every rule is checked and before the first source snapshot. A legality fault therefore leaves no allocated destination, and a fault after allocation rolls the destination group back.

The operation has no global-memory effect. Post-processing is the only source of numeric status; it ORs the flags of all its outputs and records them at commit.

<!-- PTO-READER-BLOCK: tile-tgemv-acc-constraints role=constraints -->
## Legality and fault boundary

- After command-level encoding and size-code checks pass, `PE_MASK=0000` on every binding skips matrix-handler descriptor reads, faults, and allocation. Earlier command checks still apply.
- A missing `B.FPATR` raises `Fault_BundleControl`, and an undecodable CUBE selector raises `Fault_IllegalInstruction`.
- An illegal type pair, source or destination count, `B.DATR` field, `CCTRL` use, dimension, mask, descriptor, alias, layout, or post-processing source raises `Fault_TileLegality` before allocation.
- A full destination hand, a destination size too small for the CUBE storage of D, RowMaxOut, or GroupMaxOut, or a destination group that exceeds the remaining capacity, raises `Fault_TileAllocation`.
- Setting `CScaleEn` raises `Fault_TileLegality`, because only `TMATMUL_ACC` and `TMATMUL_MX_ACC` accept CScale.

Design point: M, N, and K are compared with the valid shapes of A, B, and D, not with a capacity-derived row count. The M layout only bounds M by 16 or 32, so the dimensions stay independent of the destination TSize.

<!-- PTO-READER-BLOCK: tile-tgemv-acc-example role=example -->
## Non-normative worked example

This is a non-normative contract schema sketch; it organizes fields and bindings but is not claimed to be directly assembleable.

Take FP16 inputs with N = 2 and K = 2. The accumulator row C is 0.5, -1.0, the left vector is 1.0, 2.0, and the right source rows are 3.0, 5.0 and 4.0, 6.0.

Column 0 starts at 0.5 and adds 3.0 and 8.0 to reach 11.5. Column 1 starts at -1.0 and adds 5.0 and 12.0 to reach 16.0. C still holds 0.5, -1.0 afterwards.

In the non-normative macro sketch below, `T#2` is C, `T#1` is the vector, and `T#3` is the matrix. It is conditional on queue resolution mapping C to a physical `TileIndex` different from the destination hand, which is what the current executable model actually checks:

```text
TGEMV_ACC <M=1, N=16, K=16, FP16>, T#2, T#1, T#3, ->T<1KB>
```
<!-- SUPPLEMENTARY-END -->

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
B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one)
B.DIM LB0 M (optional, default 1; TGEMV permits only M=1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, B CUBE_N8 primary
B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations
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
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize.
- TransA=0 and TransB=0 select no logical transpose. TGEMV requires both controls to remain zero.
- C and D are both mandatory. In decoded blocks C's six-bit relative selector must differ from zero-extended DstTile before rename; direct Tile calls require destination TileIndex to differ from accumulator TileIndex.
- Omitted CCTRL selects 00: final D output and no transparent-cache hint.

## Legality

- The carrier selects exactly CUBE Function 18 and TileOperation_TGEMV_ACC.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize.
- C and D are both mandatory. In decoded blocks C's six-bit relative selector must differ from zero-extended DstTile before rename; direct Tile calls require destination TileIndex to differ from accumulator TileIndex.
- TGEMV is Local-only: TransA and TransB are zero and every effective Shared binding rejects before effects.
- AType and BType must be supported ordinary Matrix types from one numeric class. C is one explicit Local MxN accumulator source and D is a distinct newly published destination; C's encoded relative selector and D's zero-extended DstTile hand must differ before rename. M is fixed to one and every Shared binding is illegal.
- Every common nonzero four-bit PE_MASK is legal; all four PEs complete cooperative Shared readiness while only selected PEs allocate and publish. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits BType, matrix CCTRL via PadValueOrByteId, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.
- For init=1 forms CCTRL[1] must be zero. CCTRL[0]=1 selects raw accumulator-type D and forbids final-output post-processing and auxiliary outputs except legal CScale; CCTRL[1] is an ACC-only non-binding explicit-C cache-use or prefetch hint. Every successful form allocates and publishes D.

## State effects

- Multiply the matrix by the vector and accumulate into the supplied Tile.
- After complete preflight, execute TGEMV_ACC with the operand bindings listed above; destination definedness changes only as specified by that handler.
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

- BSTART.TGEMV.ACC AType; B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M (optional, default 1; TGEMV permits only M=1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, B CUBE_N8 primary; B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary
