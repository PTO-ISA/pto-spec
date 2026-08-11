# ADR 0065: CUBE CELL Layouts and TMATMUL Shape Model

- **Status**: accepted; DESIGN handoff frozen
- **Date**: 2026-08-11
- **Deciders**: PTO ISA maintainers
- **Issue**: [#65](https://github.com/PTO-ISA/pto-spec/issues/65)
- **Baseline**: `d5909a28d0fc057aa2167df082d551a2ace5f41a`
- **Scope**: PTO ISA and executable ASL in `pto-spec`
- **Upstream input**: public CUBE layout PR #33, merge commit
  `95d1340b46a5c16dd65a40fee4652fc02095fe35`

## Purpose

This record captures the architecture discussion needed to bring the v5 CUBE
CELL layouts into PTO ISA. It is the durable design source for a later APPLY
handoff. It does not change normative ASL, generated instruction pages, or
encodings.

The upstream PR defines the byte arrangement inside one 128-byte CELL. The PTO
work additionally has to define persistent Local Tile layouts, multi-CELL
geometry, GM-to-Local conversion, PE-level versus group-level matrix
multiplication, arbitrary valid tails, Shared-input transpose, and accumulator
aliasing.

## Source boundary

The upstream source defines:

- PE-level MMA with Local A, Local B, and Local C/D;
- group-level GMMA with per-PE Local A/C/D and a group-shared B;
- the `m32`, `m16`, and `n8` 128-byte CELL arrangements;
- `m16 b4` interleaving; and
- on-the-fly transpose on the group CUBE Shared-input path.

The upstream source does not define PTO encodings, the PTO persistent Tile
descriptor, multi-CELL order, or the interaction with current PTO valid-region
and accumulator semantics. Those points are owned by this design.

## Settled architecture decisions

### Persistent Local Tile layouts

PTO adds three persistent Local Tile layouts:

- `CUBE_M32` for A, C, and D;
- `CUBE_M16` for A, C, and D; and
- `CUBE_N8` for PE-level B.

The layout is descriptor state, not merely a transfer mode. Its element
mapping is parameterized by the Tile data type. In particular, `CUBE_M16` does
not have one dtype-independent byte permutation.

The persistent descriptor records only this layout class and its derived
storage geometry. `CUBE_M32` and `CUBE_M16` are one generic M-layout storage
class; `CUBE_N8` is the B-layout storage class. Because decoded `ND2M*`
conversions carry no A/C/D role discriminator, the descriptor does not record
or default A, C, or D identity. Matrix operand binding resolves that identity
when a later operation consumes the tile.

Shared Tiles do not support any CUBE layout. A Shared Tile remains an ordinary
two-dimensional Tile. It carries no persistent ND/DN orientation metadata.

### `B.DATR` names conversions, not bare CUBE layouts

The six GM/Local conversion spellings are:

| Direction | `B.DATR.Layout` spelling |
|---|---|
| GM ordinary to Local `CUBE_M32` | `ND2M32` |
| GM ordinary to Local `CUBE_M16` | `ND2M16` |
| GM ordinary to Local `CUBE_N8` | `ND2N8` |
| Local `CUBE_M32` to GM ordinary | `M322ND` |
| Local `CUBE_M16` to GM ordinary | `M162ND` |
| Local `CUBE_N8` to GM ordinary | `N82ND` |

The five-bit `B.DATR.Layout` values are fixed as follows:

| Value | Spelling |
|---:|---|
| 21 | `ND2M32` |
| 22 | `ND2M16` |
| 23 | `ND2N8` |
| 24 | `M322ND` |
| 25 | `M162ND` |
| 26 | `N82ND` |

These conversions are legal only for GM-to-Local `TLOAD` and Local-to-GM
`TSTORE`, in the indicated direction. GM/Shared transfer remains a raw
base-plus-row-stride ordinary two-dimensional transfer and performs no CUBE
conversion. Local/Shared CUBE conversion is outside the first change.

The conversion spelling determines the persistent destination or required
source layout. It does not cause an arbitrary in-place reinterpretation of an
existing Tile payload.

Layout conversion preserves dtype and every element's raw representation. It
performs no PostProcess conversion and is not `TCVT`; rounding, saturation,
and numerical canonicalization are not part of the conversion. Every existing
dtype with a defined b32, b16, b8, or b4 CELL mapping may use the matching
conversion. b64 is illegal because this decision defines no b64 CELL.
Matrix-operation legality separately restricts which A/B/C/D dtype
combinations `TMATMUL` may consume or produce.

### One CELL is 128 bytes

Let `X` denote K for A and N for C/D. The per-CELL geometry is:

| Layout | element width | CELL logical shape |
|---|---:|---|
| `CUBE_N8` | b32 | `[K=4, N=8]` |
| `CUBE_N8` | b16 | `[K=8, N=8]` |
| `CUBE_N8` | b8 | `[K=16, N=8]` |
| `CUBE_N8` | b4 | `[K=32, N=8]` |
| `CUBE_M32` | b32 | `[M=32, X=1]` |
| `CUBE_M32` | b16 | `[M=32, X=2]` |
| `CUBE_M32` | b8 | `[M=32, X=4]` |
| `CUBE_M32` | b4 | `[M=32, X=8]` |
| `CUBE_M16` | b32 | `[M=16, X=2]` |
| `CUBE_M16` | b16 | `[M=16, X=4]` |
| `CUBE_M16` | b8 | `[M=16, X=8]` |
| `CUBE_M16` | b4 | `[M=16, X=16]`, special interleave |

For `CUBE_M16` b4 and a fixed M row, the two 32-bit words contain:

```text
word 0: x0 x1 x2 x3 x8  x9  x10 x11
word 1: x4 x5 x6 x7 x12 x13 x14 x15
```

All other rows use the ordinary CELL rule supplied by the upstream layout:
the X/K direction is the fast logical direction and M/N is the slow logical
direction, subject to the element packing rules of the selected dtype.

The b8 and b4 `CUBE_N8` rows are PTO design extensions of the upstream table,
which explicitly showed only f32 and f16.

### Multi-CELL storage geometry

The persistent descriptor records storage geometry separately from valid
geometry, without retaining matrix operand identity. Software supplies layout,
dtype, valid dimensions, and capacity
through the existing bundle descriptors. The architecture derives the minimal
storage geometry by applying the layout's CELL-alignment formulas below and
retains that geometry in the allocated Tile descriptor. No new encoded
storage-dimension field is introduced. A hardware implementation may store an
equivalent compact descriptor or rederive fields that are functionally
determined.

For A in `CUBE_M32` or `CUBE_M16`, CELLs repeat only in K:

```text
K_repeat = ceil(storage_K / K_per_cell)
cell_count = K_repeat
```

For C and D in `CUBE_M32` or `CUBE_M16`, CELLs repeat only in N:

```text
N_repeat = ceil(storage_N / N_per_cell)
cell_count = N_repeat
```

For PE-level B in `CUBE_N8`, CELLs repeat in both K and N. K repeat is the
faster CELL direction and N repeat is the slower CELL direction:

```text
K_repeat = ceil(storage_K / K_per_cell)
N_repeat = ceil(storage_N / 8)
cell_index(n_cell, k_cell) = n_cell * K_repeat + k_cell
cell_count = K_repeat * N_repeat
```

For example, a b16 B Tile with storage shape `[K=13,N=19]` has
`K_repeat=2`, `N_repeat=3`, six CELLs, storage-aligned shape `[K=16,N=24]`,
and CELL order `(n0,k0), (n0,k1), (n1,k0), (n1,k1), (n2,k0), (n2,k1)`.

Changing a valid region within the recorded storage geometry does not
reinterpret payload bytes. A change that requires different repeat counts or
CELL strides requires a new allocation/load/repack rather than descriptor-only
reinterpretation.

### Valid geometry and padding

Valid M, N, and K are arbitrary positive integers within the storage geometry;
they are not restricted to powers of two. `M=0` on an active matrix operation
is illegal.

ADR 0054's zero-PE-mask precedence remains unchanged. A zero mask is a strict
no-op before active-operation shape checks, so an encoded `M=0` under a zero
mask has no effect and does not fault. `M=0` is illegal only when the resolved
operation has a nonzero PE mask.

There is one invalid/padding semantic class. Positions outside the valid
region, whether they are inside a partially valid CELL or in a wholly unused
CELL, are not matrix operands. CUBE does not compute them, GM-to-Local load
does not read GM for them, and Local-to-GM store does not write GM for them.
Their Local payload state is undefined.

The current dense `rows * columns == capacity` shape model is therefore not
sufficient. CUBE descriptors require layout-specific functions for:

- CELL shape by layout and dtype;
- storage-aligned dimensions;
- repeat counts and CELL count;
- required byte capacity;
- logical-element-to-payload mapping; and
- valid-region legality.

For CUBE layouts, required bytes may be less than the allocated `TSize`, but
must not exceed it. Ordinary dense Tile behavior is unchanged unless separately
specified.

### PE-level and group-level `TMATMUL`

Both execution forms use the existing `BSTART.TMATMUL` family and are described
in the same instruction document. They are distinguished from the resolved
operand bindings, not by a persistent `MShard4` or group/PE tag in a Tile.

PE-level form:

- A is Local `CUBE_M32` or `CUBE_M16`;
- B is Local `CUBE_N8`;
- C and D are Local and use the M layout class required by A;
- K and N may span multiple CELLs; and
- the encoded M/N/K are PE-local operation dimensions;
- `CUBE_M16` requires `1 <= valid_M <= 16`; and
- `CUBE_M32` requires `1 <= valid_M <= 32`.

Group-level form:

- at least the broadcast operand is Shared and ordinary;
- A may be per-PE Local CUBE layout or an ordinary Shared input according to
  the selected schema;
- B is an ordinary Shared input;
- C and D are per-PE Local CUBE layouts; and
- all four PEs execute the group operation in lockstep.

No persistent `MShard4` descriptor is added. `MShard4` describes operation-time
row distribution only. The group instruction carries a core-level valid M:

```text
1 <= group_valid_M <= 64   => required layout CUBE_M16, M_per_PE = 16
65 <= group_valid_M <= 128 => required layout CUBE_M32, M_per_PE = 32
otherwise                  => illegal

pe_valid_M(i) = clamp(group_valid_M - i * M_per_PE, 0, M_per_PE)
```

A derived `pe_valid_M(i)=0` means that PE contributes no rows; it is not an
encoded group `M=0`. Each PE's private destination descriptor records its own
local valid M. Group M/N/K are not copied into a persistent group-layout tag.

For a group operation with a Local A, A's layout must match the class derived
from `group_valid_M`. For a group operation with two Shared inputs, the same
valid-M rule selects the destination C/D layout.

N is not limited to 8 for PE-level matrix multiplication. The instruction's K,
N, and B capacity determine the `CUBE_N8` K-by-N CELL grid. Software splits M
or N only when the required persistent Tile exceeds the selected `TSize` or an
operation limit; N=8 is a CELL width, not the architectural instruction limit.

### Shared-input transpose

`B.FPATR` gains independent one-bit `TransA` and `TransB` controls appended to
the existing canonical assembly field list. `TransA` is bit 7, `TransB` is bit
8, and bits `[10:9]` remain reserved zero. `B.FPATR` remains mandatory for the
matrix family; canonical no-transpose encodes both fields as zero rather than
omitting the command. A control is legal only when the corresponding A or B
source is Shared. PE-level matrix multiply requires both controls to be zero.
A group form with only Shared B requires `TransA=0` and may use `TransB`; a
two-Shared-input form may use both controls independently.

Shared Tiles remain ordinary 2D Tiles. CUBE reads the ordinary logical matrix
using its descriptor and Shared transfer stride, applies the requested logical
transpose after the read, and then consumes the normalized matrix with K as
the reduction/continuous direction expected by the array. No ND/DN identity
is persisted or checked.

The canonical assembly is extended by explicit trailing `TransA, TransB`
operands. Setting a transpose bit for a Local operand is illegal rather than
ignored.

### C/D type, layout, and `TMATMUL_ACC`

C and D use the same M layout class as A, but the exact byte mapping remains
parameterized by each Tile's dtype. Therefore a final quantized D may be the
same `CUBE_M16` or `CUBE_M32` class as C while having different storage
geometry.

`TMATMUL_ACC` has this dataflow:

```text
P = C + A * B        // accumulator domain: FP32 or S32
D = PostProcess(P)   // destination dtype may differ
```

For a non-final K chunk, C and D remain FP32/S32 accumulator Tiles and D may be
used as the next C. For the final quantizing chunk, C remains FP32/S32 while D
may have a lower or otherwise different dtype; that D is not a later
accumulator input.

`D == C` is legal only for the non-final accumulator-preserving case, with the
same accumulator dtype, CUBE layout class, storage geometry, and capacity. The
operation observes a snapshot of C before writing D. Final quantization with a
different dtype or storage geometry requires distinct C and D Tiles and is not
an atomic in-place replacement.

The existing ASL accumulator legality must consequently stop reusing
destination-output legality for C.

## Explicitly deferred work

The first implementation does not add:

- GM/Shared CUBE conversion;
- Local/Shared CUBE conversion or CUBE-aware `TMOV`;
- generic VEC, SFU, reduction, or rearrangement support for CUBE layouts;
- arbitrary CUBE-to-CUBE conversion; or
- release/V2 artifact generation.

The architecture may later define which additional instructions can consume or
produce CUBE layouts. Until then, CUBE layouts are accepted only by the
GM/Local `TLOAD`/`TSTORE` conversion paths and the matrix-multiply family
defined here.

## Current-contract conflicts to supersede

- ADR 0054 states that `MShard4` encodes per-PE M and derives
  `group_M=4*pe_M`. This design keeps per-PE `TSize` and common group N/K, but
  supersedes that M rule for group `TMATMUL`: its valid M is core-level and
  each PE derives a possibly different local valid M.
- `PTO-TILE-MODEL-SHAPE-ROWS-COLUMNS` requires power-of-two columns and exact
  dense capacity. CUBE storage geometry requires arbitrary positive valid
  dimensions and layout-specific capacity.
- `PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS` only interprets row-major and
  column-major payloads. It needs defined CUBE mappings.
- `PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE` requires every matrix valid dimension
  to be a nonzero power of two and currently treats the accumulator as though
  it had the destination's post-process dtype and geometry.
- `PTO-BLOCK-B-DATR` exposes accepted opaque target layout codes but no
  normative conversion meaning for the six new spellings.
- `PTO-BLOCK-B-FPATR` leaves bits `[10:7]` reserved and has no transpose state.

## APPLY acceptance criteria

1. The ASL state model has explicit persistent `CUBE_M32`, `CUBE_M16`, and
   `CUBE_N8` layouts with dtype-parameterized CELL mappings, including the
   `CUBE_M16` b4 interleave.
2. Multi-CELL A, B, C, and D mappings match this record, including B's
   K-fast/N-slow CELL order and distributed K/N tails.
3. Arbitrary positive valid M/N/K values are accepted when within storage
   geometry and operation limits; active `M=0` is rejected.
4. `TLOAD`/`TSTORE` implement exactly the six GM/Local conversion directions;
   GM/Shared and Local/Shared remain ordinary and non-converting.
5. PE-level and group-level `TMATMUL` are selected from operand bindings and do
   not depend on persistent `MShard4` metadata.
6. Group valid M chooses M16/M32 at 64/65, derives four local valid-M values,
   and rejects values above 128.
7. `TransA` and `TransB` affect only corresponding Shared inputs and normalize
   the logical operand before matrix multiplication.
8. `TMATMUL_ACC` accepts FP32/S32 C independently of a quantized D type;
   accumulator-preserving in-place aliasing works and final-quantizing aliasing
   is rejected.
9. Focused executable tests cover every CELL dtype row, repeat-boundary tails,
   M values 1/64/65/128, invalid M values, transpose legality, quantized ACC,
   aliasing, capacity overflow, zero mask, and no-effect-on-fault behavior.
10. Catalogs, generated Markdown, runtime mirrors, source indices, and V1
    checks agree with normative ASL.

## Freeze conclusion

The DESIGN contract is frozen. All architecture-visible choices needed by
APPLY are resolved, including the six layout encodings, dtype-preserving
width-based layout conversion, `B.FPATR` transpose bits, zero-mask precedence,
CELL mappings, repeat order, group-M derivation, and accumulator aliasing.

The exact ASL representation of per-PE private descriptors is not considered
an open architecture choice if it preserves the observable contract above.
The executor may use per-PE records or an equivalent mechanically derived
representation, but may not introduce shared persistent `MShard4` metadata.

## Frozen PTO ISA handoff

### Contract refs

- PTO ISA NDF architecture issue
  [#65](https://github.com/PTO-ISA/pto-spec/issues/65).
- ADR 0065, this document.
- ADR 0054 for per-PE `TSize`, fixed PE identities, Shared binding, and
  zero-mask strict no-op; ADR 0065 supersedes only its group `MShard4` M rule
  for group `TMATMUL`.
- ADR 0064 for complete-bundle PostProcess ordering and state; ADR 0065 refines
  C/D layout, accumulator input, and in-place-alias legality.
- Upstream layout input: public CUBE layout PR #33, merge commit
  `95d1340b46a5c16dd65a40fee4652fc02095fe35`.

### Baseline

`d5909a28d0fc057aa2167df082d551a2ace5f41a`

### Affected PTO clauses

- `PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES`
- `PTO-BLOCK-B-DATR`
- `PTO-BLOCK-B-DIM`
- `PTO-BLOCK-B-FPATR`
- `PTO-TILE-MODEL-STATE-DESCRIPTORS`
- `PTO-TILE-MODEL-SHAPE-ROWS-COLUMNS`
- `PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS`
- `PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE`
- `PTO-TILE-TLOAD`
- `PTO-TILE-TSTORE`
- the accepted `TMATMUL`, `TMATMUL_BIAS`, `TMATMUL_ACC`, and MX matrix-family
  instruction clauses and their shared CUBE execution owners

### Behavioral delta

- Add persistent Local layouts `CUBE_M32`, `CUBE_M16`, and `CUBE_N8` with the
  exact dtype-parameterized 128-byte CELL and multi-CELL mappings in ADR 0065.
- Assign `B.DATR.Layout` values 21 through 26 to `ND2M32`, `ND2M16`, `ND2N8`,
  `M322ND`, `M162ND`, and `N82ND`; implement them only on GM/Local
  `TLOAD`/`TSTORE`. They preserve dtype and perform no numerical conversion.
- Replace dense power-of-two-only shape assumptions for CUBE layouts with
  persistent storage geometry, arbitrary positive valid geometry, and
  layout-specific capacity/indexing. Derive the minimal aligned storage
  geometry from existing valid dimensions; add no storage-dimension encoding.
- Resolve PE-level versus group-level matrix behavior from operand bindings in
  the existing `BSTART.TMATMUL` family. Do not persist `MShard4` metadata.
- For group `TMATMUL`, treat encoded valid M as core-level: 1..64 selects M16,
  65..128 selects M32, and each PE derives its own local valid M.
- Add `B.FPATR.TransA=[7]` and `TransB=[8]`; bits `[10:9]` stay reserved zero.
  Each transpose is legal only for its corresponding Shared source.
- Separate FP32/S32 accumulator-input legality from post-processed D legality.
  Permit read-old/write-new `D==C` only for accumulator-preserving output and
  reject final-quantizing in-place aliasing.

### Protected / unchanged

- Per-PE `TSize`, fixed mask-to-PE identities, transactional preflight, and
  zero-mask strict no-op from ADR 0054 remain unchanged. Zero mask suppresses
  active M legality; nonzero-mask `M=0` is illegal.
- Existing `B.DIM` forms remain the dimension carriers. CUBE storage geometry
  is derived and persisted; no additional dimension command is introduced.
- Shared Tiles remain ordinary 2D Tiles without persistent ND/DN or CUBE
  metadata. GM/Shared is raw base-plus-row-stride transfer with no conversion.
- Local/Shared conversion, generic VEC/SFU/rearrangement support for CUBE
  layouts, and arbitrary CUBE-to-CUBE conversion remain out of scope.
- Existing TMATMUL dtype-profile legality remains independent of layout
  transfer legality. Layout conversion does not widen the legal matrix profile.
- PostProcess still consumes the full accumulator result before producing D;
  a final quantized D is not a later `TMATMUL_ACC` accumulator.

### Acceptance

1. Decoded GM/Local `TLOAD` and `TSTORE` prove all six exact encodings and
   directions, dtype preservation for b32/b16/b8/b4, b64 rejection, correct
   CELL bytes including M16-b4, repeat-boundary tails, and no GM access outside
   the valid region. Shared and Local/Shared forms reject CUBE conversion.
2. Decoded PE-level matrix operations prove Local M32/M16 A/C/D, Local N8 B,
   K-fast/N-slow B repeats, N greater than 8, arbitrary valid K/N tails,
   capacity bounds, and no computation outside valid geometry.
3. Decoded group-level matrix operations prove M boundaries 1, 64, 65, and
   128, per-PE valid-M derivation including inactive zero-row PEs, rejection of
   active M=0 and M>128, and zero-mask no-effect even with M=0.
4. Decoded Shared-input paths prove independent TransA/TransB behavior,
   mandatory `B.FPATR`, canonical explicit zero-bit no-transpose, reserved
   `[10:9]` rejection, Local-source transpose rejection, and correct logical
   results after transpose.
5. Decoded `TMATMUL_ACC` proves FP32/S32 C with a differently typed final D,
   accumulator-preserving read-old/write-new aliasing, final-quantizing alias
   rejection, and no partial destination or memory effect on every fault.
6. Normative owners, catalogs, generated Markdown, navigation, runtime mirrors,
   traceability, and the acceptance-to-test evidence matrix agree at the final
   candidate HEAD.

### Validation

V1. Run focused generation and executable evidence while iterating, then the
current repository PR gates `make pr-check`, `make repo-check`, and
`git diff --check` against the final candidate. Do not run V2/release work.

### Executor effort

XHigh. APPLY crosses complete-bundle encoding/state, persistent descriptors,
non-dense indexing, memory effects, group execution, aliasing, and a broad
decoded negative-path matrix.

### Staged APPLY orchestration

APPLY remains one architecture change, one implementation branch, one final
PR, and one user-facing conversation. ADR 0065 is the single frozen
architecture contract. The stages below are execution subcontracts derived
from it; they are not independent architecture contracts and may not override
it.

Stages execute strictly in order with at most one APPLY executor active. Each
stage uses a fresh Luna XHigh executor in the same root conversation and starts
from the exact checkpoint HEAD accepted for the preceding stage. The parent
Sol session performs the `pto-isa-iterate` light semantic review after every
stage. A later executor may accommodate reviewed earlier work but may not
revert or reinterpret it. No stage is pushed or opened as a separate PR.

| Stage | Execution subcontract | Required checkpoint |
|---|---|---|
| A | Add the three persistent CUBE layouts, dtype-specific CELL mappings, derived storage geometry, arbitrary valid-region support, layout-specific indexing, capacity, and definedness. Do not yet accept new transfer encodings. | Focused mapping/shape evidence covers every width, M16-b4, repeat boundaries, arbitrary tails, capacity overflow, and descriptor persistence. Sol accepts the state-model diff and pins the checkpoint HEAD. |
| B | Add `B.DATR.Layout` values 21 through 26 and close GM/Local `TLOAD`/`TSTORE` conversion legality, memory effects, faults, and decoded evidence in the same stage. | All six directions, b32/b16/b8/b4 raw preservation, b64 rejection, no access outside valid geometry, and Shared/Local-Shared rejection pass through decoded normal paths. Sol accepts the TLSU diff and pins the checkpoint HEAD. |
| C | Close the complete matrix family together: PE/group binding topology, group valid-M derivation, `B.FPATR.TransA/TransB`, Shared logical transpose, C/D layout derivation, `TMATMUL_ACC` accumulator typing, PostProcess output, aliasing, transactional faults, and decoded evidence. | M boundaries, N greater than 8, K/N tails, transpose/default/reserved cases, quantized final D, alias read-old/write-new, zero mask, and no-effect-on-fault are observable through decoded paths. Sol accepts the CUBE diff and pins the checkpoint HEAD. |
| D | Perform integration closure only: programming guidance, generated projections, catalogs, navigation, traceability, acceptance-to-test matrix, regression repair, scope audit, and final V1 gates. | Final candidate passes focused checks, `make pr-check`, `make repo-check`, and `git diff --check`; Sol performs the final semantic review before any authorized push or PR creation. |

At each checkpoint the executor returns the exact HEAD, normative owners and
direct consumers changed, acceptance-to-test mapping, commands and results,
projection status, protected dirty files, and escalation status. A failed
mechanical or evidence check remains in the same stage for correction. Any new
architecture choice or material contract conflict stops the sequence and
returns to Sol and, when necessary, the user; later stages do not work around
it.

### Implementation-sensitive rationale

- N=8 is a CELL dimension, not a PE-level instruction limit.
- B repeats K first and N second, so K and N padding are distributed through
  the CELL grid rather than represented as one compact trailing pad.
- Storage geometry is persistent; changing repeat counts cannot reinterpret an
  existing payload by changing only valid dimensions.
- CUBE layout class equality does not imply byte-layout equality when C/D
  dtypes differ.

### Escalate

Stop for any new architecture choice, material conflict with accepted ASL/ADR,
need to broaden the explicitly deferred instruction scope, or inability to
produce normal decoded-path evidence for an acceptance claim. The implementation
and PR must remain linked to NDF architecture issue #65 and this baseline;
neither link is license to invent or alter semantics.
