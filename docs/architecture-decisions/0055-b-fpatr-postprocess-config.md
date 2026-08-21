# ADR 0055: B.FPATR owns CUBE PostProcessConfig

- Status: accepted
- Date: 2026-08-12
- Requirement: `PTO-BLOCK-B-FPATR`, `PTO-REQ-CUBE-001`
- Decision source: [pto-spec issue 64](https://github.com/PTO-ISA/pto-spec/issues/64)

## Context

All 12 accepted CUBE matrix operations already name `B.FPATR` in their bundle
composition, but the command had no catalog row, ASL owner, decoded execution
binding, or state-transition evidence. Generated prose could not substitute for
that missing normative owner.

## Decision

PTO ISA 0.58.0 accepts one 32-bit `B.FPATR` command with mask
`0x00007fff`, match `0x00002023`, and canonical-None word `0x00002023`.
Its variable fields are `PreQuantMode[31:26]`, `ReluMode[25:23]`,
`GroupNCode[22:19]`, `RowMaxEn[18]`, `GroupMaxEn[17]`, `RowMaxInit[16]`,
and `MaxAbsEn[15]`.

Every complete bundle selecting one of the 12 accepted CUBE operations MUST
contain exactly one `B.FPATR`. Missing, duplicate, or inapplicable presence
produces `Fault_BundleControl`. A duplicate MUST preserve the first latched
configuration. Reserved modes, invalid combinations, or incompatible operand
schemas produce `Fault_TileLegality` during complete-bundle preflight.

The configuration, including encoded presence, is architectural bundle state.
Reset, clear, and new-bundle initialization remove it; trap save and recovery
preserve it. No destination allocation, input consumption, or payload effect
may occur before all PostProcess legality and allocation checks succeed.

CUBE first computes its complete-K value P. RowMax and GroupMax observe P
before ReLU, quantization, conversion, offset, or saturation. D and every
enabled auxiliary output commit atomically. Exact FP19 arithmetic, floating
exceptional results, and non-saturating out-of-range conversion remain owned by
named numeric-profile hooks.

## Consequences

The accepted bundle-command inventory increases from 99 to 100 without adding
a tile selector or reusing reserved CUBE functions. Existing explicit D and
explicit C behavior remains unchanged. The ASL model must expose structural
legality and deterministic reference hooks without importing backend behavior.
