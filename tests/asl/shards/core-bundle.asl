func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalDecoders();
    ValidateSystemRegisterResetAndAccess();
    ValidateCanonicalCommandExecution();
    TestUnifiedInstructionDispatch();
    TestCrossDispatchExecutionContract();
    TestScalarState();
    TestPredicateStateContract();
    TestTrapRoutingPolicy();
    TestCompleteTrapEnvelope();
    TestVisibleTrapContextRegisters();
    TestBundleStateLifecycle();
    TestBundleFaults();
    TestTrapContextRouteAndRecover();
    TestBundleConfigurationState();
    TestDecodedBundleStartAndStop();
    TestBundleCommandTotalityBoundaries();
    TestBundleOperationDescriptorFields();
    TestBundleTileCommitLifecycle();
    TestBundleTileCommitRollback();
    TestTileRegisterMapping();
    TestScalarTemporaryQueues();
    TestTileAllocationState();
    TestInterruptRegisterState();
    return 0;
end;
