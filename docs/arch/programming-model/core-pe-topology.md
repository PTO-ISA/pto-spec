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

A PTO Core contains four processing elements (PEs), numbered PE0 through PE3. This unit fixes the sizes of the register namespaces that programs name, and it defines how a PE number maps to a bit of the four-bit PE mask.

Use this page to check counts and mask indexing. It does not define instruction behavior or memory ordering.

<!-- PTO-READER-BLOCK: arch-core-pe-topology-concepts-state role=concepts-state -->
## Namespaces and identities

| Namespace | Count | Notes |
| --- | --- | --- |
| Scalar register encodings | `32` | Five-bit selector space |
| Absolute GPRs | `24` | Selectors `0` through `23` |
| Temporary queues | `2` | T and U, each of depth `4` |
| Predicate registers | `8` | Each `32` bits wide |
| ACRs | `16` | Access-control rings |
| Local Tile registers | `64` | `PTO_TILE_REGISTER_COUNT` |
| Shared Tile registers | `64` | `PTO_SHARED_TILE_COUNT` |

The scalar namespace is a five-bit selector space of `32` encodings: `24` absolute GPRs plus the eight entries of the two bundle-local temporary queues, T and U.

Design point: selectors `24` through `31` are not registers. As sources they name queue positions `T#1` through `T#4` and `U#1` through `U#4`; as destinations, `31` pushes to T, `30` pushes to U, and `24` through `29` write nothing. This is why the GPR file has `24` entries rather than `32`.

Semantic PE identities are the integers `0` through `3`, read as PE0 through PE3.

<!-- PTO-READER-BLOCK: arch-core-pe-topology-rules-interactions role=rules-interactions -->
## Identity-to-mask rule

The architectural PE mask is four bits wide and keeps PE0 in its high bit: PE0 maps to bit `3`, PE1 to bit `2`, PE2 to bit `1`, and PE3 to bit `0`.

`PTOPEMaskBitOfPEIdentity` performs this mapping by computing `3 - pe_identity`.

Design point: the bridge is an explicit function because the PE number and the bit number run in opposite directions. Any consumer that indexes a mask by semantic PE identity must go through this function instead of using the PE number as a bit index. Written as a binary literal, the mask reads left to right as PE0, PE1, PE2, PE3.

<!-- PTO-READER-BLOCK: arch-core-pe-topology-boundaries role=boundaries -->
## Model boundaries

`PTO_MODEL_MEMORY_AGENTS` and `PTO_MODEL_MEMORY_EVENTS` size the executable model at `4` agents and `16` events. Their `PTO_MODEL_` names identify them as model bounds; this page does not generalize those values into additional implementation requirements.

In the executable model, the memory-agent identity also indexes the per-PE scalar register files, so each PE has its own GPR file.

<!-- PTO-READER-BLOCK: arch-core-pe-topology-example-usage role=example-usage -->
## Non-normative indexing example

When a reader starts with semantic PE2, apply the bridge before indexing a mask: `3 - 2` gives mask bit `1`. Directly using `2` as the bit index would select the wrong semantic PE, PE1.

The mask `1100` therefore selects PE0 and PE1: bit `3` is PE0 and bit `2` is PE1. The mask `0001` selects only PE3.

<!-- PTO-READER-BLOCK: arch-core-pe-topology-related-owners role=related-owners-navigation -->
## Related owners

- [Architecture overview](../overview/architecture.md) is the dependency that establishes the top-level architecture identity.
- [Scalar registers](scalar-registers.md) uses the current memory-agent identity for per-PE GPR access.
- [Tile registers](tile-registers.md) is the named Tile-register programming-model owner.
- [PE mask legality](../../tile/model/legality/pe-mask.md) counts selected PEs and derives Core-wide allocation size from a mask.
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
