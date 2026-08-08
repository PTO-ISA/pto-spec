// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTTRAPCONTEXTROUTEANDRECOVER-FAULT-001","source":"asl/block/model/faults/rollback.asl","requirements":[],"kind":"fault","summary":"migrated independent behavior point for TestTrapContextRouteAndRecover","pass_condition":"TestTrapContextRouteAndRecover completes without assertion failure","related_sources":[]}
pure func BundleTestTEPLStart(selector: bits(10), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = data_type;
    return instruction;
end;

func TestTrapContextRouteAndRecover()
begin
    ResetBundleControlState();
    ClearFault();
    SetCurrentACR(0);
    WriteSystemRegisterAddress(Zeros{24} + 0x1f01, Zeros{PTO_XLEN} + 0x900);

    SetCurrentACR(2);
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    WriteBPC(Zeros{PTO_XLEN} + 0x340);
    SetBundleArgument(Zeros{PTO_XLEN} + 0x55);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x11);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x22);
    BeginBundle(BundleKind_Standard, BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x500, Zeros{PTO_XLEN} + 0x304,
        Zeros{PTO_XLEN} + 0x304, TRUE);
    let tepl_instruction = BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24);
    let tepl_decoded = DecodeCommandForm(tepl_instruction, 32);
    assert tepl_decoded != PTO_COMMAND_FORM_COUNT;
    let tepl_form = tepl_decoded as integer {0..PTO_COMMAND_FORM_COUNT-1};
    InstallBundleOperationDescriptor(
        DecodeBundleOperationDescriptor(tepl_instruction, tepl_form));
    EnterBundleBody();
    SetBundleDimension(2, Zeros{PTO_XLEN} + 0x33);
    SetBundleScalarBinding(31, 5, 2, 3, 4, 3);
    SetBundleTileBinding(15, TRUE, 2, 7, '1111', TRUE, TRUE, 10, 11,
        TRUE);
    SetBundleControlAttributeState(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE);
    SetBundleDataAttributeState(Zeros{5} + 1, Zeros{5} + 2,
        Zeros{2} + 3, Zeros{3} + 1, Zeros{3} + 2, TRUE);

    SetFault(Fault_DataPage, Zeros{PTO_XLEN} + 0x2222);
    assert CurrentACR() == 1;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    assert _ACRTrapNumber[[1]] == Zeros{6} + 35;
    assert _ACRTrapArgument0[[1]] == Zeros{PTO_XLEN} + 0x2222;
    assert _TrapContexts[[1]].valid;
    assert _TrapContexts[[1]].source_acr == 2;
    assert _TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x500;
    assert _TrapContexts[[1]].bpc == Zeros{PTO_XLEN} + 0x500;
    assert _TrapContexts[[1]].bundle_argument == Zeros{PTO_XLEN} + 0x55;
    assert _TrapContexts[[1]].bundle_operation.valid;
    assert _TrapContexts[[1]].bundle_operation.form_identity ==
        Zeros{7} + tepl_form;
    assert _TrapContexts[[1]].bundle_operation.selector == Zeros{10};
    assert _TrapContexts[[1]].bundle_operation.data_type == Zeros{5} + 24;
    assert _TrapContexts[[1]].bundle_body_active;
    assert _TrapContexts[[1]].bundle_dimensions[[2]] ==
        Zeros{PTO_XLEN} + 0x33;
    assert _TrapContexts[[1]].bundle_scalar_bindings[[31]].destination == 5;
    assert _TrapContexts[[1]].bundle_tile_bindings[[15]].destination == 2;
    assert _TrapContexts[[1]].bundle_control_attributes.atomic;
    assert _TrapContexts[[1]].bundle_data_attributes.saturating;
    assert _TrapContexts[[1]].t_queue[[0]] == Zeros{PTO_XLEN} + 0x11;
    assert _TrapContexts[[1]].u_queue[[0]] == Zeros{PTO_XLEN} + 0x22;

    WriteTPC(Zeros{PTO_XLEN} + 0xabc);
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x99);
    SetBundleDimension(2, Ones{PTO_XLEN});
    SetBundleScalarBinding(31, 1, 1, 1, 1, 1);
    SetBundleTileBinding(15, FALSE, 1, 0, '0011', FALSE, FALSE, 1, 1,
        FALSE);
    SetBundleControlAttributeState(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE);
    SetBundleDataAttributeState(Zeros{5}, Zeros{5}, Zeros{2},
        Zeros{3}, Zeros{3}, FALSE);
    ArchitectureEnterRequest('0001');
    assert CurrentACR() == 2;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x500;
    assert ReadBPC() == Zeros{PTO_XLEN} + 0x500;
    assert _BundleArgument == Zeros{PTO_XLEN} + 0x55;
    assert _BundleOperation.valid;
    assert _BundleOperation.form_identity == Zeros{7} + tepl_form;
    assert _BundleOperation.selector == Zeros{10};
    assert _BundleOperation.data_type == Zeros{5} + 24;
    assert _CommitArgument == Zeros{PTO_XLEN} + 0x55;
    assert BundleBodyIsActive();
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x11;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x22;
    assert _BundleDimensions[[2]] == Zeros{PTO_XLEN} + 0x33;
    assert _BundleScalarBindings[[31]].destination == 5;
    assert _BundleScalarBindings[[31]].source_count == 3;
    assert _BundleTileBindings[[15]].destination == 2;
    assert _BundleTileBindings[[15]].pe_mask == '1111';
    assert _BundleControlAttributes.atomic;
    assert _BundleControlAttributes.release;
    assert _BundleDataAttributes.data_type == Zeros{5} + 1;
    assert _BundleDataAttributes.saturating;
    assert !_TrapContexts[[1]].valid;
end;
func main() => integer
begin
    ResetProfileState();
    TestTrapContextRouteAndRecover();
    return 0;
end;
