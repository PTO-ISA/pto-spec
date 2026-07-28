# Arm ASL comparison record

This record captures the bounded Arm review requested for PTO operations with
familiar load, store, writeback, pair, or prefetch shapes. It is review evidence,
not a normative source and not an assertion that similarly named operations
share encodings or semantics.

## Official comparison sources

- [Arm Architecture Specification Language](https://developer.arm.com/architectures/architecture-specification-language)
- [Arm A64 PRFM (immediate), 2022-06](https://developer.arm.com/documentation/ddi0602/2022-06/Base-Instructions/PRFM--immediate---Prefetch-Memory--immediate--)
- [Arm Architecture Reference Manual DDI0487mb, load-store pair](https://developer.arm.com/documentation/ddi0487/mb/-Part-C-The-AArch64-Instruction-Set/-Chapter-C3-A64-Instruction-Set-Overview/-C3-2-Loads-and-stores/-C3-2-3-Load-store-pair)

The references are versioned official Arm pages. They were reviewed to identify
questions PTO must answer; their pseudocode, prose, constraints, and
constrained-unpredictable choices are not copied into PTO.

## Disposition

| Review topic | Arm comparison question | PTO-owned disposition | Not imported |
| --- | --- | --- | --- |
| Prefetch | Is a prefetch merely a hint, and does it change architectural state? | PTO scalar prefetch is a non-faulting hint. Direct tile `TPREFETCH` is a destination-free checking hint: it may report applicable address faults but writes no tile state. | Arm hint encodings, cache policy, fault suppression, and target-specific effects. |
| Updating load/store | What happens when a data result, stored-data selector, and address-writeback selector overlap? | Catalog family rule `agu-updating-store-address-data-distinct` rejects updating stores whose returned-address selector equals the stored-data selector before any effect. | Arm register-number conventions, constrained-unpredictable choices, suppression choices, and execution order. |
| Pair results | What happens when two encoded result selectors are equal? | Catalog family rule `agu-pair-results-distinct` rejects equal pair-result selectors before register or memory effects. | Arm pair register restrictions, special-register meanings, and any implicit write ordering. |
| Shared spelling | Does a familiar mnemonic imply the same constraint or fault? | No. Every PTO constraint must be present in a PTO catalog/ADR/ASL rule and have positive and negative witnesses. Tile operation names are reconciled against the public PTO API, not Arm. | All semantics inferred only from name similarity. |

ADR-0004 defines the family-constraint schema and the two retained AGU rules.
The scalar catalog contains 85 generated applications of those rules; CI
requires both legal and rejecting witnesses. ADR-0007 separately reconciles the
public PTO source layer with the direct binary architecture.

## Review boundary

This is not an exhaustive Arm-to-PTO instruction mapping. PTO does not claim
Arm compatibility, and this record does not authorize future rules by analogy.
A new comparison-derived PTO rule requires a stable PTO requirement, PTO-owned
normative text, catalog or ASL enforcement, and executable evidence.
