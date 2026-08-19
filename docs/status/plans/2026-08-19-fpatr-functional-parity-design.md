# FPATR Functional Parity Design

## Status

Approved design for two sequential normative pull requests. The transfer,
layout, cache, synchronization, and memory-atomic portions of a physical
FIXPIPE implementation are outside this change.

Implementation requires two linked NDF architecture issues against the exact
`main` baseline. Each issue must name the clauses, defaults, compatibility,
open questions, focused evidence, and release impact owned by its pull request.

## Goal

Make PTO matrix post-processing functionally equivalent to the accepted
FIXPIPE-compatible numeric pipeline while preserving PTO-owned encodings,
explicit architectural state, the one-level Tile model, and atomic Local Tile
publication.

The work lands as two pull requests:

1. correct the numeric semantics of the existing `B.FPATR` command and its
   twenty-seven assigned modes without changing their encodings;
2. add explicit attribute forms for the remaining pre-stage, elementwise, and
   post-stage functionality.

The second pull request depends on the first and starts only after the first is
merged.

## Authority and evidence boundary

PTO ASL remains the sole normative source. The implementation records only
PTO-owned behavior, decisions, and expected results. Diagnostic comparison
material may be used to discover differences and construct local review
vectors, but its identity, paths, prose, code, diagrams, and encoding namespace
must not enter ASL, NDF clauses, decisions, generated evidence, or committed
tests.

Functional equivalence does not require encoding equivalence. Existing PTO
encodings remain stable in the first pull request. New encodings in the second
pull request are allocated by the PTO command catalog and must pass overlap,
decoder, binary-closure, and extension-reservation checks.

## Shared architectural invariants

- CUBE computes a raw FP32, S32, or U32 accumulator result.
- RowMax and GroupMax remain PTO extensions over the complete raw accumulator
  and execute before destination conversion or activation.
- All enabled numerical stages consume one pre-effect snapshot of their scalar,
  Local, and Shared parameters.
- Every legality, descriptor, shape, parameter, capacity, alias, and
  definedness check completes before the first destination or numeric-status
  effect.
- The processed D result, enabled auxiliary outputs, numeric status, public
  representation state, and destination descriptors publish atomically.
- No FPATR form creates an implicit parameter buffer, hidden Tile operation,
  body-local queue, replay body, or memory transfer.
- Direct memory movement and physical synchronization remain explicit PTO Tile
  operations or named target-profile behavior outside this design.

## Pull request 1: existing FPATR numeric semantics

### Scope

PR1 changes no command mask, match, field position, assembly spelling,
`PreQuantMode` allocation, source/destination role, or CUBE selector. It changes
the accepted results of existing modes and therefore updates the owning NDF
clauses and decisions before changing their ASL implementation.

Primary owners:

- `asl/block/attributes/B.FPATR.asl`
- `asl/arch/data-types/fp19.asl`
- `asl/arch/profile/matrix-quantization.asl`
- `asl/arch/profile/matrix-postprocess.asl`
- `asl/tile/model/legality/matrix-postprocess.asl`
- `asl/tile/model/execution/postprocess.asl`

Generated pages mirror those owners. Tests remain in their exact mirrored
directories under `tests/asl/`.

### Pipeline order

For an existing nonzero pre-quantization mode, each D element follows this
order:

```text
raw accumulator snapshot
-> select positive/negative-path multiplier
-> multiply in the mode's source/intermediate domain
-> mode-specific intermediate rounding and saturation
-> add the signed mode-specific offset, when present
-> destination rounding and saturation
-> publish the processed destination value
```

Activation participates before destination conversion. For a nonnegative
source, the ordinary quantization scale remains selected. For a negative
source:

- no activation selects the ordinary quantization scale;
- ReLU selects zero;
- scalar or vector LReLU/PReLU selects its corresponding activation
  multiplier.

The activation multiplier replaces the negative-path quantization multiplier;
it is not multiplied by an already converted destination value. RowMaxOut and
GroupMaxOut continue to observe the raw accumulator and are not modified by
this per-D pipeline.

### Zero and affine semantics

Floating signed zero is a finite participant whenever the selected mode owns a
scale or offset. The implementation must not return early merely because the
source class is positive or negative zero.

For every affine mode:

```text
source = +/-0, scale = S, offset = O
result-before-rounding = O
```

Signed zero is preserved only when the complete affine result is zero and the
selected destination format and mode preserve its sign.

### Mode-specific arithmetic

The current mode names remain authoritative. Their implementation must not
collapse all conversions into one `real -> destination` helper when the mode
defines an intermediate width or fixed rounding point.

- `REQ4` and `REQ8` families use their assigned signed intermediate width,
  add the assigned offset, and saturate to S4X2 or S8.
- `DEQS16` uses its assigned signed intermediate and signed seventeen-bit
  offset before S16 saturation.
- `SHIFTS322S16` performs the assigned one-through-sixteen-bit arithmetic
  shift, applies its defined rounding point, and saturates to S16.
- `F322F16` and `F322BF16` use round-to-nearest, ties-to-even at the defined
  destination conversion point.
- existing `QF322FP8` modes target E4M3 and use round-to-nearest,
  ties-to-even.
- existing `QF322HIF8` modes use the assigned half-away behavior. Hybrid
  threshold selection requires new state and belongs to PR2.
- `QF322F32` retains FP32 output but still applies its scale and any assigned
  status behavior.
- S32-to-floating modes interpret S32 before applying their assigned scale and
  destination conversion.

### Saturation and rounding controls

PR1 distinguishes fixed mode behavior from programmable behavior:

- a mode with architecturally fixed rounding rejects a conflicting non-default
  `B.DATR.RMode` before effects;
- programmable integer modes apply the selected rounding only at the mode's
  defined rounding point;
- every mode-specific intermediate narrowing saturates at its assigned S5,
  S9, or S17 boundary and is never replaced by modulo wrapping;
- final integer destination encoding retains the PTO Sat extension: `Sat=1`
  clamps and `Sat=0` wraps only after the required intermediate saturation;
- `B.DATR.Sat` retains PTO polarity: one requests finite clamping and zero
  requests ordinary non-clamping behavior where the mode permits both;
- a mode with no architecturally programmable final saturation rejects an
  inapplicable Sat selection rather than silently selecting a different
  result.

### Special values

Special-value handling runs at the stage where the selected mode first
interprets the floating source. A source NaN, infinity, or zero must not bypass
an owned offset or a later required stage.

PR1 uses the existing fields only:

- `Sat=1` maps floating overflow to the largest finite destination value and
  maps a NaN to zero for the assigned saturating floating modes;
- `Sat=0` preserves the destination format's non-saturating infinity or
  canonical-NaN behavior where representable;
- E4M3, which has no infinity, uses its assigned NaN or largest-finite result;
- signaling NaN raises NV before canonicalization;
- integer destinations use their assigned invalid and endpoint results.

An independently selectable FP8 NaN-preservation policy requires a new field
and belongs to PR2.

### FP19 parameter legality

PR1 narrows the executable parameter domain:

- quantization scales remain positive, finite, and nonzero;
- activation parameters remain finite and nonnegative;
- subnormal FP19 scales and activation parameters are illegal;
- infinity, quiet NaN, signaling NaN, nonzero unused carrier bits, and a scale
  with the wrong sign reject before source snapshots or destination effects.

This design does not infer support for negative quantization scales.

### Fault classification

The owning NDF and decision text must distinguish:

- a bit pattern that does not decode as an accepted command, including fixed
  bits and decode-reserved field encodings: `Fault_IllegalInstruction`;
- an accepted command encoding whose state, mode/type tuple, parameter,
  binding, shape, alias, or attribute combination is illegal:
  `Fault_TileLegality`;
- missing, duplicate, misplaced, or non-Matrix use of the attribute:
  `Fault_BundleControl`.

No rejected case allocates a destination, consumes a source, changes numeric
status, or partially publishes an auxiliary output.

### PR1 evidence

PR1 adds independent tests for:

- FP32 `+0` and `-0` with positive, negative, and zero offsets;
- values that distinguish activation-before-convert from
  convert-before-activation;
- minimum, maximum, halfway, one-ULP-below, and one-ULP-above boundaries for
  every destination family;
- fixed and programmable rounding modes at their actual rounding point;
- intermediate S5, S9, and S17 saturation boundaries;
- clamp and permitted non-clamp behavior;
- quiet/signaling NaN, both infinities, both zeros, and subnormal sources;
- FP19 zero, normal minimum/maximum, subnormal, infinity, NaN, sign, and unused
  bits;
- decode-reserved, bundle-control, and Tile-legality fault identities;
- legal FP32, S32, and U32 auxiliary reductions, partial final groups,
  `GroupN > N`, RowMax input/output aliasing, and complete rollback on a late
  auxiliary failure.

The existing unit-value mode-table test remains a structural witness but is
not used as numeric-boundary evidence.

### PR1 stop condition

PR1 stops when all existing mode encodings have exact positive, boundary,
special-value, fault, and atomic-publication evidence; generated mirrors and
release evidence are fresh; `make pr-check`, `make repo-check`, and
`git diff --check` pass; and the hosted `PR / validate` check succeeds for the
exact reviewed head.

## Pull request 2: extended FPATR stages

### Dependency and scope

PR2 begins from merged PR1. It adds explicit attribute forms and descriptor
state for functionality that cannot be represented by the current command.
It does not add memory movement, layout conversion, cache policy, unit flags,
or memory atomic operations.

The conceptual assembly family is:

```text
B.FPATR          existing required Matrix post-process anchor
B.FPATR.PRE      optional extended pre-stage controls
B.FPATR.ELT      optional elementwise and anti-quant controls
B.FPATR.POST     optional post-stage controls
```

These are PTO-owned names. Exact masks, matches, and field positions are
allocated through the command catalog. They need not match any external
encoding. Each form must have a canonical positive witness, reviewed overlap
priority, reserved-code rejection, generated decode binding, semantic handler,
and independent AVS points.

### Extended pre-stage

`B.FPATR.PRE` adds only controls absent from the anchor command:

- U8 destination selection;
- E5M2 destination selection;
- HiF8 hybrid-rounding selection and threshold parameter;
- an independent floating NaN-preservation policy;
- scalar Clip-ReLU;
- PWL activation;
- explicit compatibility checks between the extension and the anchor's
  `PreQuantMode`, `ReluMode`, RMode, Sat, accumulator type, and destination
  type.

Omission selects the PR1 behavior. A present extension that does not apply to
the anchor mode is illegal rather than ignored.

### Elementwise and anti-quant stage

`B.FPATR.ELT` configures:

- the assigned elementwise operation set;
- one explicit source-2 Tile and its data type;
- optional anti-quantization and its parameter type;
- per-column source selection and M-dimension broadcast;
- shape, layout, definedness, and alias rules.

Source 2 and every anti-quant parameter are explicit Local or Shared bindings.
There is no hidden parameter memory. The operation snapshots the complete
source and parameter set before any D write.

### Post-stage

`B.FPATR.POST` configures:

- post-stage conversion and its scalar/vector parameter form;
- post-stage ReLU, LReLU/PReLU, Clip-ReLU, and PWL controls;
- S4, S8/U8, and S16 shift-based post modes;
- destination bit masking after post-stage activation;
- post-stage rounding, saturation, and NaN policy.

The post stage consumes the output of the elementwise stage. It cannot alter
the raw RowMaxOut or GroupMaxOut results.

### Complete PR2 pipeline

With every extension present, D follows:

```text
raw CUBE accumulator
-> raw PTO auxiliary reductions
-> PR1/extended pre activation and quantization
-> optional source-2 anti-quantization
-> optional elementwise operation and broadcast
-> optional post quantization and activation
-> optional Clip-ReLU or PWL
-> optional destination bit mask
-> atomic D, auxiliary, descriptor, representation, and flags publication
```

The pipeline has one deterministic order. Mutually exclusive activations or
inapplicable controls reject before effects.

### Parameter and binding model

PR2 extends architecture-visible ordered parameter roles instead of creating a
physical FIXPIPE buffer.

- scalar parameters use dense `B.IOR` roles;
- vector parameters and elementwise sources use explicit Local or Shared
  bindings;
- descriptor state records presence and role for every parameter;
- trap save/recovery preserves every new presence bit, field, and binding;
- reset and successful bundle completion clear the complete descriptor;
- source-count limits are expanded only if the exact worst-case role inventory
  cannot fit the current bound, and any expanded bound is a model capacity, not
  a physical implementation claim.

### PR2 faults and atomicity

Missing companion forms, duplicates, ordering violations, incompatible stage
combinations, reserved values, wrong parameter carriers, shape mismatch,
undefined inputs, illegal aliases, or insufficient destination capacity reject
before stage evaluation or publication.

All stages prepare results in temporary architectural values. Failure in the
last configured stage preserves D, auxiliary outputs, source lifetime,
descriptor state, numeric status, and allocation state.

### PR2 evidence

PR2 adds separate mnemonic-owned tests for:

- canonical decode and every reserved extension encoding;
- omission, duplicate, placement, reset, trap preservation, and next-bundle
  lifecycle;
- U8 and E5M2 normal, boundary, overflow, NaN, and saturation results;
- HiF8 half-away versus hybrid threshold boundaries;
- NaN-preserve on/off behavior;
- Clip-ReLU and every accepted PWL segment boundary;
- each elementwise operation, anti-quant type, broadcast form, and alias class;
- scalar and vector post-stage conversion/activation;
- S4, S8/U8, and S16 shift-post boundaries;
- bit-mask counts and inapplicable destination types;
- representative pre+elementwise+post combinations;
- maximum binding-role inventory and complete late-failure rollback.

### PR2 stop condition

PR2 stops when all new command forms close catalog, decode, state, legality,
semantic reachability, trap preservation, generated documentation, independent
tests, binary closure, and release traceability; `make pr-check`,
`make repo-check`, and `git diff --check` pass; and the hosted
`PR / validate` check succeeds for the exact reviewed head.

## Explicit non-goals

Neither pull request adds or changes:

- Local/L0C-to-memory movement;
- OUT, L1, or UB physical destinations;
- NZ2ND, NZ2DN, channel merge/split/pad, or dummy removal;
- LoopEnhance, depth-to-space, space-to-depth, or Winograd layout transforms;
- cache hints, unit flags, physical pipeline stalls, or memory atomic RMW;
- implementation alignment, latency, throughput, or buffer allocation policy.

Those behaviors remain separate explicit PTO operation or target-profile
questions.

## Pull-request separation

PR1 is a normative semantic correction with no catalog encoding change. PR2 is
a separate normative command/state extension and must not be opened until PR1
is merged. Neither PR includes toolchain, governance, unrelated mnemonic,
mechanical tree-reorganization, or release-publication changes.
