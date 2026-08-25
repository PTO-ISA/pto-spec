<!-- GENERATED FROM: asl/arch/profile/applicability.asl -->
# Applicability

**Normative ASL source:** `asl/arch/profile/applicability.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-APPLICABILITY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-profile-applicability-purpose role=purpose-scope -->
## Purpose and scope

This unit implements the PTO v0 access-control rule for system registers. It decides whether a read or write to a `SystemRegisterAddress` is permitted for a given `AccessControlRing`.

<!-- PTO-READER-BLOCK: arch-profile-applicability-concepts role=concepts-state -->
## Address and privilege inputs

- The decision receives the register `address`, a `write` indicator, and the current `ring`.
- The PTO v0 rule uses the low `12` address bits and the ring number.
- Base registers occupy addresses below `0x0f00`; context, translation, and debug families begin at that boundary.

<!-- PTO-READER-BLOCK: arch-profile-applicability-rules role=rules-interactions -->
## Access rule

`SystemRegisterAccessPermitted` returns true for any address whose low `12` bits are below `0x0f00`. At or above `0x0f00`, it returns true only when `ring == 0`. The current implementation applies the same boundary to reads and writes.

<!-- PTO-READER-BLOCK: arch-profile-applicability-boundaries role=boundaries -->
## Profile boundary

This is an `implementation` function for the PTO v0 reference profile. It is not a portable promise that every future named profile uses the same address split or privilege rule.

<!-- PTO-READER-BLOCK: arch-profile-applicability-example role=example-usage -->
## Non-normative access example

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-profile-applicability-related role=related-owners-navigation -->
## Related owners

- Profile reset establishes initial ACR and register state.
- System-register access instructions call this profile predicate before their effects.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/applicability.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-APPLICABILITY","surface":"arch","classification":["profile","applicability"],"depends_on":["PTO-ARCH-PROFILE-RESET"]}
readonly implementation func SystemRegisterAccessPermitted(
    address: SystemRegisterAddress, write: boolean,
    ring: AccessControlRing) => boolean
begin
    // Base registers are available at every level. Context, translation, and
    // debug register families are ACR0-only in the PTO v0 profile.
    return UInt(address[11:0]) < 0x0f00 || ring == 0;
end;
```
<!-- GENERATED-ASL-END: unit -->
