// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-APPLICABILITY","surface":"arch","classification":["profile","applicability"],"depends_on":["PTO-ARCH-PROFILE-RESET"]}
readonly implementation func SystemRegisterAccessPermitted(
    address: SystemRegisterAddress, write: boolean,
    ring: AccessControlRing) => boolean
begin
    // Base registers are available at every level. Context, translation, and
    // debug register families are ACR0-only in the PTO v0 profile.
    return UInt(address[11:0]) < 0x0f00 || ring == 0;
end;

