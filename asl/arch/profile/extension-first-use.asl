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
