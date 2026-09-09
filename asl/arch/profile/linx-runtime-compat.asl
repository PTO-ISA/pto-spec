// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-LINX-RUNTIME-COMPAT","surface":"arch","classification":["profile","linx-runtime-compat"],"depends_on":["PTO-ARCH-PROFILE-RESET","PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING","PTO-BLOCK-MODEL-STATE-TYPES"]}
//
// This file is the single profile owner for the optional Linx runtime
// compatibility surface used by the ASL-backed ELF bring-up runner.  The
// configuration switches are declared in tile-allocation.asl because they
// are model configuration values; all semantic users go through the helpers
// below so the compatibility policy cannot spread across instruction code.
//
// The portable PTO profile is the default.  With both compatibility switches
// disabled, these helpers reproduce the ordinary SYS-block and body-placement
// rules exactly.

// NDF-BEGIN: PTO-PROFILE-LINX-RUNTIME-COMPAT-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// The Linx runtime compatibility surface MUST be explicitly selected by a
// named model profile.  Its switches MUST default to FALSE, and no portable
// PTO legality, state, or numeric rule may depend on an opt-in switch.
// NDF-END: PTO-PROFILE-LINX-RUNTIME-COMPAT-001

// NDF-BEGIN: PTO-PROFILE-LINX-PEID-SSR-001
// ndf: kind=contract level=L1 layer=state status=accepted
// When the named Linx runtime profile is selected, read-only SSR address
// 0x0802 supplies the current PE/thread identity.  The alias is unavailable
// in the portable profile and MUST NOT create a writable or persistent
// system-register state distinct from the selected PE context.
// NDF-END: PTO-PROFILE-LINX-PEID-SSR-001

// NDF-BEGIN: PTO-PROFILE-LINX-NON-SYS-SYSTEM-OPS-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// When both Linx compatibility switches are selected, system operations may
// execute in the runtime's non-SYS startup block.  The portable profile MUST
// continue to require an active SYS block with body placement.  This profile
// exception changes applicability only; decode, operand legality, operation,
// fault, and state effects remain owned by the instruction's ASL handler.
// NDF-END: PTO-PROFILE-LINX-NON-SYS-SYSTEM-OPS-001

// NDF-BEGIN: PTO-PROFILE-LINX-ACRC-EXIT-OBSERVATION-001
// ndf: kind=contract level=L1 layer=concurrency status=accepted
// ACRC MUST first execute its ASL-defined request/terminal semantics.  A
// runtime may observe the resulting ACRC event and terminate a direct-boot
// process according to its host ABI, but it MUST NOT skip ACRC based only on
// its encoding or replace its ASL state transition with a host-side finisher.
// NDF-END: PTO-PROFILE-LINX-ACRC-EXIT-OBSERVATION-001

// NDF-BEGIN: PTO-PROFILE-HOST-MEMORY-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// A named runtime profile may provide sparse host-backed data memory for
// addresses outside the bounded reference byte array.  The portable profile
// MUST keep the bounded in-ASL array and its existing permission/fault rules;
// enabling host-backed memory MUST NOT alter decode, Tile legality, ordering,
// or definedness semantics.
// NDF-END: PTO-PROFILE-HOST-MEMORY-001

readonly func PTOModelLinxRuntimeCompatibilityEnabled() => boolean
begin
    return PTO_MODEL_LINX_RUNTIME_COMPAT;
end;

pure func PTOModelLinxRuntimeSubfeatureSelected(
    master_selected: boolean, subfeature_selected: boolean) => boolean
begin
    return master_selected && subfeature_selected;
end;

readonly func PTOModelLinxRuntimePEIDAddress() => SystemRegisterAddress
begin
    return Zeros{24} + 0x0802;
end;

readonly func PTOModelLinxRuntimePEIDEnabled(
    address: SystemRegisterAddress) => boolean
begin
    return PTOModelLinxRuntimeCompatibilityEnabled() &&
           address == PTOModelLinxRuntimePEIDAddress();
end;

readonly func PTOModelLinxRuntimeAllowsPreBodyControlSetter() => boolean
begin
    return PTOModelLinxRuntimeCompatibilityEnabled();
end;

readonly func PTOModelLinxRuntimeAllowsNonSystemOperation() => boolean
begin
    return PTOModelLinxRuntimeSubfeatureSelected(
        PTOModelLinxRuntimeCompatibilityEnabled(),
        PTO_MODEL_ALLOW_SYSTEM_OPS_IN_NON_SYS_BLOCK);
end;

readonly func PTOModelLinxRuntimeSystemOperationApplicable(
    block_type: BundleKind, body_active: boolean) => boolean
begin
    if PTOModelLinxRuntimeAllowsNonSystemOperation() then
        return TRUE;
    end;
    return body_active && block_type == BundleKind_System;
end;

pure func PTOModelLinxRuntimeACRCExitMarkerSelected(
    master_selected: boolean, bundle_active: boolean,
    block_type: BundleKind, body_active: boolean,
    request_type: bits(4)) => boolean
begin
    // Direct-boot Linx kernels use ACRC 1 as a process completion marker in
    // their ordinary code block.  It is a named profile behavior: the
    // instruction remains decoded and executed by the ASL handler, but this
    // profile does not route that one marker through the portable ACR service
    // request machinery.
    // Direct-boot startup images may issue the marker immediately after an
    // empty C.BSTART or at a block boundary, before body-active is latched.
    // The explicit profile therefore keys this compatibility marker on the
    // request type and profile selection; decode, operand checks, ASL handler
    // execution, and terminal-state publication remain unchanged.
    // body_active is intentionally not part of the result: the direct-boot
    // marker may occur immediately after bundle start, before body entry.
    return master_selected && bundle_active &&
           block_type == BundleKind_Standard &&
           request_type == '0001';
end;

readonly func PTOModelLinxRuntimeACRCExitMarkerApplicable(
    bundle_active: boolean, block_type: BundleKind, body_active: boolean,
    request_type: bits(4)) => boolean
begin
    return PTOModelLinxRuntimeACRCExitMarkerSelected(
        PTOModelLinxRuntimeCompatibilityEnabled(), bundle_active,
        block_type, body_active, request_type);
end;

readonly func PTOModelLinxRuntimeACRCRequiresASLExecution() => boolean
begin
    return TRUE;
end;

readonly func PTOModelHostMemoryEnabled() => boolean
begin
    return PTOModelLinxRuntimeSubfeatureSelected(
        PTOModelLinxRuntimeCompatibilityEnabled(), PTO_MODEL_HOST_MEMORY);
end;

pure func PTOModelFrameStackPointerIndexSelected(
    master_selected: boolean,
    configured_index: integer {0..31}) => GPRIndex
begin
    if master_selected then return configured_index as GPRIndex;
    else return 1;
    end;
end;

readonly func PTOModelConfiguredFrameStackPointerIndex() => GPRIndex
begin
    return PTOModelFrameStackPointerIndexSelected(
        PTOModelLinxRuntimeCompatibilityEnabled(), PTO_MODEL_FRAME_SP_INDEX);
end;

pure func PTOModelMSETMaxBytesSelected(
    master_selected: boolean,
    configured_limit: integer {63..262144}) => integer {63..262144}
begin
    if master_selected then return configured_limit;
    else return 262144;
    end;
end;

readonly func PTOModelEffectiveMSETMaxBytes() => integer {63..262144}
begin
    return PTOModelMSETMaxBytesSelected(
        PTOModelLinxRuntimeCompatibilityEnabled(), PTO_MODEL_MSET_MAX_BYTES);
end;

readonly func PTOModelLinxTraceBoundaryCompatibilityEnabled() => boolean
begin
    return PTOModelLinxRuntimeSubfeatureSelected(
        PTOModelLinxRuntimeCompatibilityEnabled(),
        PTO_MODEL_LINX_TRACE_BOUNDARY_COMPAT);
end;

readonly func PTOModelLinxLegacyCompressedStopEnabled() => boolean
begin
    return PTOModelLinxRuntimeSubfeatureSelected(
        PTOModelLinxRuntimeCompatibilityEnabled(),
        PTO_MODEL_LINX_LEGACY_C_BSTOP);
end;
