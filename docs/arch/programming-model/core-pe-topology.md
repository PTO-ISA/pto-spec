<!-- GENERATED FROM: asl/arch/programming-model/core-pe-topology.asl -->
# Core PE Topology

**Normative ASL source:** `asl/arch/programming-model/core-pe-topology.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-core-pe-topology-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit collects the fixed namespace sizes used by the PTO programming model and defines the representation bridge between semantic PE identities and the four-bit PE mask.

It is the place to check counts and identity-to-mask indexing. It does not define instruction behavior or memory ordering.

<!-- PTO-READER-BLOCK: arch-core-pe-topology-concepts-state role=concepts-state -->
## Namespaces and identities

The scalar namespace has `32` register encodings, including `24` absolute GPRs and two temporary queues of depth `4`. The unit also fixes `8` predicate registers of width `32`, `16` ACRs, `64` Tile registers, and `64` Shared Tile registers.

Semantic PE identities are the integers `0` through `3`, conventionally read as PE0 through PE3.

<!-- PTO-READER-BLOCK: arch-core-pe-topology-rules-interactions role=rules-interactions -->
## Identity-to-mask rule

`PTOPEMaskBitOfPEIdentity` maps a semantic PE identity to the corresponding mask index by subtracting it from `3`.

This bridge is necessary because PE0 occupies the high bit of the four-bit architectural mask: PE0 maps to bit `3`, PE1 to bit `2`, PE2 to bit `1`, and PE3 to bit `0`.

<!-- PTO-READER-BLOCK: arch-core-pe-topology-boundaries role=boundaries -->
## Model boundaries

`PTO_MODEL_MEMORY_AGENTS` and `PTO_MODEL_MEMORY_EVENTS` size the executable model at `4` agents and `16` events. Their `PTO_MODEL_` names identify them as model bounds; this page does not generalize those values into additional implementation requirements.

<!-- PTO-READER-BLOCK: arch-core-pe-topology-example-usage role=example-usage -->
## Non-normative indexing example

When a reader starts with semantic PE2, apply the bridge before indexing a mask: `3 - 2` gives mask bit `1`. Directly using `2` as the bit index would select the wrong semantic PE.

<!-- PTO-READER-BLOCK: arch-core-pe-topology-related-owners role=related-owners-navigation -->
## Related owners

- [Architecture overview](../overview/architecture.md) is the dependency that establishes the top-level architecture identity.
- [Scalar registers](scalar-registers.md) uses the current memory-agent identity for per-PE GPR access.
- [Tile registers](tile-registers.md) is the named Tile-register programming-model owner.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/core-pe-topology.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY","surface":"arch","classification":["programming-model","core-pe-topology"],"depends_on":["PTO-ARCH-OVERVIEW-ARCHITECTURE"]}
// The five-bit scalar namespace contains 24 absolute GPRs and two four-entry
// bundle-local temporary queues (T and U).
constant PTO_SCALAR_REGISTER_COUNT = 32;
constant PTO_ABSOLUTE_GPR_COUNT = 24;
constant PTO_TEMPORARY_QUEUE_DEPTH = 4;
constant PTO_PREDICATE_REGISTER_COUNT = 8;
constant PTO_PREDICATE_WIDTH = 32;
constant PTO_ACR_COUNT = 16;
constant PTO_TILE_REGISTER_COUNT = 64;
constant PTO_SHARED_TILE_COUNT = 64;
constant PTO_MODEL_MEMORY_AGENTS = 4;
constant PTO_MODEL_MEMORY_EVENTS = 16;

// Fixed semantic PE identities are numbered PE0..PE3.  The architectural
// four-bit mask keeps PE0 in its high bit, so consumers that index a mask by
// semantic PE identity must use this explicit representation bridge.
pure func PTOPEMaskBitOfPEIdentity(
    pe_identity: integer {0..3}) => integer {0,1,2,3}
begin
    return (3 - pe_identity) as integer {0,1,2,3};
end;
```
<!-- GENERATED-ASL-END: unit -->
