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

This unit names the address-update and atomic-operation selectors used by scalar memory execution.

It contains two enumerations and no executable behavior, so it defines which operations exist and not what any of them does.

<!-- PTO-READER-BLOCK: arch-memory-operations-concepts-state role=concepts-state -->
## Concepts and visible state

`AddressUpdateMode` contains `AddressUpdate_None`, `AddressUpdate_PreIndex`, and `AddressUpdate_PostIndex`.

`AtomicOperation` contains `Atomic_SWAP`, `Atomic_ADD`, `Atomic_AND`, `Atomic_OR`, `Atomic_XOR`, `Atomic_SMIN`, `Atomic_SMAX`, `Atomic_UMIN`, and `Atomic_UMAX`.

Design point: keeping both selector families in one owner means the same operation identity is used wherever it appears, so a consumer never has to reconcile two names for one atomic operation.

<!-- PTO-READER-BLOCK: arch-memory-operations-rules-interactions role=rules-interactions -->
## Rules and interactions

Pre-index and post-index are distinct selectors, so the selector alone does not state when the base update is computed or committed; the consuming instruction owner decides that.

Signed and unsigned minimum and maximum use separate members, so the signedness of the comparison is part of the operation identity rather than an operand interpretation chosen later.

No member implies a fault, an ordering, an access size, or a publication rule, because those remain parameters of the consuming instruction owner.

<!-- PTO-READER-BLOCK: arch-memory-operations-boundaries role=boundaries -->
## Architectural boundaries

Design point: because a selector names only the operation, two instructions can share `Atomic_ADD` while defining different widths, orderings, and fault behavior without either one redefining the other.

The unit has no fallback and no implementation-defined selector, so a decoder must map to one of the declared members before execution.

This unit declares two enumerations and contains no functions, so the member lists above are the complete definition of the selector vocabulary.

<!-- PTO-READER-BLOCK: arch-memory-operations-example-usage role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

Selector identity is portable, while support for a particular instruction form and its legality remain with that instruction's current ASL owner.

Reading a memory operation means reading the consuming instruction owner for the address, width, ordering, fault, and commit contract.

An atomic instruction selecting `Atomic_ADD` still needs its own address, width, order, fault, and commit contract, and `AddressUpdate_PostIndex` does not by itself state whether a failed access updates the base register.

Two instructions that share one selector may therefore differ in width and in ordering, so the selector alone never fixes the size of the access a consumer performs.

<!-- PTO-READER-BLOCK: arch-memory-operations-related-owners role=related-owners-navigation -->
## Related owners

- [Memory model types](memory-model.md) defines the event records these selectors act on.

- [Atomicity](../memory-model/atomicity.md) defines the atomicity requirements themselves.
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
