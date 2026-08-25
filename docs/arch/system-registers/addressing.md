<!-- GENERATED FROM: asl/arch/system-registers/addressing.asl -->
# Addressing

**Normative ASL source:** `asl/arch/system-registers/addressing.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-system-addressing-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit owns the base system-register state record and the profile reset hook used to initialize the profile-owned part of architectural state.

<!-- PTO-READER-BLOCK: arch-system-addressing-concepts-state role=concepts-state -->
## Base system-register state

`BaseSystemRegisterState` contains `thread_ptr`, `global_ptr`, `core_state`, `core_id`, `thread_id`, `vendor`, `version`, `core_feature`, `core_feature_enable`, `tile_capacity`, `blocknum`, `blockid`, and `cycle`, each represented as a `Word`.

The architecture-visible owner is `_SystemRegisters`, identified by `PTO-STATE-ARCH-SYSTEM-REGISTERS`.

<!-- PTO-READER-BLOCK: arch-system-addressing-rules-interactions role=rules-interactions -->
## Profile reset hook

`ResetProfileState` is implementation-defined and may be overridden by the active concrete profile. The default body in this owner sets `_CurrentACR` to `0` and clears `_SystemRegisters.cycle` to `Zeros{PTO_XLEN}`.

<!-- PTO-READER-BLOCK: arch-system-addressing-boundaries role=boundaries -->
## Architectural boundaries

The default body does not write the other fields of `BaseSystemRegisterState`. This page therefore does not claim a reset value for fields that the owner leaves untouched.

Profile-specific reset behavior must remain behind the `ResetProfileState` hook rather than being inferred from a target implementation.

<!-- PTO-READER-BLOCK: arch-system-addressing-example-usage role=example-usage -->
## Non-normative reset reading example

When checking the portable default, expect ACR0 and a zero cycle counter after `ResetProfileState`. Treat the value of `vendor` or `tile_capacity` as unresolved by this helper unless another current owner or active profile defines it.

<!-- PTO-READER-BLOCK: arch-system-addressing-related-owners role=related-owners-navigation -->
## Related owners

- [Trap-context data type](../data-types/trap-context.md) is the declared dependency.
- [Context registers](context.md) maps ring-relative context registers into extended-system-register storage.
- [Numeric status](../state/numeric-status.md) uses the `core_state` field owned here.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/system-registers/addressing.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING","surface":"arch","classification":["system-registers","addressing"],"depends_on":["PTO-ARCH-DATA-TYPES-TRAP-CONTEXT"]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-SYSTEM-REGISTERS","classification":["architecture","system-registers"],"scope":"system","owner":"PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING","members":["_SystemRegisters"],"depends_on":[]}
type BaseSystemRegisterState of record {
    thread_ptr: Word,
    global_ptr: Word,
    core_state: Word,
    core_id: Word,
    thread_id: Word,
    vendor: Word,
    version: Word,
    core_feature: Word,
    core_feature_enable: Word,
    tile_capacity: Word,
    blocknum: Word,
    blockid: Word,
    cycle: Word
};

var _SystemRegisters : BaseSystemRegisterState;

impdef func ResetProfileState()
begin
    // Overridden by the active concrete profile.
    _CurrentACR = 0;
    _SystemRegisters.cycle = Zeros{PTO_XLEN};
end;
```
<!-- GENERATED-ASL-END: unit -->
