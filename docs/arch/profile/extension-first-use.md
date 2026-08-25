<!-- GENERATED FROM: asl/arch/profile/extension-first-use.asl -->
# Extension First Use

**Normative ASL source:** `asl/arch/profile/extension-first-use.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-EXTENSION-FIRST-USE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-extension-first-use-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the profile hook for a precise first-use trap on optional `VECTOR` or `CUBE` extension state. The portable default is disabled and has no effect.

<!-- PTO-READER-BLOCK: arch-extension-first-use-concepts role=concepts-state -->
## Hook inputs

- `ExtensionFirstUseKind` distinguishes `ExtensionFirstUseKind_VECTOR` and `ExtensionFirstUseKind_CUBE`.
- `ExtensionFirstUseEnabled` asks whether the named kind is active.
- `RaiseExtensionFirstUse` receives the extension kind, source `AccessControlRing`, and manager `AccessControlRing`.

<!-- PTO-READER-BLOCK: arch-extension-first-use-rules role=rules-interactions -->
## Default and enabling rules

The portable definition is disabled and effect-free.

Both `impdef` functions implement that default by returning false.

An enabling named profile defines the covered kinds, enable state, source and manager ACRs, precise trap envelope, pre-effect ordering, retry state, and context-save progress.

<!-- PTO-READER-BLOCK: arch-extension-first-use-boundaries role=boundaries -->
## Architectural boundary

The hook does not create extension state or infer when an instruction first uses it. Instruction and profile owners decide whether to call the hook before effects; disabled behavior remains effect-free.

<!-- PTO-READER-BLOCK: arch-extension-first-use-example role=example-usage -->
## Non-normative profile example

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-extension-first-use-related role=related-owners-navigation -->
## Related owners

- Fault precision provides the trap-entry mechanisms available to profiles.
- Covered instruction owners provide the pre-effect call sites and retry boundaries.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/extension-first-use.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-EXTENSION-FIRST-USE","surface":"arch","classification":["profile","extension-first-use"],"depends_on":["PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION"]}
// NDF-BEGIN: PTO-ARCH-EXTENSION-FIRST-USE-PROFILE-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// A target profile MAY provide a precise extension first-use trap. The
// portable default MUST remain disabled and effect-free. An enabling profile
// MUST define covered kinds, enable state, source and manager ACRs, the exact
// trap envelope, pre-effect ordering, retry state, and context-save progress.
// NDF-END: PTO-ARCH-EXTENSION-FIRST-USE-PROFILE-001

type ExtensionFirstUseKind of enumeration {
    ExtensionFirstUseKind_VECTOR,
    ExtensionFirstUseKind_CUBE
};

readonly impdef func ExtensionFirstUseEnabled(kind: ExtensionFirstUseKind)
    => boolean
begin
    return FALSE;
end;

impdef func RaiseExtensionFirstUse(kind: ExtensionFirstUseKind,
                                  source: AccessControlRing,
                                  manager: AccessControlRing) => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: unit -->
