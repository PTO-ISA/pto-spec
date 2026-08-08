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

