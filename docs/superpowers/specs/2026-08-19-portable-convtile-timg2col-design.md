# Portable ConvTile and TIMG2COL Design

## Outcome

Add a portable convolution-tile descriptor and replace the current simplified
two-dimensional `TIMG2COL` model with an exact multidimensional image-to-column
transform.

The accepted operation remains one direct Tile operation at TEPL selector
`0x064`. It reads all convolution geometry from the source ConvTile descriptor,
accepts only `posM` and `posK` as scalar offsets, and writes one ordinary matrix
Tile. It does not depend on hidden FMATRIX registers, body-local queues, target
pipelines, or configuration commands.

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
  one-to-six-dimensional convolution Tile with explicit logical shape, layout,
  geometry, padding, payload, and definedness;
- `PTO-REQ-TIMG2COL-001`: `TIMG2COL` produces a deterministic matrix slice from
  a legal ConvTile and `(posM, posK)`.

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

- `TileInfo` represents only `rows` and `columns`; it cannot preserve a
  ConvTile's one-to-six-dimensional logical shape.
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

- ConvTile kind, rank, logical shape, valid shape, data type, layout, capacity,
  payload, and per-element definedness;
- filter size, stride, dilation, four-sided padding, logical channel count, and
  raw padding value;
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

### ConvTile descriptor

`ConvTileInfo` contains:

- `configured`;
- rank in the architectural domain 1 through 6;
- six positive logical dimensions, with unused trailing dimensions equal to
  one;
- six positive valid dimensions, each no greater than its logical dimension;
- layout;
- filter height and width;
- stride height and width;
- dilation height and width;
- padding left, right, top, and bottom;
- logical channel count;
- raw padding value.

The first accepted `TIMG2COL` source layouts are:

| Layout | Rank | Dimension order |
| --- | ---: | --- |
| `NC1HWC0` | 5 | N, C1, H, W, C0 |
| `NDC1HWC0` | 6 | N, D, C1, H, W, C0 |

Other public ConvTile layouts may exist as descriptor identities, but
`TIMG2COL` rejects them until a separate operation defines their logical
mapping. This rule prevents an implementation layout from silently becoming a
portable indexing convention.

Logical dimensions determine storage strides and capacity. Valid dimensions
determine the feature-map extent observed by `TIMG2COL`. In the equations below,
N, D, C1, H, W, and C0 name the valid dimensions; layout offset calculation
continues to use the corresponding logical dimensions.

The logical channel count is positive and no greater than
`valid_C1 * valid_C0`. A value smaller than that product makes lanes whose
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

## TIMG2COL interface and binding

The semantic interface becomes:

```text
TIMG2COL(destination, source, pos_m, pos_k)
```

The catalog row retains TEPL Mode 3, Function 4, selector `0x064`, and the SFU
layout-and-rearrangement classification. Its operand roles become:

| Operand | Role |
| --- | --- |
| `destination0` | ordinary matrix destination |
| `source0` | ConvTile source |
| `natural0` | `posM` |
| `natural1` | `posK` |

The bundle form uses:

- `BSTART.TEPL` for selector and data type;
- `B.DIM LB0` for destination valid M;
- `B.DIM LB1` for destination valid K;
- `B.DIM LB2` for the destination physical column extent when it differs from
  valid K;
- `B.IOT` for source and destination Tile bindings;
- `B.IOR` scalar sources zero and one for `posM` and `posK`.

No kernel, stride, dilation, padding, or padding-value operand remains in the
tile-operation catalog. No `TSETFMATRIX`, `TSET_IMG2COL_RPT`, or
`TSET_IMG2COL_PADDING` state is consumed by the portable operation.

Those three public configuration intrinsics remain lowering hints outside the
accepted encoded PTO 0.58.0 surface in this change. A backend may emit physical
configuration writes before `TIMG2COL`, but those writes cannot change the
portable result derived from the source descriptor.

## TIMG2COL value semantics

Let the source dimensions be:

```text
N, [D,] C1, H, W, C0
```

For NC1HWC0, `D` is one. Let `C` be the descriptor's logical channel count.
Define:

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
valid feature-map region, the result is the source descriptor's raw padding value.
Otherwise, the result is the raw source element at the layout-defined offset.

`TIMG2COL` performs no arithmetic conversion. Source, destination, and padding
use one identical `TileDataType`; payload bits are copied unchanged.

## Legality and faults

The complete read-only legality predicate runs before destination effects.
`TIMG2COL` is legal only when:

- source and destination are distinct allocated Tile registers;
- source kind is ConvTile and destination kind is ordinary;
- source layout is NC1HWC0 or NDC1HWC0 with the exact required rank;
- all used dimensions, filter sizes, strides, and dilations are positive;
- every valid dimension is within its logical dimension;
- logical channels are in `1..C1*C0`;
- effective filter size fits the padded H/W domain;
- computed `out_h`, `out_w`, `M_total`, and `K_total` are positive and fit the
  architectural integer domains;
- `posM + destination.valid_rows <= M_total`;
- `posK + destination.valid_columns <= K_total`;
- destination physical columns are no smaller than destination valid columns;
- source and destination data types match;
- source and destination layouts are indexable by their respective portable
  mapping;
- every selected in-bounds source element is defined;
- destination storage fits its allocation capacity.

Zero filter, stride, dilation, logical channel, destination extent, or derived
output extent is illegal. PTO does not publish a warning channel, so these
cases do not execute as warning-only no-ops.

A recognized `TIMG2COL` with an illegal operand or state tuple raises
`Fault_TileLegality`, reports the current TPC, returns
`TileExecution_Rejected`, and preserves source and destination state. An
unknown or reserved selector remains `Fault_IllegalInstruction`.

## Aliasing, ordering, and completion

Source and destination aliasing is illegal because one Tile register cannot be
interpreted simultaneously as the ConvTile source descriptor and ordinary
matrix destination descriptor.

Execution snapshots the complete source descriptor and selected payload before
the first destination write. It computes the destination payload and
definedness in temporary state and commits the whole valid region atomically.

`TIMG2COL` produces no memory event and does not fence unrelated scalar or Tile
traffic. Bundle-launched rejection preserves source lifetime, destination
allocation, bundle state, and trap-visible retry state under the existing
bundle completion contract.

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

The Makefile lists the new sources in dependency order and lists both tests in
`ASL_TESTS`. The tests are assigned exactly once to explicit shards.

## Catalog, traceability, and documentation

The normative change updates together:

- `spec/catalog/tile-operations.json` for the corrected operand contract;
- generated decoder witnesses and instruction reference;
- `spec/requirements.json` with `PTO-REQ-CONVTILE-001` and
  `PTO-REQ-TIMG2COL-001`;
- a new accepted architecture decision for ConvTile and portable image-to-column
  semantics;
- `docs/architecture.md`, `docs/modeling-conventions.md`,
  `docs/normative-sources.md`, and `docs/coverage.md`;
- `docs/instructions/tile/TIMG2COL.md`;
- release traceability and TEPL totality evidence;
- catalog and repository checks that reject the former nine-argument handler
  shape.

The accepted direct-operation count and selector allocation do not change.
Generated `build/` and `.cache/` files remain untracked.

## Executable evidence

### ConvTile state tests

Tests cover:

- rank-five NC1HWC0 and rank-six NDC1HWC0 descriptors;
- minimum and model-bound shapes;
- capacity acceptance and rejection, including packed four-bit storage;
- invalid rank/layout combinations;
- valid dimensions exceeding logical dimensions;
- logical channel count at one, at `C1*C0`, and outside the legal range;
- reconfiguration clearing definedness;
- failed reconfiguration preserving descriptor and payload;
- trap save and recovery of every ConvTile descriptor leaf.

### TIMG2COL value tests

Tests cover:

- one-by-one kernel identity;
- overlapping windows;
- asymmetric padding and nonzero raw padding values;
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
- source/destination data-type mismatch;
- undefined selected source element;
- source/destination alias;
- insufficient destination capacity;
- preserved destination payload and definedness after every rejection;
- decoded direct execution and bundle-launched rejection/retry behavior.

### Closure gates

The implementation must pass, at minimum:

```bash
make test-shard-tile-ops
make test-shard-tepl-totality
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
- selector `0x064` accepts exactly destination, source, `posM`, and `posK`;
- the ASL result matches the documented multidimensional equations for every
  legal model-bounded input;
- every illegal tuple rejects before effects with the correct PTO fault class;
- catalog, decoder, semantic binding, requirements, documentation, traceability,
  and executable evidence agree;
- no physical accelerator buffer, register, pipeline, warning channel, or
  performance constraint appears as portable architectural state.
