<!-- GENERATED FROM: asl/arch/data-types/memory-operations.asl -->
# Memory Operations

**Normative ASL source:** `asl/arch/data-types/memory-operations.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-MEMORY-OPERATIONS}

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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
