<!-- GENERATED FROM: asl/arch/data-types/memory-operations.asl -->
# Memory Operations

**Normative ASL source:** `asl/arch/data-types/memory-operations.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-MEMORY-OPERATIONS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-memory-operations-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit names the address-update and atomic-operation selectors shared by scalar and tile memory execution.

Keeping these selectors in one owner prevents individual instructions from inventing incompatible names for the same operation class.

<!-- PTO-READER-BLOCK: arch-memory-operations-concepts-state role=concepts-state -->
## Concepts and visible state

- `AddressUpdateMode` has `AddressUpdate_None`, `AddressUpdate_PreIndex`, and `AddressUpdate_PostIndex`.
- `AtomicOperation` covers swap, add, bitwise AND/OR/XOR, signed min/max, and unsigned min/max.
- The enumerations are typed inputs to executable helpers; they do not contain address calculation or read-modify-write behavior by themselves.

<!-- PTO-READER-BLOCK: arch-memory-operations-rules-interactions role=rules-interactions -->
## Rules and interactions

Pre-index and post-index are distinct selectors. The consuming instruction owner determines when the base update is computed and committed.

Signed and unsigned min/max have separate enum members: `Atomic_SMIN`, `Atomic_SMAX`, `Atomic_UMIN`, and `Atomic_UMAX`.

No enum member implies fault, ordering, size, or publication rules; those remain parameters and behavior of the consuming owner.

<!-- PTO-READER-BLOCK: arch-memory-operations-boundaries role=boundaries -->
## Architectural boundaries

This unit has no fallback or implementation-defined selector. A decoder must map only to a declared member before execution.

Selector identity is portable, while support and legality for a particular instruction form remain with that instruction's current ASL owner.

<!-- PTO-READER-BLOCK: arch-memory-operations-example-usage role=example-usage -->
## Non-normative reading example

An atomic instruction selecting `Atomic_ADD` still needs its own address, width, order, fault, and commit contract; this enumeration contributes only the operation identity.

Likewise, `AddressUpdate_PostIndex` identifies the mode but does not by itself state whether a failed access updates the base register.

<!-- PTO-READER-BLOCK: arch-memory-operations-related-owners role=related-owners-navigation -->
## Related owners

- [Memory model types](memory-model.md)
- [Atomicity](../memory-model/atomicity.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/memory-operations.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-MEMORY-OPERATIONS","surface":"arch","classification":["data-types","memory-operations"],"depends_on":["PTO-ARCH-DATA-TYPES-MEMORY-MODEL"]}
type AddressUpdateMode of enumeration {
    AddressUpdate_None,
    AddressUpdate_PreIndex,
    AddressUpdate_PostIndex
};

type AtomicOperation of enumeration {
    Atomic_SWAP,
    Atomic_ADD,
    Atomic_AND,
    Atomic_OR,
    Atomic_XOR,
    Atomic_SMIN,
    Atomic_SMAX,
    Atomic_UMIN,
    Atomic_UMAX
};
```
<!-- GENERATED-ASL-END: unit -->
