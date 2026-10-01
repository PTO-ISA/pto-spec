<!-- GENERATED FROM: asl/block/execution/BSTART.TMATMULMX.ACC.asl -->
# BSTART.TMATMULMX.ACC

**Normative ASL source:** `asl/block/execution/BSTART.TMATMULMX.ACC.asl`

Starts CUBE Function 6 for the TMATMUL_MX_ACC Matrix-matrix complete-bundle operation.

## Normative identity {#PTO-INST-BLOCK-BSTART-TMATMULMX-ACC}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tmatmulmx-acc-purpose role=purpose -->
## What BSTART.TMATMULMX.ACC does

`BSTART.TMATMULMX.ACC` opens a bundle whose operation is the CUBE matrix product `TMATMUL_MX_ACC`. It is a 32-bit standalone start command. Its fixed bits select CUBE Function 6 and `TileOperation_TMATMUL_MX_ACC`, and its only encoded field is the 5-bit `DataType` in bits 31:27. That field becomes AType, the element type of the left operand A.

The result D is the explicit Local accumulator C (M x N) plus the product of A (M x K) and B (K x N). As an MX form it takes microscaled inputs: a side whose type is not `FP16` or `BF16` carries its own scale Tile.

Design point: the operation identity is fixed entirely by the start command. The following commands (`B.DATR`, `B.FPATR`, `B.DIM`, `B.IOS`, `B.IOT`, and `B.IOR`) supply only types, shape, and operands. All 12 CUBE matrix start commands commit through one handler, `ExecuteBundleTMATMULOperation`, which tells the bias, accumulator, MX, and GEMV variants apart only by the function code.

<!-- PTO-READER-BLOCK: block-bstart-tmatmulmx-acc-mechanism role=mechanism -->
## Placement and execution mechanism

At the start, `BSTART.TMATMULMX.ACC` builds a Tile matrix descriptor with selector 6 and the encoded `DataType`. A `DataType` code of 15, 21 to 23, or 29 to 31 is outside the accepted set and is rejected by the encoding check with `Fault_IllegalInstruction`. All start checks run before any active predecessor bundle is committed, so a rejected start leaves the predecessor in place. See [bundle start dispatch](../model/dispatch/start.md).

The header commands that follow only record bundle state. No operand is read and no Tile is allocated until the bundle commits at `BSTOP` or at the next `BSTART`.

At commit, [commit validation](../model/commit/validation.md) runs the Tile operation, and [Tile execution](../model/dispatch/tile-execution.md) routes it to [CUBE TMATMUL dispatch](../model/dispatch/cube-tmatmul.md). `ExecuteBundleTMATMULOperation` then works in this order:

1. If every Tile and Shared binding selects no PE, it returns with no effect.
2. A missing `B.FPATR` raises `Fault_BundleControl`.
3. Types, binding counts, `B.DATR` fields, `CCTRL`, dimensions, and PE masks are checked together. Any failure raises `Fault_TileLegality`.
4. It waits, without a fault, until every Shared source is published, and then checks the Shared schemas.
5. It checks the Local sources, the separation of C from D, the result layout, and the post-processing sources.
6. It allocates the destination group, snapshots the operands, and computes the result. A fault after allocation rolls the destinations back.

Design point: allocation is the last preflight step. Every field, stream, descriptor, shape, and capacity rule is closed before the first destination is reserved, so a bundle rejected by a legality check leaves no allocated destination and no changed source.

Design point: a failed commit returns before the bundle stops. The bundle stays active with its header intact and its continuation is not applied, so the trap context still describes the failing bundle.

<!-- PTO-READER-BLOCK: block-bstart-tmatmulmx-acc-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- `DataType` in the start command is AType. The optional `B.DATR` supplies BType in its `DataType` field; when `B.DATR` is omitted, BType equals AType, rounding is RNE, and saturation is off. Each type must be an MX input type: `FP16`, `BF16`, `E4M3`, `E5M2`, `E2M1X2`, `E1M2X2`, or `HiF4X2`.
- `B.DATR` may set BType, `RMode`, `Sat`, and `CCTRL`, which travels in its `PadValueOrByteId` field. Its `Layout` and `CMode` must be zero and `Canonicalize` must be off.
- Exactly one `B.FPATR` is required. All-zero fields select no conversion, activation, or reduction; nonzero fields add the RowMax, GroupMax, quantization, ReLU, or CScale operands that they enable.
- `B.DIM` `LB0`, `LB1`, and `LB2` give M, N, and K, and each defaults to 1 when omitted. In a cooperative bundle `LB0` is the Core-total group_M.
- `B.IOT` binds the Local mathematical sources in this order: C first, then A, the A scale when required, B, and the B scale when required, then CScale when `CScaleEn` is set. Post-processing sources follow them.
- The destination bindings are D, then RowMaxOut and GroupMaxOut when `B.FPATR` enables them.
- An optional `B.IOS` supplies the right group (B and its scale) or both matrix groups from Shared Tiles. Supplementary sources and all destinations stay Local.

Local A uses `CUBE_M16` (M at most 16) or `CUBE_M32` (M at most 32), and Local B uses `CUBE_N8`. C uses the same layout as A, holds M x N elements of the result type, and must have the same capacity as D unless `PreQuantMode` is nonzero. A Local scale is stored in `CUBE_M32`. It is `E8M0` with one value per group of 32 K elements, or `U32` with one value per group of 64 for `HiF4X2`. The A scale has M rows and the B scale has N rows.

D's element type is `FP32`. A nonzero `PreQuantMode` selects that mode's output type for D instead.

Design point: a scale Tile is present exactly when its side needs one. `FP16` and `BF16` sides carry none, so the expected source count depends on both types. A missing or extra scale changes the count and is rejected with `Fault_TileLegality` before allocation.

Design point: C must be distinct from D. The contract requires C's encoded source selector to differ from D's zero-extended `DstTile` hand, and `BundleMatrixAccumulatorDestinationIndicesDistinct` raises `Fault_TileLegality` before allocation when its comparison fails. C is snapshotted before the product and is unchanged after success or rejection, so the old accumulator stays readable.

<!-- PTO-READER-BLOCK: block-bstart-tmatmulmx-acc-effects role=effects -->
## State effects and ordering

The start command changes only bundle state. It records a fallthrough `BARG` of kind `TileMatrix` and installs the descriptor; no Tile, Shared Tile, or memory changes.

On success, D and every enabled RowMaxOut and GroupMaxOut are published as one atomic group. A rejected bundle publishes none of them. No source is consumed or modified, and a successful read leaves every Shared source descriptor, publication state, and payload unchanged.

D is allocated in A's M layout. When A itself is Shared, the layout is taken from C.

`CCTRL` is read from `B.DATR` and is `00` when `B.DATR` is absent. Bit 0 publishes D as the raw accumulator-type result and forbids quantization, ReLU, and the RowMax, GroupMax, and max-abs reductions. Bit 1 is a non-binding hint to reuse or prefetch C.

Design point: omitting `B.DATR` is not the same as encoding pad value `11`. `BundleTMATMULCCTRL` returns `00` when `B.DATR` is absent, so a bundle without `B.DATR` never requests raw output by accident. See [accumulator routing](../model/dispatch/cube-accumulator-routing.md).

Design point: the cache hints call implementation-defined hooks that do nothing in the portable model. They cannot change results, faults, allocation, or publication; only the output type chosen by bit 0 is observable.

The bundle has no global-memory effect.

<!-- PTO-READER-BLOCK: block-bstart-tmatmulmx-acc-constraints role=constraints -->
## Legality, faults, and atomicity

A bundle with any Shared source is cooperative. Every binding must then use `PE_MASK` 1111, group_M must be 1 to 128, and N and K must be powers of two. Each PE owns 16 rows when group_M is at most 64 and 32 rows otherwise. A PE whose rows start at or beyond group_M consumes its Shared bindings and finishes with no Local effect. See [Shared CUBE matrix](../model/dispatch/shared-cube-matrix.md).

`TransA` and `TransB` are legal only when the corresponding primary is Shared. A Shared source that is not yet published makes the commit return without a fault, and the bundle stays active.

`CScaleEn` is legal for this form only with an `FP32` result. The CScale source is a Local `U8` `CUBE_M32` Tile with M rows and 1 column, and it must not share an index with any destination hand. See [matrix scale](../model/dispatch/matrix-scale.md).

`PE_MASK` 0000 on every binding is a strict no-op: the matrix handler reads no descriptor and raises no fault.

A `DataType` outside the accepted set raises `Fault_IllegalInstruction` at the start. A missing `B.FPATR` raises `Fault_BundleControl`. A failed type, count, shape, layout, alias, or post-processing check raises `Fault_TileLegality`, and a full destination hand or insufficient capacity raises `Fault_TileAllocation`. Each of these faults occurs before any destination is published.

<!-- PTO-READER-BLOCK: block-bstart-tmatmulmx-acc-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

The canonical macro below computes a 16 x 32 result with K equal to 64. C is `T#5`, a 16 x 32 `FP32` Tile in `CUBE_M16` with a capacity of 2KB; A is `T#4`, a 16 x 64 `E4M3` Tile in `CUBE_M16`; the A scale is `T#3`, a 16 x 2 `E8M0` Tile in `CUBE_M32`; B is `T#2`, a 64 x 32 `E4M3` Tile in `CUBE_N8`; the B scale is `T#1`, a 32 x 2 `E8M0` Tile in `CUBE_M32`.

```text
TMATMUL_MX_ACC <M=16, N=32, K=64, E4M3>, T#5, T#4, T#3, T#2, T#1, ->T<2KB>
```

One physical bundle for this macro follows. The all-zero `B.FPATR` is still required.

```asm
BSTART.TMATMULMX.ACC E4M3
B.FPATR None, None, 0, 0, 0, 0, 0, 0, 0, 0
B.DIM zero, 16, ->LB0
B.DIM zero, 32, ->LB1
B.DIM zero, 64, ->LB2
B.IOT T#5, T#4, mask=1111
B.IOT T#3, T#2, mask=1111
B.IOT T#1, mask=1111, last, ->T<5>
BSTOP
```

The result type is `FP32`, and each side uses 2 scale groups because 64 / 32 = 2. Each selected PE adds C to the product, computing 16 x 32 = 512 elements from sums of 64 products, and C keeps its old value. D is a new `FP32` Tile in `CUBE_M16` that occupies 16 cells of 128 bytes, which is 2KB and matches SizeCode 5.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TMATMULMX.ACC DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tmatmulmx_acc_32_70fa59b0ab4c | L32 | 32 | 0x00631181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tmatmulmx_acc_32_70fa59b0ab4c | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### DataType (`PTO-FIELD-BLOCK-DATATYPE`)

Selects the Tile element data type carried by Block data attributes and typed Block starts.

**Encoded zero:** Code zero selects FP64; zero never means absent, inherited, NONE, or NULL.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | FP64 |
| 1 | assigned | FP32 |
| 2 | assigned | TF32 |
| 3 | assigned | HF32 |
| 4 | assigned | FP16 |
| 5 | assigned | BF16 |
| 6 | assigned | HiF8 |
| 7 | assigned | E4M3 |
| 8 | assigned | E5M2 |
| 9 | assigned | E3M2 |
| 10 | assigned | E2M3 |
| 11 | assigned | E2M1X2 |
| 12 | assigned | E1M2X2 |
| 13 | assigned | E8M0 |
| 14 | assigned | HiF4X2 |
| 15 | assigned | E6M2 |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | assigned | RCPE6M2 |
| 22 | reserved | future extension |
| 23 | reserved | future extension |
| 24 | assigned | U64 |
| 25 | assigned | U32 |
| 26 | assigned | U16 |
| 27 | assigned | U8 |
| 28 | assigned | U4X2 |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Reserved values are held for future extension and reject before architectural effects.

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_tmatmulmx_acc_32_70fa59b0ab4c | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | tile element data type selector | Encoded zero selects FP64. |

- `bstart_tmatmulmx_acc_32_70fa59b0ab4c.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | tile element data type selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TMATMULMX.ACC.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TMATMULMX_ACC(
    operation: CommandOperation) => boolean
begin
    return operation ==
        CommandOperation_bstart_tmatmulmx_acc_32_70fa59b0ab4c;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TMATMULMX.ACC AType
B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one)
B.DIM LB0 M or cooperative group_M (optional, default 1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111)
B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale, optional U8 CScale CUBE_M32 [M,1]
B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations
B.IOT/B.IOR postprocess operands selected by B.FPATR
BSTOP or the next BSTART completion boundary
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TMATMULMX.ACC.asl -->
```asl
readonly func InstructionContractTileOperation_BSTART_TMATMULMX_ACC()
    => TileOperation
begin
    return TileOperation_TMATMUL_MX_ACC;
end;

readonly func InstructionContractCubeFunction_BSTART_TMATMULMX_ACC()
    => integer {0..31}
begin
    return 6;
end;

readonly func InstructionContractSharedOperandsAllowed_BSTART_TMATMULMX_ACC()
    => boolean
begin
    return TRUE;
end;

readonly func InstructionContractHandler_BSTART_TMATMULMX_ACC()
    => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.
- Omitted LB0 defaults Local M or cooperative group_M to one; omitted LB1 and LB2 default N and K to one.
- Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize; when a Local Matrix-MX scale is required, its M/N major is at most 32 because Local scales use one-block CUBE_M32, while Shared scales remain ordinary Tiles. Each side uses group-32 E8M0 or HiF4X2 group-64 U32 scale; Local scales use CUBE_M32 and Shared scales remain ordinary Tiles.
- TransA=0 and TransB=0 select no logical transpose. Each nonzero control is legal only when the corresponding primary is Shared.
- C and D are both mandatory. CScaleEn accepts one final U8 CUBE_M32 [M,1] Local mathematical source only with FP32 C; omission defaults CScaleEn to zero. In decoded blocks C's six-bit relative selector must differ from zero-extended DstTile before rename; direct Tile calls require destination TileIndex to differ from accumulator TileIndex.
- Omitted CCTRL selects 00: final D output and no transparent-cache hint.

## Legality

- The carrier selects exactly CUBE Function 6 and TileOperation_TMATMUL_MX_ACC.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize; when a Local Matrix-MX scale is required, its M/N major is at most 32 because Local scales use one-block CUBE_M32, while Shared scales remain ordinary Tiles. Each side uses group-32 E8M0 or HiF4X2 group-64 U32 scale; Local scales use CUBE_M32 and Shared scales remain ordinary Tiles.
- C and D are both mandatory. CScaleEn accepts one final U8 CUBE_M32 [M,1] Local mathematical source only with FP32 C; omission defaults CScaleEn to zero. In decoded blocks C's six-bit relative selector must differ from zero-extended DstTile before rename; direct Tile calls require destination TileIndex to differ from accumulator TileIndex.
- A Shared primary must satisfy hardware-maintained whole-parent readiness and publication before payload access; fixed-quarter allocation or initialization masks are not a prerequisite. Any cooperative Local-A/Shared-B or Shared-A/Shared-B TMATMUL interprets LB0 as Core-total group_M in 1..128; Shared A has exact physical valid shape [group_M,K] with physical index m*pitch+k (K-major) for TransA=0 or [K,group_M] with physical index k*pitch+m (M-major) for TransA=1; Shared B has exact physical valid shape [N,K] with physical index n*pitch+k (K-major, ordinary dense column-major/DN-equivalent) for TransB=0 or [K,N] with physical index k*pitch+n (N-major, ordinary dense row-major) for TransB=1; physical columns may be legally padded, and PE i uses valid_M=clamp(group_M-i*M_per_PE,0,M_per_PE) with M_per_PE 16 for group_M<=64 and 32 for group_M>=65. TransA and TransB apply only to their corresponding Shared primary. Right-only Shared inherits Local A layout; all-Shared ACC inherits C layout; all-Shared non-ACC selects M16 through M=16 and M32 through M=32.
- Each non-FP16/BF16 side requires its assigned scale: group-32 E8M0 for MX FP8/FP4 or group-64 U32 for HiF4X2. C is one explicit Local MxN accumulator source and D is a distinct newly published destination; C's encoded relative selector and D's zero-extended DstTile hand must differ before rename. Published Shared operands may replace the right group or both matrix groups; supplementary operands and destinations remain Local.
- Every cooperative nonzero PE_MASK must be 1111; all four PEs complete Shared readiness, while zero-row PEs suppress every compute-only Local resolution and effect. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits BType, matrix CCTRL via PadValueOrByteId, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.
- For init=1 forms CCTRL[1] must be zero. CCTRL[0]=1 selects raw accumulator-type D and forbids final-output post-processing and auxiliary outputs except legal CScale; CCTRL[1] is an ACC-only non-binding explicit-C cache-use or prefetch hint. Every successful form allocates and publishes D.

## State effects

- Start a CUBE Function 6 descriptor with encoded DataType preserved as AType.
- At block completion execute TileOperation_TMATMUL_MX_ACC using the resolved M, N, K, input types, mathematical operands, and B.FPATR postprocess schema.
- Publish the complete output group atomically after successful preflight and computation; do not consume mathematical or postprocess sources.
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

- BSTART.TMATMULMX.ACC AType; B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M or cooperative group_M (optional, default 1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111); B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A with encoded selector distinct from DstTile, A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale; B.IOT D matching A's CUBE_M16/M32 layout with a distinct encoded destination index, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary
