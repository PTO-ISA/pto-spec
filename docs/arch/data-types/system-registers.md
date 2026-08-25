<!-- GENERATED FROM: asl/arch/data-types/system-registers.asl -->
# System Registers

**Normative ASL source:** `asl/arch/data-types/system-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-SYSTEM-REGISTERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-system-register-types-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit defines the shared symbolic namespaces for base system registers, access classes, and cache/TLB maintenance operations.

It supplies typed identities; address mapping, access control, register state, and maintenance effects are owned elsewhere.

<!-- PTO-READER-BLOCK: arch-system-register-types-concepts-state role=concepts-state -->
## Concepts and visible state

- `SystemRegister` names thread/global pointers, time/cycle, core and thread identity, vendor/version/features, tile capacity, and block identity registers.
- `SystemRegisterAccess` distinguishes unknown, read-only, write-only, and read-write access classes.
- `MaintenanceOperation` names data-cache, instruction-cache, bundle-cache, and TLB invalidation or cleaning variants.

<!-- PTO-READER-BLOCK: arch-system-register-types-rules-interactions role=rules-interactions -->
## Rules and interactions

An enum member identifies a register or operation but does not assign its encoded address.

Access classification is separate from the current access-control ring and concrete read/write behavior.

Maintenance variants remain distinct, including whole-cache, virtual-address, and set/way forms where declared.

<!-- PTO-READER-BLOCK: arch-system-register-types-boundaries role=boundaries -->
## Architectural boundaries

This unit does not create the system-register file and does not state reset values. Follow the state and addressing owners for those contracts.

A declared maintenance identity does not by itself guarantee instruction availability or define epoch changes; the executing owner supplies those effects.

<!-- PTO-READER-BLOCK: arch-system-register-types-example-usage role=example-usage -->
## Non-normative reading example

`SystemRegister_TIME` names a system register.

The addressing and timer/state owners define its architectural address and value behavior.

`Maintenance_TLB_IALL` identifies the all-entry TLB operation.

The invoking instruction still owns legality, operands, and visible maintenance state changes.

<!-- PTO-READER-BLOCK: arch-system-register-types-related-owners role=related-owners-navigation -->
## Related owners

- [System-register addressing](../system-registers/addressing.md)
- [System-register access control](../system-registers/access-control.md)
- [Maintenance behavior](../system-registers/maintenance.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/system-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-SYSTEM-REGISTERS","surface":"arch","classification":["data-types","system-registers"],"depends_on":["PTO-ARCH-DATA-TYPES-MEMORY-OPERATIONS"]}
type SystemRegister of enumeration {
    SystemRegister_THREAD_PTR,
    SystemRegister_GLOBAL_PTR,
    SystemRegister_TIME,
    SystemRegister_CORE_STATE,
    SystemRegister_CORE_ID,
    SystemRegister_THREAD_ID,
    SystemRegister_VENDOR,
    SystemRegister_VERSION,
    SystemRegister_CORE_FEATURE,
    SystemRegister_CORE_FEATURE_ENABLE,
    SystemRegister_TILE_CAPACITY,
    SystemRegister_BLOCKNUM,
    SystemRegister_BLOCKID,
    SystemRegister_CYCLE
};

type SystemRegisterAccess of enumeration {
    SystemRegisterAccess_Unknown,
    SystemRegisterAccess_ReadOnly,
    SystemRegisterAccess_WriteOnly,
    SystemRegisterAccess_ReadWrite
};

type MaintenanceOperation of enumeration {
    Maintenance_DC_IALL,
    Maintenance_DC_IVA,
    Maintenance_DC_ISW,
    Maintenance_DC_ZVA,
    Maintenance_DC_CVA,
    Maintenance_DC_CIVA,
    Maintenance_DC_CSW,
    Maintenance_DC_CISW,
    Maintenance_IC_IALL,
    Maintenance_IC_IVA,
    Maintenance_BC_IALL,
    Maintenance_BC_IVA,
    Maintenance_TLB_IV,
    Maintenance_TLB_IAV,
    Maintenance_TLB_IA,
    Maintenance_TLB_IALL
};
```
<!-- GENERATED-ASL-END: unit -->
