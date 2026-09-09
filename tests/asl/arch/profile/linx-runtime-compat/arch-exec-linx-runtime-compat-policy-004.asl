// PTO-TEST: {"id":"PTO-AVS-ARCH-PROFILE-LINX-RUNTIME-COMPAT-POLICY-004","source":"asl/arch/profile/linx-runtime-compat.asl","requirements":["PTO-PROFILE-LINX-RUNTIME-COMPAT-001","PTO-PROFILE-LINX-NON-SYS-SYSTEM-OPS-001","PTO-PROFILE-LINX-ACRC-EXIT-OBSERVATION-001","PTO-PROFILE-HOST-MEMORY-001"],"kind":"execution","summary":"explicit Linx runtime selections enforce the master gate and ACRC marker context","pass_condition":"pure policy helpers accept the enabled Standard pre-body ACRC marker while rejecting no-bundle, SYS, non-request-1, and master-disabled cases; every subfeature and configurable limit remains portable when the master is disabled","related_sources":["asl/arch/features/tile-allocation.asl","asl/arch/profile/reference-profile.asl","asl/block/model/commit/effects.asl","asl/block/model/lifecycle/lifetime.asl"]}
func main() => integer
begin
    assert PTOModelLinxRuntimeACRCExitMarkerSelected(
        TRUE, TRUE, BundleKind_Standard, FALSE, '0001');
    assert PTOModelLinxRuntimeACRCExitMarkerSelected(
        TRUE, TRUE, BundleKind_Standard, TRUE, '0001');
    assert !PTOModelLinxRuntimeACRCExitMarkerSelected(
        TRUE, FALSE, BundleKind_Standard, FALSE, '0001');
    assert !PTOModelLinxRuntimeACRCExitMarkerSelected(
        TRUE, TRUE, BundleKind_System, FALSE, '0001');
    assert !PTOModelLinxRuntimeACRCExitMarkerSelected(
        TRUE, TRUE, BundleKind_Standard, FALSE, '0000');
    assert !PTOModelLinxRuntimeACRCExitMarkerSelected(
        FALSE, TRUE, BundleKind_Standard, FALSE, '0001');

    assert PTOModelLinxRuntimeSubfeatureSelected(TRUE, TRUE);
    assert !PTOModelLinxRuntimeSubfeatureSelected(FALSE, TRUE);
    assert !PTOModelLinxRuntimeSubfeatureSelected(TRUE, FALSE);
    assert PTOModelFrameStackPointerIndexSelected(TRUE, 3) == 3;
    assert PTOModelFrameStackPointerIndexSelected(FALSE, 3) == 1;
    assert PTOModelMSETMaxBytesSelected(TRUE, 63) == 63;
    assert PTOModelMSETMaxBytesSelected(FALSE, 63) == 262144;
    return 0;
end;
