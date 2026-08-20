# Portable Convolution Pipeline RFC Design

## Status and baseline

This document is the review design for GitHub issue
[#99](https://github.com/PTO-ISA/pto-spec/issues/99). It supersedes the earlier
draft in this file.

- Status: design accepted section by section; updated for renewed review.
- PTO specification baseline: `origin/main` commit
  `328ab1989572b93d5ef5b1e2b726e906b30cbb3c`.
- Public PTO source comparison baseline:
  `8e2f0fa10ddc1e887ac2e102666854247aee9b77`.
- Independent comparison evidence: anonymized source SHA-256
  `670174008299a58c25b8fc365a079980b4bf663508812d23c11211ed3026055e`.

The independent source remains read-only comparison evidence. PTO artifacts
must not publish its identity, local path, prose, code, diagrams, physical
buffer names, or private register names.

## Outcome

PTO defines convolution as an explicit one-level sequence:

```text
strided GM tensor
    -> ConvTile TLOAD
    -> TIMG2COL to CUBE_M16 or CUBE_M32
    -> TMATMUL with CUBE_N8 weights
    -> explicit TMOV/PostProcess and TEPL operations
    -> explicit TTRANS layout conversion
    -> TSTORE
```

No fused convolution instruction, hidden configuration instruction, persistent
filter register, persistent stride register, or persistent padding register is
added. Every operation receives its current parameters in its own bundle.
Implementations may fuse adjacent stages physically, but fusion cannot change
architectural operands, faults, intermediate Tile visibility, numeric results,
diagnostic state, or commit boundaries.

The base contract covers H/W convolution over NC1HWC0 and NDC1HWC0 feature
maps. In NDC1HWC0, D is an outer slice in M linearization; the filter does not
slide in D. A true spatial 3-D convolution with FilterD, StrideD, DilationD,
PadFront, and PadBack requires a separate geometry contract.

## Latest-main reconciliation

| Current main contract | RFC disposition |
| --- | --- |
| `PTO-TIMG2COL-CONTRACT-001` reads geometry and padding from a persistent `TileFeatureMapDescriptor` | Supersede it. The sidecar retains only ConvTile shape/layout; each TIMG2COL bundle supplies fresh geometry and padding |
| The feature-map sidecar already distinguishes a feature-map Tile | Reuse and narrow it instead of adding another `TileKind` field |
| B.DIM exposes write-once LB0..LB2 | Extend the same contract to LB3/LB4; add no LB5..LB7 |
| `PTO-B-IOR-BINDING-001` permits at most one B.IOR | Preserve one for existing operations; permit exact ordered two-entry schemas only where this RFC assigns them |
| ADR 0074 defines TLOAD/TSTORE row stride in bytes | Use bytes for every ConvTile GM stride; the earlier element-stride proposal is superseded |
| `PTO-CUBE-CELL-STATE-001` defines persistent M16/M32/N8 layouts | Reuse its geometry, capacity, padding, definedness, and payload-index helpers |
| `PTO-CUBE-CELL-TRANSPORT-001` assigns Layout 21..26 | Reuse 21/22 for TIMG2COL output and 24/25 for TMOV export |
| Current Matrix execution still requires ordinary power-of-two Local operands | Depend on or incorporate the Local CUBE Matrix operand contract proposed by PR #109 |
| B.FPATR is mandatory CUBE-only | Preserve mandatory CUBE use; add optional TMOV/TSTORE use with strict field legality |
| CORE_STATE[36:32] owns sticky NV/DZ/OF/UF/NX | Preserve it and add a separate block-local read-clear STATUS projection |
| TTRANS defines only 2-D transpose | Preserve Layout=0 and add explicitly selected convolution output layouts |

## NDF ownership

The normative work adds or revises these stable clauses:

- `PTO-CONVTILE-DESCRIPTOR-001`;
- `PTO-B-DIM-FIVE-REGISTER-001`;
- `PTO-B-IOR-ORDERED-SCHEMA-001`;
- `PTO-CONVTILE-GM-TRANSPORT-001`;
- `PTO-TIMG2COL-PER-BUNDLE-001`;
- `PTO-TIMG2COL-CUBE-OUTPUT-001`;
- `PTO-CONV-MATRIX-NUMERIC-001`;
- `PTO-FIXPIPE-EXPLICIT-SEQUENCE-001`;
- `PTO-TTRANS-CONV-LAYOUT-001`;
- `PTO-BLOCK-STATUS-001`;
- `PTO-BLOCK-ENGINE-DIAGNOSTIC-001`.

Normative meaning is written once in current ASL. Markdown instruction pages,
catalogs, decoder witnesses, release inputs, traceability, and evidence remain
generated projections.

## Architecture boundary

Portable PTO defines ConvTile shape/layout state, byte-strided GM transport,
fresh TIMG2COL parameters, exact floor convolution geometry, CUBE CELL output,
the convolution-relevant TMATMUL numeric subset, explicit PostProcess/layout
composition, and block-local diagnostics.

Portable PTO does not define physical accelerator buffers, pipeline timing,
repeat engines, unit flags, hidden FMATRIX/FIXPIPE state, automatic TSize
truncation, target dual-source fetch, or physical fractal strides. Special ceil
output formulas remain scheduling rules; the portable value uses the floor
formula below. Depth/space and Winograd pipe mechanisms require separate
explicit PTO operations and NDF contracts.

## ConvTile state

### Minimal sidecar

Reuse current main's `_TileFeatureMapDescriptors` state root, renamed or
narrowed as the ConvTile sidecar. A valid sidecar contains only:

- valid;
- layout: NC1HWC0 or NDC1HWC0;
- N, D, C1, H, W, each in `1..65535`.

It contains no filter, stride, dilation, pad extent, logical C, padding value,
transpose, output mode, or repeat state.

C0 is derived from dtype:

```text
C0 * element_bits = 256
```

NC1HWC0 requires D=1. Required storage is:

```text
ceil(N * D * C1 * H * W * C0 * element_bits / 8)
```

It must fit TSize and aggregate per-PE Tile capacity.

`ConvTileDescriptorValid(index)` is the kind discriminator. Ordinary
operations reject a Tile with a valid sidecar unless the mnemonic explicitly
accepts ConvTile. ConvTile-aware TLOAD/TSTORE and TIMG2COL are accepted here.
Shared Tiles cannot carry the sidecar.

Reset, release, and successful ordinary reconfiguration invalidate the
sidecar. Failed reconfiguration preserves all old state. Live Local Tile state
is not copied into TrapContext; retry observes the same ConvTile.

## Bundle extensions

### Five write-once LB registers

Bundle dimension state becomes LB0..LB4. Full B.DIM function values 3 and 4
select LB3/LB4. Values 5..7 remain reserved and raise
`Fault_IllegalInstruction`.

All five preserve current behavior: absolute GPR 0..23, low 16 bits of GPR plus
uimm17, one presence bit, duplicate `Fault_BundleControl` preserving the first
value, bundle reset, and TrapContext save/recovery. Compressed dimension forms
remain LB0..LB2. Existing operation schemas require LB3/LB4 absent unless they
explicitly consume them.

No visible loop-state SSR is added. Current EBARG loop registers are
storage-only; recovery already uses internal TrapContext state.

### Ordered B.IOR schemas

The B.IOR encoding is unchanged. Current main already reserves 32 binding
records and trap-snapshots them. Existing operations retain a maximum of one
B.IOR. ConvTile transfer and memory-plus-PostProcess schemas may accept exactly
two ordered entries.

A legal instruction appends to the first unused record. Surplus, duplicate
after schema completion, reordered, or nonzero unused fields raise
`Fault_BundleControl` and preserve earlier records. This is bundle-local
parameter state, not a set/config interface.

## Layout code allocation

The RFC assigns four currently reserved B.DATR.Layout values:

| Code | Identity | Consumers |
| ---: | --- | --- |
| 12 | NC1HWC0 | ConvTile TLOAD/TSTORE, TTRANS destination |
| 14 | NCHW | TTRANS destination |
| 16 | NHWC | TTRANS destination |
| 19 | NDC1HWC0 | ConvTile TLOAD/TSTORE, TTRANS destination |

Codes 21..26 retain ND2M32, ND2M16, ND2N8, M322ND, M162ND, and N82ND. No
assigned or target-advertised code is silently reinterpreted.

## ConvTile GM transport

### Shape and attributes

ConvTile TLOAD uses:

```text
LB0=N, LB1=D, LB2=C1, LB3=H, LB4=W
```

All are present and nonzero. Mandatory B.DATR carries DTYPE_NONE, Layout 12 or
19, and zero for every other field.

ConvTile TSTORE reads shape/layout from its source sidecar and requires all LBs
absent. B.DATR may be omitted; when present, Layout matches the source and all
other fields retain their zero/DTYPE_NONE meanings.

### Byte-stride schema

All strides are XLEN byte distances. C0 is the implicit inner dimension.

| B.IOR | RegSrc0 | RegSrc1 | RegSrc2 | RegDst |
| ---: | --- | --- | --- | --- |
| 0 | GM base | strideN | strideD | zero |
| 1 | strideC1 | strideH | strideW | zero |

- no B.IOR: base zero and dense strides;
- one B.IOR: RegSrc0 is base, RegSrc1/2 are zero, strides are dense;
- two B.IORs: every used stride is explicit and positive; NC1HWC0 requires
  strideD=0.

Dense strides are:

```text
strideW=32
strideH=W*strideW
strideC1=H*strideH
strideD=C1*strideC1
strideN=D*strideD
```

NC1HWC0 uses `strideN=C1*strideC1` and ignores strideD. Explicit strides must
preserve canonical order and non-overlap:

```text
strideW >= 32
strideH >= W*strideW
strideC1 >= H*strideH
strideD >= C1*strideC1       // NDC1HWC0
strideN >= D*strideD         // NDC1HWC0
strideN >= C1*strideC1       // NC1HWC0
```

For `(n,d,c1,h,w,c0)`:

```text
block = base + n*strideN + d*strideD + c1*strideC1
             + h*strideH + w*strideW
```

Byte-sized or wider elements use `block+c0*element_bytes`. Packed four-bit
elements use `block+floor(c0/2)` and low/high nibble by c0 parity. The base
identifies the low nibble of c0=0.

Complete capacity, address, permission, alignment, and overlap preflight
precedes any descriptor, payload, memory-event, or GM effect.

## TIMG2COL bundle

### Composition

TIMG2COL retains TEPL Mode 3 Function 4, selector `0x064`, and SFU
classification.

```text
BSTART.SFU TIMG2COL, DataType
B.DATR Layout={ND2M32|ND2M16}, DTYPE_NONE,
       PadValueOrByteId={Constant|PerChannel}
B.DIM ->LB0 ValidK
B.DIM ->LB1 ValidM
B.DIM ->LB2 FilterH
B.DIM ->LB3 FilterW
B.DIM ->LB4 LogicalC
B.IOR posM, posK, ConvGeometry, ->zero
B.IOT ConvTile, [PaddingTile], ->CUBE_M destination<TSize>
BSTOP
```

Layout 21 selects CUBE_M32 and 22 selects CUBE_M16. B.DATR is mandatory.
PadValueOrByteId is an operation-specific view: 0 Constant, 1 PerChannel,
2..3 reserved. All other fields are zero except DTYPE_NONE.

LB defaults are:

| LB | Meaning | Omitted or zero |
| ---: | --- | --- |
| 0 | ValidK | `K_total-posK` |
| 1 | ValidM | `M_total-posM` |
| 2 | FilterH | 1 |
| 3 | FilterW | 1 |
| 4 | LogicalC | `C1*C0` |

An inferred zero extent is illegal. An inferred full extent that exceeds TSize
raises `Fault_TileAllocation`; it is not truncated.

One optional B.IOR supplies full unsigned XLEN posM, posK, and ConvGeometry.
posM/posK must be in `0..65535`; they are not low-16 truncated. Omission
supplies zero.

ConvGeometry is:

| Bits | Field |
| --- | --- |
| 7:0 | strideH |
| 15:8 | strideW |
| 23:16 | dilationH |
| 31:24 | dilationW |
| 39:32 | padL |
| 47:40 | padR |
| 55:48 | padT |
| 63:56 | padB |

Zero stride/dilation decodes as one. Legal decoded ranges are Filter 1..511,
Stride 1..63, Dilation 1..255, each Pad 0..255, LogicalC 1..65535 and at most
C1*C0, and derived OutH/OutW 1..65535. Legality arithmetic is mathematical and
never silently wraps.

### Padding Tile

The first B.IOT source is ConvTile. The optional second source is an ordinary
row-major same-dtype padding Tile.

- Constant accepts no padding Tile (raw zero) or a defined 1x1 Tile.
- PerChannel requires a defined 1xLogicalC Tile.
- Source, padding, and destination are pairwise distinct.

Spatial OOB with `channel<LogicalC` uses the selected padding value. A channel
at or above LogicalC always produces raw zero and reads neither source nor
padding. Thus blocked K tails contribute zero independently of spatial
padding.

### Value formula

```text
effective_h = dilationH*(FilterH-1)+1
effective_w = dilationW*(FilterW-1)+1

OutH = floor((H+padT+padB-effective_h)/strideH)+1
OutW = floor((W+padL+padR-effective_w)/strideW)+1

M_total = N*D*OutH*OutW
K_total = C1*FilterH*FilterW*C0
```

The padded input extent is at least the effective filter. M order is N, D,
OutH, OutW. K order is C1, FilterH, FilterW, C0. For `(r,c)`, `m=posM+r` and
`k=posK+c`.

```text
input_h = output_h*strideH + filter_h*dilationH - padT
input_w = output_w*strideW + filter_w*dilationW - padL
```

Bounds are:

```text
posM < M_total
posK < K_total
posM+ValidM <= M_total
posK+ValidK <= K_total
```

There is no M/K alignment requirement. Special ceil formulas do not change the
portable result.

### Direct CUBE destination

TIMG2COL configures:

```text
valid_rows=ValidM
valid_columns=ValidK
layout=CUBE_M32 or CUBE_M16
```

M16 requires ValidM 1..16; M32 requires 1..32. Larger regions use multiple
posM bundles. Storage geometry, b4 interleave, payload indices, and tails reuse
`PTO-CUBE-CELL-STATE-001`. Each logical result writes through
`TileCubePayloadIndex`. Physical tails are raw zero and not valid elements.

TIMG2COL copies raw bits and produces no numeric flag. Complete schema,
descriptor, geometry, source/padding definedness, capacity, and allocation
preflight precedes atomic publication.

## TMATMUL convolution profile

### Operand dependency

The required Local CUBE Matrix contract is:

- A: CUBE_M16/M32, MxK;
- B: CUBE_N8, KxN;
- C/D: A's M layout class, MxN;
- Bias: ordinary row-major 1xN accumulator type;
- MX scales: ordinary row-major E8M0 with existing derived shapes.

Baseline main does not yet consume these persistent layouts in Matrix
legality. This RFC depends on PR #109 or an equivalent accepted clause before
end-to-end execution can be claimed.

### Numeric subset

- S8xS8 -> S32 accumulator/destination/Bias;
- accepted FP16/BF16/FP32/TF32/HF32/HiF8/E4M3/E5M2 pairs -> FP32;
- separately accepted MX pairs with E8M0 scales -> FP32.

Other CUBE dtype decisions remain independent.

S8 multiplies exactly, accumulates in increasing K, and wraps to S32 after
each addition. Bias is added once after K and wraps once. No trap or saturation
occurs. Any mathematical overflow sets CUBE.IOV.

Floating/MX processes increasing K, applies each scale before FMA, and performs
one RNE FP32 rounding per fused term. Bias is added after K with one RNE
rounding. Inputs preserve subnormals, results use gradual underflow, tininess is
after rounding, UF requires tiny+inexact, OF also sets NX, sNaN/invalid sets NV,
and any NaN/Inf input sets CUBE.NANINF_INPUT. TMATMUL does not produce DZ.

Only committed operations register sticky flags.

## Explicit PostProcess and FIXPIPE normalization

```text
P = TMATMUL(..., CUBE B.FPATR numeric None)
Q = TMOV M322ND/M162ND(P, optional B.FPATR stage 1)
E = one or more explicit TEPL elementwise operations(Q, explicit operands)
R = TMOV(E, optional B.FPATR stage 2)
L = optional TTRANS(R, explicit layout)
TSTORE(L) or TSTORE(R)
```

CUBE retains exactly one mandatory B.FPATR. In this explicit path its
PreQuantMode/ReLU are None so the accumulator remains visible; RowMax/GroupMax
may remain independently enabled.

TMOV Layout 24/25 reads CUBE_M32/M16 and publishes ordinary ND:

```text
LB0=ValidN (default source columns)
LB1=ValidM (default source rows)
LB2=PhysicalCol (default ValidN)
LB3/LB4 absent
```

CUBE source and ordinary destination are distinct.

B.FPATR applicability becomes:

- CUBE Matrix: exactly one;
- TMOV/TSTORE: zero or one, omission means canonical numeric None;
- other operations reject unless separately assigned.

Outside CUBE, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, and MaxAbsEn are
zero. ElementWiseEn stays zero because TEPL is explicit. If PR #110 assigns
TransA/TransB bits 7/8, they remain CUBE-only and zero elsewhere.

Memory-plus-PostProcess TSTORE may use:

| B.IOR | RegSrc0 | RegSrc1 | RegSrc2 |
| ---: | --- | --- | --- |
| 0 | GM base | byte row stride | zero |
| 1 | scalar QuantParam | scalar LReLUParam | zero |

Vector parameters are explicit Tiles.

For final TMOV/TSTORE, B.DATR.CMode is a BitMask view: 0 none, 1..7 clear the
lowest N bits after conversion and before layout/memory. It is legal only for
8-bit integer or S16/U16 outputs. CMode 6/7 become decoder-assigned but remain
illegal for comparison operations.

The former LayoutAux is deleted. FP32 split, S8/S4 merge, and C0 padding derive
from dtype, logical C, and destination layout rather than a second control.

## Output layout through TTRANS

Layout=0 keeps existing 2-D transpose. Layout 12,14,16,19 selects an ND output
transform with:

```text
LB0=N, LB1=D, LB2=H, LB3=W, LB4=C
```

The ND source has `rows=N*D*H*W` and `valid_columns=C`. Row decomposition is:

```text
m = (((n*D+d)*H+h)*W+w)
```

Destination order is:

```text
NHWC      [n,h,w,c]
NCHW      [n,c,h,w]
NC1HWC0   [n,c/C0,h,w,c%C0]
NDC1HWC0  [n,d,c/C0,h,w,c%C0]
```

NC1HWC0/NCHW/NHWC require D=1. NDC1HWC0 accepts positive D. C1 is
`ceil(C/C0)`. Blocked tail lanes are raw zero and defined. TTRANS performs no
numeric conversion and rejects B.FPATR. Complete preflight precedes atomic
publication.

## Block-local diagnostics and STATUS

Add 64-bit read-clear base SSR `STATUS` at `0x0002`.

| Bits | Producer bank |
| --- | --- |
| 7:0 | FP |
| 15:8 | VEC |
| 23:16 | SFU |
| 31:24 | CUBE |
| 39:32 | TLSU |
| 47:40 | PostProcess |
| 63:48 | reserved zero |

Each bank uses bit 0 NV, 1 DZ, 2 OF, 3 UF, 4 NX, 5 IOV, 6 NANINF_INPUT, and
7 reserved zero. These are non-trapping sticky diagnostics; synchronous
`Fault_*` state remains separate.

Current CORE_STATE FFLAGS behavior remains. Every committed IEEE flag event
continues to OR into CORE_STATE[36:32] and also into the current producer bank.
IOV/NANINF_INPUT exist only in STATUS. Reading STATUS clears its banks but not
CORE_STATE.

Reset and BSTART clear banks; BSTOP retains them. Only committed operations
update. Rejected, killed, squashed, and uncommitted replay attempts do not.
Faulting operations publish no provisional flags. Earlier committed banks are
trap-saved and restored; successful replay registers once.

These six banks are producers, not six new Tile engines. VEC, SFU, TLSU, and
CUBE remain the four semantic Tile engines.

## Faults, aliases, and ordering

- Reserved encodings: `Fault_IllegalInstruction`.
- Duplicate/surplus headers: `Fault_BundleControl`, preserving the first.
- Recognized incompatible tuple: `Fault_TileLegality`.
- Legal descriptor exceeding TSize: `Fault_TileAllocation`.
- GM access failure: current precise data fault.

ConvTile source, padding Tile, and TIMG2COL destination are pairwise distinct.
Every producer snapshots sources before writes. Memory operations preflight the
whole footprint. Failure exposes no partial descriptor, allocation, payload,
definedness, diagnostic, memory event, or GM effect.

TIMG2COL and Tile-to-Tile transforms add no memory ordering. TLOAD/TSTORE keep
PTO-TSO and B.CATR aq/rl behavior.

## Open-PR coordination

At the baseline:

- PR #109 owns Local CUBE Matrix operand roles required here.
- PR #110 proposes B.FPATR TransA/TransB bits; they remain CUBE-only.
- PR #111 proposes distinct accumulator output rules; this RFC follows the
  accepted final C/D alias decision without allocating another alias bit.
- PR #72 remains the umbrella CUBE implementation and must not reassign Layout
  21..26 or restore incompatible row-major assumptions.

## Landing sequence

1. LB0..LB4, ordered B.IOR, minimal ConvTile sidecar, byte-strided transport.
2. Per-bundle TIMG2COL with explicit padding and CUBE_M output.
3. Local CUBE operand integration and convolution numeric subset.
4. B.FPATR applicability, CUBE-to-ND TMOV, BitMask, explicit PostProcess.
5. TTRANS output layouts.
6. Producer banks and STATUS.
7. End-to-end decoded convolution and release closure.

Each normative PR changes its ASL owner first, adds exact mirrored AVS points,
and regenerates all projections.

## Executable evidence

Evidence includes:

- LB3/LB4 decode, write-once, reserved values, defaults, and trap recovery;
- existing one-B.IOR schemas plus exact two-entry, surplus, reordered, and
  duplicate cases;
- ConvTile sidecar lifecycle and generic-operation rejection;
- dense and explicit-byte-stride NC1HWC0/NDC1HWC0 TLOAD/TSTORE, including b4;
- every TIMG2COL geometry/default/range, padding mode, logical-channel tail,
  M/K order, offset, M16/M32 CELL mapping, and atomic rejection;
- S8 wrap/IOV and FP/MX RNE, scale, Bias, exceptional value, and status rules;
- mandatory CUBE and optional TMOV/TSTORE B.FPATR schemas;
- explicit TEPL visibility, BitMask ordering, and TTRANS layouts;
- STATUS collision, banks, CORE_STATE double projection, lifecycle, trap, and
  replay behavior.

For each implementation PR:

```bash
make pr-check
make repo-check
git diff --check
```

Release evidence requires the current exact-head manual release lane.

## Completion criteria

The RFC is complete when no convolution geometry persists between bundles;
five LBs and exact B.IOR schemas carry all parameters; ConvTile GM strides use
accepted byte units; TIMG2COL implements the floor formula directly into
CUBE_M; TMATMUL consumes persistent CUBE layouts with fixed convolution numeric
semantics; PostProcess and output layout remain explicit; STATUS adds
block-local diagnostics without changing CORE_STATE lifetime; every failure is
pre-effect; and ASL, generated docs, catalogs, decoder witnesses, NDF
traceability, tests, and release evidence agree.
