// PTO-TEST: {"id":"PTO-AVS-BLOCK-EXECUTION-MASK-GPR-STREAM-001","source":"asl/block/model/dispatch/scalar-schema.asl","requirements":["PTO-B-IOR-BINDING-001","PTO-TCMP-CONTRACT-001"],"kind":"boundary","summary":"ExecutionMask GPR words append densely and the final B.IOR flag distinguishes GPR0.","pass_condition":"One/two-word one-record and six-source two-record bindings accept while absent, early, and surplus presence flags reject.","related_sources":["asl/block/model/operands/scalar-bindings.asl","asl/block/operands/B.IOR.asl"]}
pure func ExecutionMaskStreamTEPLStart(selector: bits(10), data_type: bits(5))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = data_type;
    return instruction;
end;

pure func ExecutionMaskStreamIOR(destination: bits(5), source0: bits(5),
    source1: bits(5), source2: bits(5), present: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[11:7] = destination;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    instruction[31:27] = source2;
    instruction[26] = if present then '1' else '0';
    return instruction;
end;

func SelectExecutionMaskTestContext(data_type: bits(5))
begin
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_TileElement;
    _BundleOperation.data_type_valid = TRUE;
    _BundleOperation.data_type = data_type;
    _BundleDataAttributes.data_layout = Zeros{5} + 29;
end;

func main() => integer
begin
    ResetProfileState();
    SelectExecutionMaskTestContext(Zeros{5} + 27); // U8, two words
    SetBundleScalarBindingWithExecutionMask(0, 0, 0, 0, 0, 3, TRUE);
    assert BundleExecutionMaskGPRBindingSchemaLegal(
        DecodeTileOperation(TileDecode_TEPL, Zeros{12})
            as integer {0..PTO_TILE_OPERATION_COUNT-1});

    // A wider operation type uses one word while retaining the same GPR0
    // disambiguation through the final-record presence flag.
    ResetProfileState();
    SelectExecutionMaskTestContext(Zeros{5} + 1); // FP32, one word
    SetBundleScalarBindingWithExecutionMask(0, 0, 0, 0, 0, 3, TRUE);
    assert BundleExecutionMaskGPRBindingSchemaLegal(
        DecodeTileOperation(TileDecode_TEPL, Zeros{12})
            as integer {0..PTO_TILE_OPERATION_COUNT-1});

    // GPR0 is a real mask word because ExecMaskPresent is set; the same
    // encoded zero selector without the presence flag is not a carrier.
    ResetProfileState();
    SelectExecutionMaskTestContext(Zeros{5} + 27);
    SetBundleScalarBindingWithExecutionMask(0, 0, 0, 0, 0, 3, FALSE);
    assert !BundleExecutionMaskGPRBindingSchemaLegal(
        DecodeTileOperation(TileDecode_TEPL, Zeros{12})
            as integer {0..PTO_TILE_OPERATION_COUNT-1});

    // TGPR2T owns four ordered GPR sources; the two mask words fill the final
    // record, which alone carries ExecMaskPresent.
    ResetProfileState();
    SelectExecutionMaskTestContext(Zeros{5} + 27);
    SetBundleScalarBindingWithExecutionMask(0, 0, 1, 2, 3, 3, FALSE);
    SetBundleScalarBindingWithExecutionMask(1, 0, 4, 5, 6, 3, TRUE);
    assert BundleExecutionMaskGPRBindingSchemaLegal(
        DecodeTileOperation(TileDecode_TEPL, Zeros{12} + 0x07e)
            as integer {0..PTO_TILE_OPERATION_COUNT-1});

    ResetProfileState();
    SelectExecutionMaskTestContext(Zeros{5} + 27);
    SetBundleScalarBindingWithExecutionMask(0, 0, 1, 2, 3, 3, TRUE);
    SetBundleScalarBindingWithExecutionMask(1, 0, 4, 5, 6, 3, TRUE);
    assert !BundleExecutionMaskGPRBindingSchemaLegal(
        DecodeTileOperation(TileDecode_TEPL, Zeros{12} + 0x07e)
            as integer {0..PTO_TILE_OPERATION_COUNT-1});

    ResetProfileState();
    SelectExecutionMaskTestContext(Zeros{5} + 27);
    SetBundleScalarBindingWithExecutionMask(0, 0, 1, 2, 3, 3, FALSE);
    SetBundleScalarBindingWithExecutionMask(1, 7, 4, 5, 6, 3, TRUE);
    assert !BundleExecutionMaskGPRBindingSchemaLegal(
        DecodeTileOperation(TileDecode_TEPL, Zeros{12} + 0x07e)
            as integer {0..PTO_TILE_OPERATION_COUNT-1});

    // The real command handler latches a one-record GPR0 mask carrier.
    ResetProfileState();
    let tadd_start = ExecuteCommandInstruction(
        ExecutionMaskStreamTEPLStart(Zeros{10}, Zeros{5} + 27), 32);
    assert tadd_start == CommandExecution_Executed;
    let gpr0_mask = ExecuteCommandInstruction(
        ExecutionMaskStreamIOR(Zeros{5}, Zeros{5}, Zeros{5}, Zeros{5}, TRUE), 32);
    assert gpr0_mask == CommandExecution_Executed;
    assert _BundleScalarBindings[[0]].execution_mask_present;
    assert _BundleScalarBindings[[0]].source0 == 0;

    // TGPR2T still accepts its contiguous 3+1 stream; the final record can
    // carry two appended mask words, and only it sets bit 26.
    ResetProfileState();
    let tgpr2t_start = ExecuteCommandInstruction(
        ExecutionMaskStreamTEPLStart(Zeros{10} + 0x07e, Zeros{5} + 27), 32);
    assert tgpr2t_start == CommandExecution_Executed;
    let record0 = ExecuteCommandInstruction(
        ExecutionMaskStreamIOR(Zeros{5}, Zeros{5} + 1, Zeros{5} + 2,
                               Zeros{5} + 3, FALSE), 32);
    assert record0 == CommandExecution_Executed;
    let record1 = ExecuteCommandInstruction(
        ExecutionMaskStreamIOR(Zeros{5}, Zeros{5} + 4, Zeros{5} + 5,
                               Zeros{5} + 6, TRUE), 32);
    assert record1 == CommandExecution_Executed;
    assert !_BundleScalarBindings[[0]].execution_mask_present;
    assert _BundleScalarBindings[[1]].execution_mask_present;

    // A first-record presence flag cannot be followed by a second record.
    ResetProfileState();
    let tgpr2t_again = ExecuteCommandInstruction(
        ExecutionMaskStreamTEPLStart(Zeros{10} + 0x07e, Zeros{5} + 27), 32);
    assert tgpr2t_again == CommandExecution_Executed;
    let nonfinal_flag = ExecuteCommandInstruction(
        ExecutionMaskStreamIOR(Zeros{5}, Zeros{5} + 1, Zeros{5} + 2,
                               Zeros{5} + 3, TRUE), 32);
    assert nonfinal_flag == CommandExecution_Executed;
    let misplaced = ExecuteCommandInstruction(
        ExecutionMaskStreamIOR(Zeros{5}, Zeros{5} + 4, Zeros{5} + 5,
                               Zeros{5} + 6, TRUE), 32);
    assert misplaced == CommandExecution_Rejected;
    assert _BundleScalarBindings[[0]].valid;
    assert !_BundleScalarBindings[[1]].valid;
    return 0;
end;
