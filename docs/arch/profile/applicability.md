<!-- GENERATED FROM: asl/arch/profile/applicability.asl -->
# Applicability

**Normative ASL source:** `asl/arch/profile/applicability.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-APPLICABILITY}

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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
