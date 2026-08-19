# Portable ConvTile and TIMG2COL Design

## Outcome

Add a portable convolution-tile descriptor and replace the current simplified
two-dimensional `TIMG2COL` model with an exact multidimensional image-to-column
transform.

The accepted operation remains one direct Tile operation at TEPL selector
`0x064`. Its binary semantic interface is
`TIMG2COL(destination, source, padding, posM, posK)`. It reads convolution
geometry from the source ConvTile descriptor, reads constant or per-channel
padding from an explicit ordinary Tile, and writes one ordinary matrix Tile.
The public four-argument intrinsic lowers its source-level padding metadata to
that explicit padding operand. The operation does not depend on hidden FMATRIX
registers, body-local queues, or target pipelines.

This design is the first of four ordered convolution changes:

1. ConvTile state and `TIMG2COL`;
2. `TMATMUL` arithmetic and accumulation rules;
3. portable FIXPIPE/PostProcess value and layout semantics;
4. end-to-end convolution composition and closure evidence.

The later changes depend on this descriptor and indexing contract. They receive
separate designs and implementation plans so that matrix arithmetic and
post-processing do not destabilize the convolution input model.

## Requirements and authority

This change adds two PTO-owned requirements:

- `PTO-REQ-CONVTILE-001`: the architecture represents a fixed-capacity,
  rank-five or rank-six convolution Tile with explicit logical shape, layout,
  geometry, padding, payload, and definedness;
- `PTO-REQ-TIMG2COL-001`: `TIMG2COL` produces a deterministic matrix slice from
  a legal ConvTile, explicit padding values, and `(posM, posK)`.

The public PTO source snapshot at commit
`8e2f0fa10ddc1e887ac2e102666854247aee9b77` supplies the intrinsic signature,
ConvTile type surface, supported source layouts, and reference indexing order.
The relevant public sources are:

- [ConvTile programming model](https://github.com/PTO-ISA/pto-isa/blob/8e2f0fa10ddc1e887ac2e102666854247aee9b77/docs/coding/ConvTile.md);
- [TIMG2COL operation page](https://github.com/PTO-ISA/pto-isa/blob/8e2f0fa10ddc1e887ac2e102666854247aee9b77/docs/isa/tile/ops/layout-and-rearrangement/timg2col.md);
- [public Tile type definitions](https://github.com/PTO-ISA/pto-isa/blob/8e2f0fa10ddc1e887ac2e102666854247aee9b77/include/pto/common/pto_tile.hpp);
- [public intrinsic declarations](https://github.com/PTO-ISA/pto-isa/blob/8e2f0fa10ddc1e887ac2e102666854247aee9b77/include/pto/common/pto_instr.hpp);
- [CPU reference indexing](https://github.com/PTO-ISA/pto-isa/blob/8e2f0fa10ddc1e887ac2e102666854247aee9b77/include/pto/cpu/TImg2col.hpp).

A user-supplied accelerator ISA manual with SHA-256
`670174008299a58c25b8fc365a079980b4bf663508812d23c11211ed3026055e`
provides independent convolution-window, dilation, padding, matrix-lowering,
and legality evidence. Repository artifacts must not publish that source's
identity, local path, prose, code, diagrams, physical buffer names, or register
names.

The PTO catalog, accepted architecture decision, ASL, and executable tests
become authoritative after this change. External implementation behavior does
not override them.

## Existing specification defects

The current model cannot express the public contract accurately:

- `TileInfo` represents only `rows` and `columns`; it cannot preserve the
  rank-five and rank-six ConvTile shapes consumed by `TIMG2COL`.
- `TIMG2COL` currently accepts kernel, stride, padding extents, and padding
  value as direct semantic operands. The public intrinsic accepts only
  destination, source, `posM`, and `posK`; the source ConvTile owns the other
  metadata.
- The current transform ignores batch, optional depth, channel blocks, channel
  lanes, dilation, asymmetric padding, and partial M/K slices.
- The instruction page describes target-defined configuration while the ASL
  publishes one simplified portable behavior. The two claims are inconsistent.
- The current legality predicate checks destination shape but not the complete
  multidimensional access set or offset bounds.

This change corrects those defects together. It does not retain the simplified
two-dimensional operation as an alias.

## Conflict audit against the current PTO architecture

| Current contract | Conflict | Required extension |
| --- | --- | --- |
| `TileInfo` is always an ordinary two-dimensional descriptor | Rank-five and rank-six ConvTiles cannot use `rows`, `columns`, or generic `TileLinearIndex` without losing architectural dimensions | Add `TileKind` and a bounded `ConvTileInfo` branch while sharing the existing capacity, payload, and definedness storage |
| `TileDescriptorLegal` and almost every direct Tile operation assume ordinary two-dimensional state | An unguarded ConvTile could be consumed accidentally by any existing handler | Make ordinary legality explicitly reject `TileKind_Convolution`; add ConvTile-only legality and indexing helpers used by `TIMG2COL` and ConvTile-aware TLSU |
| `ConfigureTile` and bundle destination resolution create only ordinary Tiles | No accepted binary path can create a ConvTile descriptor | Add an ordered B.IOR descriptor schema for ConvTile-producing `TLOAD` and an operation-specific destination configurator |
| B.IOR values map to `address`, `scalar0`, and `scalar1`; `natural0/1` come from LB0/LB1 | The earlier design incorrectly mapped B.IOR `posM/posK` to `natural0/1` | Bind `posM/posK` as `scalar0/scalar1`, validate their unsigned 16-bit range, and require source two plus destination to select R0 |
| Generic bundle allocation interprets LB0 as rows and LB1 as columns; LB2 is ignored | The published TIMG2COL bundle uses LB0=ValidCol, LB1=ValidRow, LB2=physical Col | Add operation-specific destination descriptor derivation: rows=LB1, columns=LB2, valid rows=LB1, valid columns=LB0 |
| `TileLayout` contains only row-major, column-major, and implementation-defined | NC1HWC0 and NDC1HWC0 must be portable, indexable identities rather than implementation-defined layouts | Add a separate `ConvTileLayout` enumeration; do not add convolution layouts to ordinary `TileLayout` |
| `SharedTileInfo` embeds `TileInfo` and its quarter logic assumes ordinary rows/columns | Embedding ConvTile state could silently make Shared ConvTiles appear legal | Keep ConvTiles Local-only in this change and make every Shared descriptor path reject convolution kind |
| TrapContext does not snapshot Local or Shared Tile registers | The earlier design incorrectly required ConvTile descriptor leaves in TrapContext | Preserve the existing boundary: faults and traps do not rewrite Tile state; retry observes the same ConvTile in place, but TrapContext contains no Tile copy |
| The accepted `0x064` catalog row and tests use a nine-argument ordinary-Tile handler | Current catalog closure proves the wrong semantic shape | Replace the row under the same selector, regenerate decoder/evidence, and require new multidimensional feature tests |
| Current TEPL/TLSU/CUBE counts are frozen at 87/10/12 | Adding a separate Conv instruction would change the release ABI and all closure ledgers | Keep selector `0x064` and the 109-operation total; extend bundle binding and existing TLOAD/TSTORE behavior rather than adding a new selector |

The state, binding, and semantic changes are normative. The selector identity
and direct-operation counts are preserved.

## Downstream TMATMUL and FIXPIPE compatibility

This first change fixes boundaries that the later matrix and post-processing
designs must preserve.

| Downstream area | Current PTO contract | Conflict exposed by the convolution design | Required later extension |
| --- | --- | --- | --- |
| TMATMUL inputs | CUBE accepts ordinary two-dimensional Local or explicit Shared matrices | A ConvTile cannot be passed directly to CUBE without bypassing TIMG2COL | Keep CUBE ordinary-only; TIMG2COL is the sole ConvTile-to-matrix boundary |
| Accumulator state | ACC forms read explicit Local C and write explicit Local D | The reference implementation uses a physical accumulator buffer | Keep PTO's explicit C/D and read-old/write-new alias rule; do not introduce an implicit accumulator singleton |
| Matrix arithmetic | `TileProfileMatrixAccumulate`, bias, scaled accumulation, and conversion remain profile hooks | The requested migration promotes supported reference dtype/accumulation rules to portable results | Add a separate matrix-numeric ADR and replace each accepted reference tuple with pure ASL; retain hooks only for rules not fixed by accepted evidence |
| B.FPATR | The current worktree adds pre-quant, ReLU, row/group max, and max-abs configuration for CUBE | The complete reference FIXPIPE also has post-quant, elementwise, bit mask, channel merge/split, and layout transforms | Extend the machine-readable PostProcess mode/schema contract before claiming complete FIXPIPE coverage; do not treat the current B.FPATR fields as full FIXPIPE |
| FIXPIPE placement | PTO has no architectural pipe state; existing direct operations are TMOV, TSTORE, TEPL, and CUBE | A literal FIXPIPE port would add hidden buffers, stages, and configuration registers | Define FIXPIPE as pure PostProcess value/layout functions invoked by explicit CUBE/TMOV/TSTORE operations; implementation fusion remains invisible |
| Layout-changing postprocess | CUBE destinations are ordinary matrix Tiles and current generic layout support is row/column only | NZ2ND, NZ2DN, channel packing, depth/space, and Winograd post change destination indexing | Add explicit destination layout descriptors and preflight/commit rules in the later PostProcess design; do not mutate ConvTile metadata implicitly |
| Numeric maturity | Current Stage 4 claims are raw-carrier reference totality; Stage 5 numeric conformance is open | Publishing reference quantization, NaN/Inf, rounding, and saturation as portable changes the current maturity boundary | Update numeric decision ledgers, profile-hook ownership, conformance vectors, coverage, and maturity claims together with each accepted numeric subset |

The selected composition remains:

```text
ConvTile --TIMG2COL--> ordinary A matrix
weight Tile ----------> ordinary B matrix
ordinary A,B,[C] --TMATMUL--> complete-K matrix result P
P + explicit parameters --PostProcess/TMOV/TSTORE--> final Tile or memory effect
```

An implementation may fuse these stages, but the architecture observes their
explicit operands, faults, alias rules, and atomic commit boundaries.

## Considered approaches

### Add ConvTile state to each Tile register

This is the selected approach. `TileInfo` gains an explicit kind and a bounded
ConvTile descriptor. Ordinary Tile state keeps its existing two-dimensional
contract. ConvTile state shares allocation, capacity, payload, definedness,
and register identity with ordinary Tiles but uses rank, shape, and convolution
layout for logical indexing.

This approach preserves the six-bit Tile operand namespace and explicit
read-before-write behavior. It avoids a second hidden register file.

### Generalize every Tile operation to one-to-six dimensions

This would remove the distinction between ordinary Tiles and ConvTiles, but it
would force all 109 accepted operations and their legality predicates to
interpret rank and multidimensional layout. Most operations are deliberately
two-dimensional. The wider refactor would obscure this change and increase
regression risk without improving `TIMG2COL`.

### Flatten ConvTile into a two-dimensional Tile

Flattening would preserve the current ASL types, but it would lose the
architecture-visible distinction among N, D, C1, H, W, and C0. Dilation,
asymmetric padding, `posM`, `posK`, and layout-dependent indexing would then
depend on non-architectural conventions. This approach cannot provide a total
portable transform and is rejected.

## Architecture boundary

The portable model defines:

- ConvTile kind, rank, logical shape, data type, layout, capacity,
  payload, and per-element definedness;
- filter size, stride, dilation, four-sided padding extents, and logical channel
  count;
- constant and per-channel padding through an explicit ordinary padding Tile;
- exact NC1HWC0 and NDC1HWC0 source indexing;
- exact output geometry and M/K linearization;
- exact `(posM, posK)` slicing;
- legality, rejection, source snapshot, and atomic destination commit.

The portable model does not define:

- physical L0/L1/UB/OUT storage names or addresses;
- FMATRIX registers or special-purpose register encodings;
- physical fractal allocation, DMA repetition, unit flags, pipeline latency,
  throughput, or scheduling;
- performance-only alignment or preferred blocking;
- a fused convolution instruction.

Fixed ASL array bounds remain verification bounds. They are not architectural
limits on a conforming implementation's ConvTile capacity or convolution
shape.

## ConvTile state

### Tile kind

Add a `TileKind` enumeration with ordinary and convolution members. Every
allocated Tile register has exactly one active descriptor interpretation.

- An ordinary Tile uses the existing `rows`, `columns`, `valid_rows`,
  `valid_columns`, and `TileLayout` fields.
- A ConvTile uses `ConvTileInfo` and does not expose its multidimensional shape
  through invented ordinary rows and columns.

Changing kind is a reconfiguration. It clears payload definedness exactly as
ordinary Tile reconfiguration does. Failed reconfiguration preserves the old
descriptor and payload.

The existing `TileDescriptorLegal` name remains the ordinary-Tile predicate so
that existing operations fail closed. It first requires
`TileKind_Ordinary`, then applies the existing rows, columns, valid-region,
capacity, and layout checks. New helpers own the convolution branch:

```text
ConvTileDescriptorConfigured
ConvTileDescriptorLegal
ConvTileLinearIndex
ConvTileElementDefined
ConvTileStorageBytes
```

Generic `TileLinearIndex`, `TileLogicalShapeMatch`, TMOV, CUBE, TEPL, and TLSU
operations other than the explicitly extended TLOAD/TSTORE reject convolution
kind. Shared-register descriptor, materialization, compatibility, and atomic
quarter-update paths also reject convolution kind. ConvTiles are Local-only in
this change.

### ConvTile descriptor

`ConvTileInfo` contains:

- `configured`;
- rank in the architectural domain 5 through 6 for the first portable
  convolution contract;
- six positive canonical dimensions ordered N, D, C1, H, W, C0; NC1HWC0
  requires D equal to one;
- layout;
- output-extent mode;
- filter height and width;
- stride height and width;
- dilation height and width;
- padding left, right, top, and bottom;
- logical channel count.

The first accepted `TIMG2COL` source layouts are:

| Layout | Rank | Dimension order |
| --- | ---: | --- |
| `NC1HWC0` | 5 | N, C1, H, W, C0 |
| `NDC1HWC0` | 6 | N, D, C1, H, W, C0 |

Other public ConvTile layouts are outside this first portable descriptor. A
later architecture decision may extend `ConvTileLayout`, but an
implementation-defined layout cannot silently acquire a portable indexing
convention.

Logical dimensions determine both storage strides and the feature-map extent
observed by `TIMG2COL`. ConvTile does not add a second valid-shape tuple. This
matches the public ConvTile type and avoids two competing multidimensional
region contracts. Capacity may exceed the bytes occupied by the logical shape;
the excess is unobservable.

The logical channel count is positive and no greater than
`C1 * C0`. A value smaller than that product makes lanes whose
flattened channel index is at or above the logical channel count padding lanes
rather than source reads.

### Capacity and definedness

The descriptor storage requirement is:

```text
ceil(product(logical_dimensions) * element_bits / 8)
```

It must fit the Tile allocation capacity and the architectural aggregate Tile
capacity. Packed four-bit types retain low-index/low-nibble packing.

ConvTile definedness is per logical element. `TIMG2COL` preflights only the
in-bounds elements selected by its output slice. An out-of-image or
out-of-channel position supplies the padding value and does not require a
defined source element. Every selected in-bounds source element must be
defined before execution begins.

Reset and release set kind to ordinary, clear the complete ConvTile descriptor,
and clear the shared payload/definedness state. Successful ordinary-to-ConvTile,
ConvTile-to-ordinary, or ConvTile-to-ConvTile reconfiguration clears
definedness. Every descriptor and aggregate-capacity check completes before the
old state is changed.

### Trap boundary

Local and Shared Tile registers are persistent architectural state, but they are
not members of the current `TrapContext` snapshot. ConvTile follows the same
rule. Fault entry, trap handling, and ACRE do not copy or restore Tile payloads
or descriptors. A rejected TIMG2COL or ConvTile-aware TLSU attempt preserves the
live ConvTile in place; bundle state needed to retry the attempt remains
trap-preserved through the existing `TrapContext` fields.

The release-traceability state-root inventory expands the `TileInfo` composite
with kind and ConvTile descriptor leaves. The trap-context per-leaf ledger does
not add those leaves because it inventories saved context, not all live
architectural state.

## ConvTile creation and transport

### Required bundle extension

The current binary model can allocate only an ordinary two-dimensional Tile.
ConvTile therefore requires an encoded producer path. This design extends the
existing B.IOR binder semantics instead of allocating a new command opcode or
Tile selector.

B.IOR bindings become an ordered append-only sequence within one bundle. The
existing `BundleScalarBindingSnapshot` already has 32 entries and is already
trap-preserved. A command appends to the first unused entry; overflow or a
binding after a schema-complete sequence raises `Fault_BundleControl` without
replacing an earlier entry. Existing operations that consume one B.IOR retain
their current one-entry schema.

A ConvTile-producing TLOAD uses one ordinary memory binder followed by seven
metadata binders:

| B.IOR index | Source 0 | Source 1 | Source 2 |
| ---: | --- | --- | --- |
| 0 | GM base address | unused | unused |
| 1 | ConvTile layout | output-extent mode | N |
| 2 | D | C1 | H |
| 3 | W | C0 | logical channels |
| 4 | filter H | filter W | stride H |
| 5 | stride W | dilation H | dilation W |
| 6 | pad left | pad right | pad top |
| 7 | pad bottom | unused | unused |

All descriptor values are read from absolute GPR inputs before allocation.
Unused sources and every B.IOR destination must select R0. The layout values
are zero for NC1HWC0 and one for NDC1HWC0. Rank is derived from layout rather
than encoded independently. The initial portable output-extent mode is zero,
the explicit-padding floor mode defined below; other values reject pending the
architecture decision recorded under "Open source conflicts."

Bundle destination resolution recognizes the exact eight-entry schema,
constructs a temporary `ConvTileInfo`, validates descriptor storage and
aggregate capacity, and calls `ConfigureConvTile` only after every memory and
descriptor precondition succeeds. The existing TLOAD selector and TSize
allocation remain unchanged.

ConvTile TLOAD requires all B.DIM slots and all nonzero B.DATR fields to be
absent. Shape and layout come only from the ordered descriptor bindings. The
common Tile data type comes from the effective BSTART/B.DATR type resolution,
and the allocated location is `TileLocation_Matrix`. ConvTile TSTORE likewise
rejects a nonzero DATR layout because the source descriptor already owns its
layout.

### ConvTile-aware TLOAD and TSTORE

TLOAD and TSTORE branch on Tile kind after legality:

- ordinary Tiles retain the existing two-dimensional behavior;
- ConvTiles iterate the canonical payload index range
  `0 .. product(N,D,C1,H,W,C0)-1` and transfer contiguous same-layout raw
  elements;
- all memory accesses are preflight before the first payload or memory effect;
- packed four-bit elements retain the existing low-index/low-nibble rule;
- ConvTile TLOAD marks every logical element defined only after all reads
  succeed;
- ConvTile TSTORE requires every logical element defined.

This stage defines contiguous same-layout ConvTile transport. General
multidimensional GlobalTensor stride conversion is a separate TLSU extension;
it is not inferred from the ignored ordinary TLOAD row-stride binder.

## TIMG2COL interface and binding

The semantic interface becomes:

```text
TIMG2COL(destination, source, padding, pos_m, pos_k)
```

The catalog row retains TEPL Mode 3, Function 4, selector `0x064`, and the SFU
layout-and-rearrangement classification. Its operand roles become:

| Operand | Role |
| --- | --- |
| `destination0` | ordinary matrix destination |
| `source0` | ConvTile source |
| `source1` | constant or per-channel padding values |
| `scalar0` | `posM` raw GPR value |
| `scalar1` | `posK` raw GPR value |

The bundle form uses:

- `BSTART.TEPL` for selector and data type;
- `B.DIM LB0` for destination valid K;
- `B.DIM LB1` for destination valid M;
- `B.DIM LB2` for destination physical columns;
- one `B.IOT` form containing ConvTile source, padding source, and destination;
- exactly one input-only `B.IOR`; source zero supplies `posM`, source one
  supplies `posK`, and source two selects R0.

The operation-specific destination descriptor is:

```text
rows = valid_rows = LB1
columns = LB2
valid_columns = LB0
layout = TileLayout_RowMajor
location = TileLocation_Matrix
```

LB0, LB1, and LB2 must all be positive and LB0 must not exceed LB2. The
operation does not use the generic LB0-as-rows/LB1-as-columns allocator.

The B.IOR sources are snapshotted as Words. Legality requires both unsigned
values to fit `0..65535`; only after that check are they converted to the
constrained `posM` and `posK` domains. The B.IOR destination and third source
must select R0.

No kernel, stride, dilation, or padding-extent operand remains in the
tile-operation catalog. Those values belong to the source ConvTile descriptor.
No `TSETFMATRIX`, `TSET_IMG2COL_RPT`, or `TSET_IMG2COL_PADDING` state is
consumed by the portable operation.

Those three public configuration intrinsics remain lowering hints outside the
accepted encoded PTO 0.58.0 surface in this change. A backend may emit physical
configuration writes before `TIMG2COL`, but those writes cannot change the
portable result derived from the explicit Tile operands and source descriptor.

The public source-level four-argument intrinsic lowers constant padding by
materializing a one-element padding Tile from the ConvTile padding metadata.
An internal or future public overload supplies a C-element padding Tile for
per-channel padding. The binary semantic boundary remains explicit in both
cases.

## TIMG2COL value semantics

Let the source dimensions be:

```text
N, [D,] C1, H, W, C0
```

For NC1HWC0, `D` is one. Let `C` be the descriptor's logical channel count.
Output-extent mode zero uses explicit-padding floor semantics:

```text
effective_filter_h = dilation_h * (filter_h - 1) + 1
effective_filter_w = dilation_w * (filter_w - 1) + 1

out_h = floor((H + pad_top + pad_bottom - effective_filter_h) / stride_h) + 1
out_w = floor((W + pad_left + pad_right - effective_filter_w) / stride_w) + 1

M_total = N * D * out_h * out_w
K_total = C1 * filter_h * filter_w * C0
```

For destination row `r` and column `c`:

```text
m = posM + r
k = posK + c
```

M linearization is N-major, then D, output H, and output W. K linearization is
C1-major, then filter H, filter W, and C0. The flattened channel index is
`c1 * C0 + c0`; indices at or above logical channel C are padding. Keeping the
complete blocked K extent preserves the layout and makes a partial final C1
block deterministic.

The source image coordinates are:

```text
input_h = output_h * stride_h + filter_h_index * dilation_h - pad_top
input_w = output_w * stride_w + filter_w_index * dilation_w - pad_left
```

If the batch, depth, channel, input H, or input W coordinate is outside the
feature-map region, the result comes from the explicit padding Tile. A
one-element padding Tile supplies one constant value. A padding Tile with one
row and C valid columns supplies the value at flattened channel index
`c1 * C0 + c0`. Otherwise, the result is the raw source element at the
layout-defined offset.

`TIMG2COL` performs no arithmetic conversion. Source, destination, and padding
use one identical `TileDataType`; payload bits are copied unchanged.

## Legality and faults

The complete read-only legality predicate runs before destination effects.
`TIMG2COL` is legal only when:

- source kind is ConvTile; padding and destination kinds are ordinary;
- source, padding, and destination are pairwise distinct;
- source layout is NC1HWC0 or NDC1HWC0 with the exact required rank;
- all used dimensions, filter sizes, strides, and dilations are positive;
- logical channels are in `1..C1*C0`;
- effective filter size fits the padded H/W domain;
- computed `out_h`, `out_w`, `M_total`, and `K_total` are positive and fit the
  architectural integer domains;
- `posM + destination.valid_rows <= M_total`;
- `posK + destination.valid_columns <= K_total`;
- destination descriptor exactly matches the LB0/LB1/LB2 mapping;
- source, padding, and destination data types match;
- padding is fully defined and has shape 1x1 or 1xC;
- source and destination layouts are indexable by their respective portable
  mapping;
- every selected in-bounds source element is defined;
- destination storage fits its allocation capacity.

Zero filter, stride, dilation, logical channel, destination extent, or derived
output extent is illegal. PTO does not publish a warning channel, so these
cases do not execute as warning-only no-ops.

Every nonzero B.DATR field is illegal for TIMG2COL. Source layout and padding
are explicit state and operands; accepting a DATR layout or pad selector without
consuming it would create an ambiguous second control surface.

A recognized `TIMG2COL` with an illegal operand or state tuple raises
`Fault_TileLegality`, reports the current TPC, returns
`TileExecution_Rejected`, and preserves source and destination state. An
unknown or reserved selector remains `Fault_IllegalInstruction`.

## Aliasing, ordering, and completion

Source, padding, and destination must be pairwise distinct. The ConvTile source
cannot share one register with an ordinary operand, and destination allocation
cannot overwrite padding values before they are consumed.

Execution snapshots the complete source descriptor, selected source payload,
padding payload, and scalar offsets before the first destination write. It
computes the destination payload and definedness in temporary state and commits
the whole valid region atomically.

`TIMG2COL` produces no memory event and does not fence unrelated scalar or Tile
traffic. Bundle-launched rejection preserves source lifetime, destination
allocation, bundle state, and trap-visible retry state under the existing
bundle completion contract.

## Reference-to-PTO normalization decisions

The portable contract retains observable data and legality while removing
hardware mechanisms:

- Reference constant and per-channel padding become one explicit padding Tile.
  The padding-table buffer and configuration register are not architectural.
- Reference M-repeat and K-repeat become destination valid M/K plus `posM/posK`
  slicing. Repeat counters and destination-fractal strides are not state.
- Reference dual-source feature-map concatenation is represented by one ConvTile
  whose logical payload already contains the concatenated H extent. TIMG2COL
  does not gain an implicit second feature-map source.
- Reference zero repeat, dimension, filter, or stride warning-only no-ops become
  `Fault_TileLegality`; PTO has no architectural warning result.
- Reference address units, physical buffer bounds, fractal alignment, and
  performance restrictions do not constrain the portable descriptor. PTO
  capacity and model-bound checks remain authoritative.
- Reference padding-mode encodings 2 and 3 are reserved and reject. Constant and
  per-channel modes are derived from padding Tile shape rather than a hidden
  mode register.

## Open source conflicts

The supplied reference describes two special output-extent cases with ceil
formulas: loss-feature convolution and a restricted asymmetric-padding mode.
Its text and active pseudocode do not fully define the final partial window's
per-element source mapping. The public PTO reference implements only the
explicit-padding floor equation defined above.

This design therefore reserves nonzero `output-extent mode` values and does not
publish guessed element semantics. Closing the complete requested reference
rule set requires one additional architecture decision that supplies either:

- an exact coordinate rule for every element of the final partial window; or
- a decision that those ceil formulas are scheduling guidance and that the
  portable result remains the explicit-padding floor transform.

Until that decision is recorded, a nonzero output-extent mode raises
`Fault_TileLegality` before allocation or payload effects. This is the only
known reference convolution rule in this stage that cannot be normalized from
active text and public PTO behavior without guessing.

## ASL organization

The implementation introduces focused units rather than expanding unrelated
Tile files:

```text
asl/tile/convolution-state.asl
asl/tile/img2col.asl
tests/asl/convolution-state-tests.asl
tests/asl/img2col-tests.asl
```

`asl/tile/state.asl` owns common allocation, capacity, and definedness helpers.
`asl/tile/convolution-state.asl` owns ConvTile descriptor types, layout
indexing, configuration, and validation. `asl/tile/img2col.asl` owns pure
geometry/index helpers and the thin state-updating instruction procedure.
`asl/tile/memory.asl` gains explicit ordinary/ConvTile TLOAD and TSTORE
branches. `asl/bundle/state.asl` gains ordered B.IOR append state, and
`asl/bundle/dispatch.asl` gains operation-specific B.IOR schema and destination
descriptor resolution.

The Makefile lists the new sources in dependency order and lists both tests in
`ASL_TESTS`. The tests are assigned exactly once to explicit shards.

## Catalog, traceability, and documentation

The normative change updates together:

- `spec/catalog/tile-operations.json` for the corrected operand contract;
- `spec/catalog/command-forms.json` documentation for ordered B.IOR semantics
  without adding a new encoded form;
- generated decoder witnesses and instruction reference;
- `spec/requirements.json` with `PTO-REQ-CONVTILE-001` and
  `PTO-REQ-TIMG2COL-001`;
- a new accepted architecture decision for ConvTile and portable image-to-column
  semantics;
- `docs/architecture.md`, `docs/modeling-conventions.md`,
  `docs/normative-sources.md`, and `docs/coverage.md`;
- `docs/instructions/tile/TIMG2COL.md`;
- `docs/instructions/tile/TLOAD.md`, `docs/instructions/tile/TSTORE.md`, and
  `docs/instructions/bundle/operands/B.IOR.md`;
- release traceability and TEPL totality evidence;
- TLSU totality evidence for ordinary and ConvTile memory paths;
- public-source reconciliation with an explicit PTO normalization record for
  the compiler-synthesized padding operand;
- catalog and repository checks that reject the former nine-argument handler
  shape.

The accepted direct-operation count, command-form count, and selector allocation
do not change. B.IOR's encoded word is unchanged; only its bundle-level
append/lifecycle contract expands. Generated `build/` and `.cache/` files
remain untracked.

## Executable evidence

### ConvTile state tests

Tests cover:

- rank-five NC1HWC0 and rank-six NDC1HWC0 descriptors;
- minimum and model-bound shapes;
- capacity acceptance and rejection, including packed four-bit storage;
- invalid rank/layout combinations;
- logical channel count at one, at `C1*C0`, and outside the legal range;
- reconfiguration clearing definedness;
- failed reconfiguration preserving descriptor and payload;
- reset and release clearing kind and descriptor;
- trap entry and recovery leaving live ConvTile state unchanged without adding
  it to TrapContext;
- Shared descriptor paths rejecting convolution kind.

### ConvTile transport and binding tests

Tests cover:

- exact eight-entry ConvTile TLOAD B.IOR schema and append order;
- missing, surplus, reordered, nonzero-unused, and overflow B.IOR bindings;
- ordinary one-entry B.IOR behavior remaining unchanged;
- NC1HWC0 and NDC1HWC0 contiguous TLOAD/TSTORE round trips;
- complete memory preflight, first/middle/last faults, preservation, and reissue;
- operation-specific LB0/LB1/LB2 destination descriptor construction;
- `posM/posK` scalar binding, 16-bit boundaries, and nonzero B.IOR
  destination/source-two rejection.

### TIMG2COL value tests

Tests cover:

- one-by-one kernel identity;
- overlapping windows;
- asymmetric padding and nonzero constant padding Tiles;
- per-channel padding Tiles and rejected intermediate padding shapes;
- independent H/W stride;
- independent H/W dilation;
- channel-block and C0-lane ordering;
- partial final channel block;
- batch and depth linearization;
- nonzero `posM` and `posK` slices;
- destination physical columns larger than valid K;
- packed four-bit raw payload copying.

### Negative and atomicity tests

Tests cover:

- zero filter, stride, dilation, channel, and destination extents;
- effective filter larger than the padded input;
- offset plus destination extent beyond M or K;
- unsupported source layout or wrong rank;
- source/padding/destination data-type mismatch;
- undefined selected source element;
- every source/padding/destination alias pair;
- insufficient destination capacity;
- preserved destination payload and definedness after every rejection;
- decoded direct execution and bundle-launched rejection/retry behavior.

### Closure gates

The implementation must pass, at minimum:

```bash
make test-shard-tile-ops
make test-shard-tepl-totality
make test-shard-tlsu-totality
make test-shard-core-bundle
make test-shard-state
make check
make repo-check
git diff --check
```

The implementation plan identifies the exact existing shard names before
editing. The complete release gate is not run or weakened as part of ordinary
development validation.

## Completion criteria

This design is complete when:

- every allocated ConvTile has a total typed descriptor and defined payload
  interpretation;
- ConvTile-aware TLOAD is an executable producer and TSTORE is an executable
  consumer under the ordered B.IOR descriptor schema;
- selector `0x064` accepts exactly destination, ConvTile source, padding Tile,
  `posM`, and `posK`;
- the ASL result matches the documented multidimensional equations for every
  legal model-bounded input;
- every illegal tuple rejects before effects with the correct PTO fault class;
- catalog, decoder, semantic binding, requirements, documentation, traceability,
  and executable evidence agree;
- selector and accepted-form counts remain unchanged;
- no physical accelerator buffer, register, pipeline, warning channel, or
  performance constraint appears as portable architectural state.
