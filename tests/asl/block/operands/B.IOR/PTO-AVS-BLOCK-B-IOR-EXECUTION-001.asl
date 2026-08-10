// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOR-EXECUTION-001","source":"asl/block/operands/B.IOR.asl","requirements":["PTO-INST-BLOCK-B-IOR"],"kind":"execution","summary":"migrated independent behavior point for complete-bundle GPR resolution and TestBundleScalarBindingSchemaDefaults","pass_condition":"TestBundleScalarBindingSchemaDefaults and TestBundleOrderedGPRControls complete without assertion failure","related_sources":[]}
pure func BundleTestTEPLStart(selector: bits(10), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BundleTestTLSUStart(function: bits(5), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BundleTestScalarBinding(destination: bits(5), source0: bits(5),
                                  source1: bits(5), source2: bits(5))
                                  => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[11:7] = destination;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[31:27] = source2;
    return instruction;
end;

func TestBundleScalarBindingSchemaDefaults()
begin
    // Every encoded B.IOR field rejects selectors outside the 24 architectural
    // GPRs before changing bundle state.
    for selector = 24 to 31 do
        ResetProfileState();
        let invalid_destination = ExecuteCommandInstruction(
            BundleTestScalarBinding(
                Zeros{5} + selector, Zeros{5}, Zeros{5}, Zeros{5}), 32);
        assert invalid_destination == CommandExecution_Rejected;
        assert !_BundleScalarBindings[[0]].valid;

        ResetProfileState();
        let invalid_source0 = ExecuteCommandInstruction(
            BundleTestScalarBinding(
                Zeros{5}, Zeros{5} + selector, Zeros{5}, Zeros{5}), 32);
        assert invalid_source0 == CommandExecution_Rejected;
        assert !_BundleScalarBindings[[0]].valid;

        ResetProfileState();
        let invalid_source1 = ExecuteCommandInstruction(
            BundleTestScalarBinding(
                Zeros{5}, Zeros{5}, Zeros{5} + selector, Zeros{5}), 32);
        assert invalid_source1 == CommandExecution_Rejected;
        assert !_BundleScalarBindings[[0]].valid;

        ResetProfileState();
        let invalid_source2 = ExecuteCommandInstruction(
            BundleTestScalarBinding(
                Zeros{5}, Zeros{5}, Zeros{5}, Zeros{5} + selector), 32);
        assert invalid_source2 == CommandExecution_Rejected;
        assert !_BundleScalarBindings[[0]].valid;
    end;

    ResetProfileState();
    let first = ExecuteCommandInstruction(
        BundleTestScalarBinding(
            Zeros{5}, Zeros{5} + 2, Zeros{5}, Zeros{5}), 32);
    let second = ExecuteCommandInstruction(
        BundleTestScalarBinding(
            Zeros{5}, Zeros{5} + 3, Zeros{5}, Zeros{5}), 32);
    assert first == CommandExecution_Executed;
    assert second == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert _BundleScalarBindings[[0]].valid;
    assert _BundleScalarBindings[[0]].source0 == 2;

    let tadds_operation = DecodeTileOperation(TileDecode_TEPL, Zeros{12} + 0x20)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};

    // A one-scalar operation is complete when B.IOR is absent; scalar0 then
    // remains the architectural zero default.
    ResetProfileState();
    let omitted_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10} + 0x20, Zeros{5} + 24), 32);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 0, 0, TRUE);
    assert omitted_start == CommandExecution_Executed;
    assert !_BundleScalarBindings[[0]].valid;
    assert BundleOperationBindingsComplete(tadds_operation);
    let omitted_operands = BundleTileInstructionOperands(tadds_operation);
    assert omitted_operands.scalar0 == Zeros{PTO_XLEN};

    // An encoded zero is a real R0 selector. Fields outside the resolved
    // one-source schema must remain zero.
    ResetProfileState();
    let zero_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10} + 0x20, Zeros{5} + 24), 32);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 0, 0, TRUE);
    let zero_binding = ExecuteCommandInstruction(
        BundleTestScalarBinding(Zeros{5}, Zeros{5}, Zeros{5}, Zeros{5}), 32);
    assert zero_start == CommandExecution_Executed;
    assert zero_binding == CommandExecution_Executed;
    assert BundleOperationBindingsComplete(tadds_operation);

    ResetProfileState();
    let extra_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10} + 0x20, Zeros{5} + 24), 32);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 0, 0, TRUE);
    let extra_binding = ExecuteCommandInstruction(
        BundleTestScalarBinding(
            Zeros{5}, Zeros{5} + 2, Zeros{5} + 3, Zeros{5} + 4), 32);
    assert extra_start == CommandExecution_Executed;
    assert extra_binding == CommandExecution_Executed;
    assert !BundleOperationBindingsComplete(tadds_operation);

    // TQUANT consumes two scalar sources. Reusing one architectural GPR for
    // both inputs is legal.
    ResetProfileState();
    let quant_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10} + 0x6a, Zeros{5} + 24), 32);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 0, 0, TRUE);
    let quant_binding = ExecuteCommandInstruction(
        BundleTestScalarBinding(
            Zeros{5}, Zeros{5} + 5, Zeros{5} + 5, Zeros{5}), 32);
    let quant_operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x6a)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert quant_start == CommandExecution_Executed;
    assert quant_binding == CommandExecution_Executed;
    assert BundleOperationBindingsComplete(quant_operation);

    let tload_operation = DecodeTileOperation(
        TileDecode_TLSU, Zeros{12})
        as integer {0..PTO_TILE_OPERATION_COUNT-1};

    // TLOAD retains the existing B.IOR encoding: RegSrc0 is base and RegSrc1
    // is row stride in elements. Omission uses zero base and dense LB2 stride.
    ResetProfileState();
    let omitted_tload_start = ExecuteCommandInstruction(
        BundleTestTLSUStart(Zeros{5}, Zeros{5} + 24), 32);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 7);
    AddBundleTileBinding(TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);
    assert omitted_tload_start == CommandExecution_Executed;
    assert BundleOperationBindingsComplete(tload_operation);
    let omitted_tload_operands = BundleTileInstructionOperands(tload_operation);
    assert omitted_tload_operands.address == Zeros{PTO_XLEN};
    assert omitted_tload_operands.scalar0 == Zeros{PTO_XLEN} + 7;

    // An encoded zero selector is a real zero stride, not the omission
    // default. A nonzero RegSrc1 reads the selected absolute GPR.
    ResetProfileState();
    let zero_stride_start = ExecuteCommandInstruction(
        BundleTestTLSUStart(Zeros{5}, Zeros{5} + 24), 32);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 7);
    AddBundleTileBinding(TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);
    let zero_stride_binding = ExecuteCommandInstruction(
        BundleTestScalarBinding(
            Zeros{5}, Zeros{5}, Zeros{5}, Zeros{5}), 32);
    assert zero_stride_start == CommandExecution_Executed;
    assert zero_stride_binding == CommandExecution_Executed;
    assert BundleOperationBindingsComplete(tload_operation);
    let zero_stride_operands = BundleTileInstructionOperands(tload_operation);
    assert zero_stride_operands.scalar0 == Zeros{PTO_XLEN};

    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN} + 11);
    WriteGPR(3, Zeros{PTO_XLEN} + 13);
    let explicit_stride_start = ExecuteCommandInstruction(
        BundleTestTLSUStart(Zeros{5}, Zeros{5} + 24), 32);
    AddBundleTileBinding(TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);
    let explicit_stride_binding = ExecuteCommandInstruction(
        BundleTestScalarBinding(
            Zeros{5}, Zeros{5} + 2, Zeros{5} + 3, Zeros{5}), 32);
    assert explicit_stride_start == CommandExecution_Executed;
    assert explicit_stride_binding == CommandExecution_Executed;
    assert BundleOperationBindingsComplete(tload_operation);
    let explicit_stride_operands =
        BundleTileInstructionOperands(tload_operation);
    assert explicit_stride_operands.address == Zeros{PTO_XLEN} + 11;
    assert explicit_stride_operands.scalar0 == Zeros{PTO_XLEN} + 13;
end;

func TestBundleOrderedGPRControls()
begin
    let tci_operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x066)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let ttri_operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x067)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let tsort_operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x06c)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let tmrg_operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x06d)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};

    // TCI packs scalar0 then flag0, and preserves the omitted defaults.
    ResetProfileState();
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    WriteGPR(3, Zeros{PTO_XLEN} + 1);
    SetBundleScalarBinding(0, 0, 2, 3, 0, 3);
    let tci = BundleTileInstructionOperands(tci_operation);
    assert tci.scalar0 == Zeros{PTO_XLEN} + 5;
    assert tci.flag0;
    assert BundleOperationGPRBindingValuesLegal(tci_operation);

    ResetProfileState();
    let tci_default = BundleTileInstructionOperands(tci_operation);
    assert tci_default.scalar0 == Zeros{PTO_XLEN};
    assert !tci_default.flag0;

    // TTRI packs diagonal before upper and accepts both signed boundaries.
    ResetProfileState();
    WriteGPR(4, Ones{PTO_XLEN} - 65534);
    WriteGPR(5, Zeros{PTO_XLEN} + 1);
    SetBundleScalarBinding(0, 0, 4, 5, 0, 3);
    assert BundleOperationGPRBindingValuesLegal(ttri_operation);
    let ttri = BundleTileInstructionOperands(ttri_operation);
    assert ttri.diagonal == -65535;
    assert ttri.flag0;
    ResetProfileState();
    WriteGPR(4, Zeros{PTO_XLEN} + 65535);
    SetBundleScalarBinding(0, 0, 4, 0, 0, 3);
    assert BundleOperationGPRBindingValuesLegal(ttri_operation);
    let ttri_positive = BundleTileInstructionOperands(ttri_operation);
    assert ttri_positive.diagonal == 65535;

    // TSORT and TMRGSORT each consume only flag0 in RegSrc0.
    ResetProfileState();
    WriteGPR(6, Zeros{PTO_XLEN} + 1);
    SetBundleScalarBinding(0, 0, 6, 0, 0, 3);
    let tsort = BundleTileInstructionOperands(tsort_operation);
    let tmrg = BundleTileInstructionOperands(tmrg_operation);
    assert tsort.flag0;
    assert tmrg.flag0;

    // Raw boolean 2 and an out-of-range diagonal reject before constrained
    // operand assignment; the caller maps this to Fault_TileLegality.
    ResetProfileState();
    WriteGPR(6, Zeros{PTO_XLEN} + 2);
    SetBundleScalarBinding(0, 0, 6, 0, 0, 3);
    assert !BundleOperationGPRBindingValuesLegal(tsort_operation);
    ResetProfileState();
    WriteGPR(4, Zeros{PTO_XLEN} + 65536);
    SetBundleScalarBinding(0, 0, 4, 0, 0, 3);
    assert !BundleOperationGPRBindingValuesLegal(ttri_operation);

    // Every operation rejects a nonzero surplus source and RegDst.
    ResetProfileState();
    SetBundleScalarBinding(0, 1, 0, 0, 0, 3);
    assert !BundleOperationBindingsComplete(tsort_operation);
    ResetProfileState();
    SetBundleScalarBinding(0, 0, 6, 0, 1, 3);
    assert !BundleOperationBindingsComplete(tsort_operation);
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleScalarBindingSchemaDefaults();
    TestBundleOrderedGPRControls();
    return 0;
end;
