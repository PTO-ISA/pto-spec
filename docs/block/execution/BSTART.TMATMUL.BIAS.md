<!-- GENERATED FROM: asl/block/execution/BSTART.TMATMUL.BIAS.asl -->
# BSTART.TMATMUL.BIAS

**Normative ASL source:** `asl/block/execution/BSTART.TMATMUL.BIAS.asl`

Starts CUBE Function 1 for the TMATMUL_BIAS Matrix-matrix complete-bundle operation.

## Normative identity {#PTO-INST-BLOCK-BSTART-TMATMUL-BIAS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-tmatmul-bias-purpose role=purpose -->
## What BSTART.TMATMUL.BIAS does

`BSTART.TMATMUL.BIAS` opens a bundle whose operation is the CUBE matrix product `TMATMUL_BIAS`. It is a 32-bit standalone start command. Its fixed bits select CUBE Function 1 and `TileOperation_TMATMUL_BIAS`, and its only encoded field is the 5-bit `DataType` in bits 31:27. That field becomes AType, the element type of the left operand A.

The result D is the product of A (M x K) and B (K x N) plus a 1 x N Bias row, which is broadcast by output column to every output row.

Design point: the operation identity is fixed entirely by the start command. The following commands (`B.DATR`, `B.FPATR`, `B.DIM`, `B.IOS`, `B.IOT`, and `B.IOR`) supply only types, shape, and operands. All 12 CUBE matrix start commands commit through one handler, `ExecuteBundleTMATMULOperation`, which tells the bias, accumulator, MX, and GEMV variants apart only by the function code.

<!-- PTO-READER-BLOCK: block-bstart-tmatmul-bias-mechanism role=mechanism -->
## Placement and execution mechanism

At the start, `BSTART.TMATMUL.BIAS` builds a Tile matrix descriptor with selector 1 and the encoded `DataType`. A `DataType` code of 15, 21 to 23, or 29 to 31 is outside the accepted set and is rejected by the encoding check with `Fault_IllegalInstruction`. All start checks run before any active predecessor bundle is committed, so a rejected start leaves the predecessor in place. See [bundle start dispatch](../model/dispatch/start.md).

The header commands that follow only record bundle state. No operand is read and no Tile is allocated until the bundle commits at `BSTOP` or at the next `BSTART`.

At commit, [commit validation](../model/commit/validation.md) runs the Tile operation, and [Tile execution](../model/dispatch/tile-execution.md) routes it to [CUBE TMATMUL dispatch](../model/dispatch/cube-tmatmul.md). `ExecuteBundleTMATMULOperation` then works in this order:

1. If every Tile and Shared binding selects no PE, it returns with no effect.
2. A missing `B.FPATR` raises `Fault_BundleControl`.
3. Types, binding counts, `B.DATR` fields, `CCTRL`, dimensions, and PE masks are checked together. Any failure raises `Fault_TileLegality`.
4. It waits, without a fault, until every Shared source is published, and then checks the Shared schemas.
5. It checks the Local sources, the result layout, and the post-processing sources.
6. It allocates the destination group, snapshots the operands, and computes the result. A fault after allocation rolls the destinations back.

Design point: allocation is the last preflight step. Every field, stream, descriptor, shape, and capacity rule is closed before the first destination is reserved, so a bundle rejected by a legality check leaves no allocated destination and no changed source.

Design point: a failed commit returns before the bundle stops. The bundle stays active with its header intact and its continuation is not applied, so the trap context still describes the failing bundle.

<!-- PTO-READER-BLOCK: block-bstart-tmatmul-bias-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- `DataType` in the start command is AType. The optional `B.DATR` supplies BType in its `DataType` field; when `B.DATR` is omitted, BType equals AType, rounding is RNE, and saturation is off. AType and BType must be ordinary matrix input types of one class: both floating, both signed, or both unsigned.
- `B.DATR` may set BType, `RMode`, `Sat`, and `CCTRL`, which travels in its `PadValueOrByteId` field. Its `Layout` and `CMode` must be zero and `Canonicalize` must be off.
- Exactly one `B.FPATR` is required. All-zero fields select no conversion, activation, or reduction; nonzero fields add the RowMax, GroupMax, quantization, or ReLU operands that they enable.
- `B.DIM` `LB0`, `LB1`, and `LB2` give M, N, and K, and each defaults to 1 when omitted. In a cooperative bundle `LB0` is the Core-total group_M.
- `B.IOT` binds the Local mathematical sources in this order: A and then B, then Bias. Post-processing sources follow them.
- The destination bindings are D, then RowMaxOut and GroupMaxOut when `B.FPATR` enables them.
- An optional `B.IOS` supplies the right group (B) or both matrix groups from Shared Tiles. Supplementary sources and all destinations stay Local.

Local A uses `CUBE_M16` (M at most 16) or `CUBE_M32` (M at most 32), and Local B uses `CUBE_N8`. Bias is a Local `CUBE_N8` Tile with 1 row and N columns of the result type.

D's element type follows AType: `S32` for signed, `U32` for unsigned, and `FP32` for floating inputs. A nonzero `PreQuantMode` selects that mode's output type for D instead.

Design point: Bias is checked against the result type, not against AType. A Bias Tile with another type, layout, or shape is rejected with `Fault_TileLegality` before allocation, so a program must hold Bias in the result type.

<!-- PTO-READER-BLOCK: block-bstart-tmatmul-bias-effects role=effects -->
## State effects and ordering

The start command changes only bundle state. It records a fallthrough `BARG` of kind `TileMatrix` and installs the descriptor; no Tile, Shared Tile, or memory changes.

On success, D and every enabled RowMaxOut and GroupMaxOut are published as one atomic group. A rejected bundle publishes none of them. No source is consumed or modified, and a successful read leaves every Shared source descriptor, publication state, and payload unchanged.

D is allocated in A's M layout. When A itself is Shared, the layout is `CUBE_M16` for up to 16 rows per PE and `CUBE_M32` for up to 32.

`CCTRL` is read from `B.DATR` and is `00` when `B.DATR` is absent. Bit 0 publishes D as the raw accumulator-type result and forbids quantization, ReLU, and the RowMax, GroupMax, and max-abs reductions. Bit 1 must be zero, because this form has no C source.

Design point: omitting `B.DATR` is not the same as encoding pad value `11`. `BundleTMATMULCCTRL` returns `00` when `B.DATR` is absent, so a bundle without `B.DATR` never requests raw output by accident. See [accumulator routing](../model/dispatch/cube-accumulator-routing.md).

Design point: the cache hints call implementation-defined hooks that do nothing in the portable model. They cannot change results, faults, allocation, or publication; only the output type chosen by bit 0 is observable.

The bundle has no global-memory effect.

<!-- PTO-READER-BLOCK: block-bstart-tmatmul-bias-constraints role=constraints -->
## Legality, faults, and atomicity

A bundle with any Shared source is cooperative. Every binding must then use `PE_MASK` 1111, group_M must be 1 to 128, and N and K must be powers of two. Each PE owns 16 rows when group_M is at most 64 and 32 rows otherwise. A PE whose rows start at or beyond group_M consumes its Shared bindings and finishes with no Local effect. See [Shared CUBE matrix](../model/dispatch/shared-cube-matrix.md).

`TransA` and `TransB` are legal only when the corresponding primary is Shared. A Shared source that is not yet published makes the commit return without a fault, and the bundle stays active.

`CScaleEn` must be zero, because CScale is accepted only by CUBE Functions 2 and 6.

`PE_MASK` 0000 on every binding is a strict no-op: the matrix handler reads no descriptor and raises no fault.

A `DataType` outside the accepted set raises `Fault_IllegalInstruction` at the start. A missing `B.FPATR` raises `Fault_BundleControl`. A failed type, count, shape, layout, alias, or post-processing check raises `Fault_TileLegality`, and a full destination hand or insufficient capacity raises `Fault_TileAllocation`. Each of these faults occurs before any destination is published.

<!-- PTO-READER-BLOCK: block-bstart-tmatmul-bias-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

The canonical macro below computes a 16 x 32 result with K equal to 64. A is `T#3`, a 16 x 64 `FP16` Tile in `CUBE_M16`; B is `T#2`, a 64 x 32 `FP16` Tile in `CUBE_N8`; Bias is `T#1`, a 1 x 32 `FP32` Tile in `CUBE_N8`.

```text
TMATMUL_BIAS <M=16, N=32, K=64, FP16>, T#3, T#2, T#1, ->T<2KB>
```

One physical bundle for this macro follows. The all-zero `B.FPATR` is still required.

```asm
BSTART.TMATMUL.BIAS FP16
B.FPATR None, None, 0, 0, 0, 0, 0, 0, 0, 0
B.DIM zero, 16, ->LB0
B.DIM zero, 32, ->LB1
B.DIM zero, 64, ->LB2
B.IOT T#3, T#2, mask=1111
B.IOT T#1, mask=1111, last, ->T<5>
BSTOP
```

With no `B.DATR`, BType is also `FP16`, so the result type is `FP32`. Each selected PE computes 16 x 32 = 512 elements from sums of 64 products, and every output row adds the same 32 Bias values. D is a new `FP32` Tile in `CUBE_M16` that occupies 16 cells of 128 bytes, which is 2KB and matches SizeCode 5.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.TMATMUL.BIAS DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tmatmul_bias_32_4d5a498d12f3 | L32 | 32 | 0x00131181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tmatmul_bias_32_4d5a498d12f3 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
| bstart_tmatmul_bias_32_4d5a498d12f3 | DataType | 5 | 0–14, 16–20, 24–28 | none | 15, 21–23, 29–31 | tile element data type selector | Encoded zero selects FP64. |

- `bstart_tmatmul_bias_32_4d5a498d12f3.DataType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | tile element data type selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TMATMUL.BIAS.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TMATMUL_BIAS(
    operation: CommandOperation) => boolean
begin
    return operation ==
        CommandOperation_bstart_tmatmul_bias_32_4d5a498d12f3;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TMATMUL.BIAS AType
B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType)
B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one)
B.DIM LB0 M or cooperative group_M (optional, default 1)
B.DIM LB1 N (optional, default 1)
B.DIM LB2 K (optional, default 1)
B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111)
B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, B CUBE_N8 primary, CUBE_N8 1xN Bias
B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations
B.IOT/B.IOR postprocess operands selected by B.FPATR
BSTOP or the next BSTART completion boundary
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TMATMUL.BIAS.asl -->
```asl
readonly func InstructionContractTileOperation_BSTART_TMATMUL_BIAS()
    => TileOperation
begin
    return TileOperation_TMATMUL_BIAS;
end;

readonly func InstructionContractCubeFunction_BSTART_TMATMUL_BIAS()
    => integer {0..31}
begin
    return 1;
end;

readonly func InstructionContractSharedOperandsAllowed_BSTART_TMATMUL_BIAS()
    => boolean
begin
    return TRUE;
end;

readonly func InstructionContractHandler_BSTART_TMATMUL_BIAS()
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
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize. Bias uses Local CUBE_N8; it is a logical 1xN accumulator-type source (FP32 for MX) broadcast by logical output column.
- TransA=0 and TransB=0 select no logical transpose. Each nonzero control is legal only when the corresponding primary is Shared.
- Omitted CCTRL selects 00: final D output and no transparent-cache hint.

## Legality

- The carrier selects exactly CUBE Function 1 and TileOperation_TMATMUL_BIAS.
- Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize. Bias uses Local CUBE_N8; it is a logical 1xN accumulator-type source (FP32 for MX) broadcast by logical output column.
- A Shared primary must satisfy hardware-maintained whole-parent readiness and publication before payload access; fixed-quarter allocation or initialization masks are not a prerequisite. Any cooperative Local-A/Shared-B or Shared-A/Shared-B TMATMUL interprets LB0 as Core-total group_M in 1..128; Shared A has exact physical valid shape [group_M,K] with physical index m*pitch+k (K-major) for TransA=0 or [K,group_M] with physical index k*pitch+m (M-major) for TransA=1; Shared B has exact physical valid shape [N,K] with physical index n*pitch+k (K-major, ordinary dense column-major/DN-equivalent) for TransB=0 or [K,N] with physical index k*pitch+n (N-major, ordinary dense row-major) for TransB=1; physical columns may be legally padded, and PE i uses valid_M=clamp(group_M-i*M_per_PE,0,M_per_PE) with M_per_PE 16 for group_M<=64 and 32 for group_M>=65. TransA and TransB apply only to their corresponding Shared primary. Right-only Shared inherits Local A layout; all-Shared ACC inherits C layout; all-Shared non-ACC selects M16 through M=16 and M32 through M=32.
- AType and BType must be supported ordinary Matrix types from one numeric class. Bias uses one Local CUBE_N8 logical 1xN accumulator-type source (FP32 for MX), broadcast by logical output column. Published Shared operands may replace the right group or both matrix groups; supplementary operands and destinations remain Local.
- Every cooperative nonzero PE_MASK must be 1111; all four PEs complete Shared readiness, while zero-row PEs suppress every compute-only Local resolution and effect. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.
- B.DATR permits BType, matrix CCTRL via PadValueOrByteId, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.
- For init=1 forms CCTRL[1] must be zero. CCTRL[0]=1 selects raw accumulator-type D and forbids final-output post-processing and auxiliary outputs except legal CScale; CCTRL[1] is an ACC-only non-binding explicit-C cache-use or prefetch hint. Every successful form allocates and publishes D.

## State effects

- Start a CUBE Function 1 descriptor with encoded DataType preserved as AType.
- At block completion execute TileOperation_TMATMUL_BIAS using the resolved M, N, K, input types, mathematical operands, and B.FPATR postprocess schema.
- Publish the complete output group atomically after successful preflight and computation; do not consume mathematical or postprocess sources.
- For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; Bias uses Local CUBE_N8; RowMaxIn/Out and GroupMaxOut use the resolved M layout; vector quant/PReLU parameters use Local CUBE_N8/U64; MX scales keep their operation-owned layouts.
- Successful Shared primary reads leave every Shared descriptor, mask, publication state, payload, and lifetime unchanged.
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

- BSTART.TMATMUL.BIAS AType; B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M or cooperative group_M (optional, default 1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111); B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, B CUBE_N8 primary, CUBE_N8 1xN Bias; B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary
