// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TMOV-CUBE-TO-ND-COOPERATIVE-TMATMUL-004","source":"asl/block/model/dispatch/shared-tmov-cube-to-nd.asl","requirements":["PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-B-ASSEMBLE-SHARED-GENERATION-001","PTO-BSTART-TMOV-SHARED-001","PTO-TMOV-CUBE-TO-SHARED-ND-001","PTO-TMATMUL-CONTRACT-001","PTO-CUBE-SHARED-TRANSPOSE-001","PTO-CUBE-GROUP-M-DISTRIBUTION-001"],"kind":"execution","summary":"four actual PE TMATMUL consumers use converted Shared as cooperative left, transposed-left, and right operands","pass_condition":"four actual M16 writers publish a 64x64 U16 Shared result from FP16-start conversion; four PE contexts execute TMATMUL with PE_MASK=1111 for converted Shared A, transposed Shared A, and Local A times converted Shared B, and every per-PE output matches independent coordinate goldens","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/block/model/dispatch/shared-cube-matrix.asl","asl/block/model/dispatch/shared-tmov-cube-to-nd.asl","asl/tile/model/memory/shared-cube-to-nd.asl"]}

pure func CooperativeTMOVStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func CooperativeTMOVShared(shared_id: bits(6),
    size_code: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_id;
    instruction[18:15] = size_code;
    instruction[11:9] = '111';
    return instruction;
end;

pure func CooperativeTMOVAssemble(writer_size: bits(4)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[19:15] = Zeros{5} + 1;
    instruction[11] = '1';
    instruction[10:7] = writer_size;
    return instruction;
end;

pure func CooperativeTMOVSourceBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[11:9] = '111';
    instruction[19] = '1';
    return instruction;
end;

pure func CooperativeTMATMULStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

pure func CooperativeTMATMULGolden(row: integer {0..63},
    column: integer {0..63}) => Word
begin
    return Zeros{PTO_XLEN} +
        (1 + ((row * 7 + column * 3 + ((row * column) MOD 11)) MOD 31));
end;

pure func CooperativeTMATMULLeftGolden(row: integer {0..63},
    transpose: boolean) => Word
begin
    var sum: integer {0..100000} = 0;
    for inner = 0 to 63 looplimit 64 do
        let left_value = if transpose then
            1 + ((inner * 7 + row * 3 + ((inner * row) MOD 11)) MOD 31)
            else 1 + ((row * 7 + inner * 3 + ((row * inner) MOD 11)) MOD 31);
        sum = (sum + left_value) as integer {0..100000};
    end;
    return Zeros{PTO_XLEN} + sum;
end;

func PrepareCooperativeTMATMULSharedRight()
begin
    ConfigureTileForMask(10, 128, 64, 1, 64, 1,
        TileDataType_U16, TileLayout_RowMajor, '1111');
    for row = 0 to 63 looplimit 64 do
        WriteTileElement(10, row, 0, Zeros{PTO_XLEN} + 1);
    end;
    InstallSharedTile((Zeros{6} + 41) as SharedTileID,
        _Tiles[[10]], '1111');
    assert SharedTilePublished((Zeros{6} + 41) as SharedTileID);
end;

func PrepareCooperativeTMOVCubeSource(pe: integer {0..3},
    valid_columns: integer {1,64})
begin
    let configured = ConfigureCubeTileForMask(0, 2048, 16, 64,
        TileDataType_U16, TileLayout_CUBE_M16, '1111');
    assert configured;
    InstallRelativeTileFixture(0, 0);
    var source = _Tiles[[0]];
    for row = 0 to 15 looplimit 16 do
        for column = 0 to 63 looplimit 64 do
            let element = TileStorageIndex(source,
                row as integer {0..65535},
                column as integer {0..65535});
            source.payload[[element]] = CooperativeTMATMULGolden(
                pe * 16 + row, column);
            source.defined_elements[element] = '1';
        end;
    end;
    source.valid_columns = valid_columns;
    source.defined_valid_elements = (16 * valid_columns)
        as integer {0..524288};
    source.contents_defined = TRUE;
    _Tiles[[0]] = source;
    assert TileCubeDescriptorLegal(source);
end;

func PublishCooperativeConvertedShared(valid_columns: integer {1,64})
begin
    let launched = LaunchKernelInvocation(0 as PTOModelCoreIdentity,
        Zeros{PTO_XLEN});
    assert launched == KernelLifecycle_Started;
    var parked_tpcs: array [[PTO_MODEL_MEMORY_AGENTS]] of Word;
    StartMemoryEventCapture(0);
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
        if ReadTPC() == Zeros{PTO_XLEN} then
            WriteTPC(Zeros{PTO_XLEN} + 0x100);
        end;
        PrepareCooperativeTMOVCubeSource(pe, valid_columns);
        WriteGPR(1, Zeros{PTO_XLEN} + pe * 16);
        let start_status = ExecuteCommandInstruction(
            CooperativeTMOVStart(Zeros{5} + 4), 32);
        let datr_status = ExecuteCommandInstruction(
            Zeros{64} + 0x01f01ca3, 32);
        let shared_status = ExecuteCommandInstruction(
            CooperativeTMOVShared(Zeros{6} + 40, Zeros{4} + 7), 32);
        let assemble_status = ExecuteCommandInstruction(
            CooperativeTMOVAssemble(Zeros{4} + 5), 32);
        let source_status = ExecuteCommandInstruction(
            CooperativeTMOVSourceBinding(), 32);
        assert start_status == CommandExecution_Executed &&
               datr_status == CommandExecution_Executed &&
               shared_status == CommandExecution_Executed &&
               assemble_status == CommandExecution_Executed &&
               source_status == CommandExecution_Executed;
        parked_tpcs[[agent]] = ReadTPC();
        let stopped = ExecuteCommandInstruction(Zeros{64}, 16);
        assert stopped == CommandExecution_Executed;
        assert _LastFault == Fault_None;
        if pe < PTO_MODEL_MEMORY_AGENTS - 1 then
            assert !SharedTilePublished((Zeros{6} + 40) as SharedTileID) &&
                   BundleSharedGenerationOpen((Zeros{6} + 40) as SharedTileID) &&
                   BundleSharedGenerationRequestWaiting(0) &&
                   ReadTPC() == parked_tpcs[[agent]];
        end;
    end;
    StopMemoryEventCapture();
    assert _MemoryEventCount == 0 &&
           SharedTilePublished((Zeros{6} + 40) as SharedTileID);
    let published = SharedTileRecord((Zeros{6} + 40) as SharedTileID).tile;
    assert published.data_type == TileDataType_U16 &&
           published.layout == TileLayout_RowMajor &&
           published.capacity_bytes == 8192 &&
           published.rows == 64 && published.columns == 64 &&
           published.valid_rows == 64 &&
           published.valid_columns == valid_columns;
    for row = 0 to 63 looplimit 64 do
        for column = 0 to valid_columns - 1 looplimit 64 do
            assert TileReadLogicalElement(published,
                TileLogicalLinearIndex(published, row, column)) ==
                CooperativeTMATMULGolden(row, column);
        end;
    end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 2 do
        let agent = pe as MemoryAgentId;
        SelectExecutionContext(0 as PTOModelCoreIdentity, agent);
        assert ReadTPC() == parked_tpcs[[agent]] && _BundleActive &&
               BundleSharedGenerationRequestWaiting(0);
        let drain_status = ExecuteCommandInstruction(Zeros{64}, 16);
        assert drain_status == CommandExecution_Executed &&
               _LastFault == Fault_None && !_BundleActive &&
               !BundleSharedGenerationRequestWaiting(0);
    end;
    assert _MemoryEventCount == 0;
end;

func PrepareCooperativeLocalIdentity(pe: MemoryAgentId)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    let configured = ConfigureCubeTileForMask(1, 2048, 16, 64,
        TileDataType_U16, TileLayout_CUBE_M16, '1111');
    assert configured;
    for row = 0 to 15 looplimit 16 do
        let group_row = (pe as integer {0..3}) * 16 + row;
        for column = 0 to 63 looplimit 64 do
            WriteTileElement(1, row, column,
                Zeros{PTO_XLEN} +
                    (if column == group_row then 1 else 0));
        end;
    end;
end;

func ExecuteCooperativeTMATMULPE(pe: MemoryAgentId,
    converted_is_left: boolean, transpose_left: boolean)
begin
    SelectExecutionContext(0 as PTOModelCoreIdentity, pe);
    let start_status = ExecuteCommandInstruction(
        CooperativeTMATMULStart(), 32);
    assert start_status == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE,
        transpose_left, TRUE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 64);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 64);
    if converted_is_left then
        BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
        BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
        AddBundleTileBinding(TRUE, 2 as TileIndex, 1, '1111', FALSE, FALSE,
            0, 0, TRUE);
    else
        PrepareCooperativeLocalIdentity(pe);
        BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
        AddBundleTileBinding(TRUE, 2 as TileIndex, 1, '1111', TRUE, FALSE,
            1, 0, TRUE);
    end;
    assert _BundleSharedBindings[[0]].pe_mask == '1111' &&
           BundleMatrixCooperativeValidM(64, pe) == 16;
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].contents_defined;
    assert _Tiles[[destination]].data_type == TileDataType_U32;
    assert _Tiles[[destination]].valid_rows == 16;
    assert _Tiles[[destination]].valid_columns == 1;
    for row = 0 to 15 looplimit 16 do
        let group_row = (pe as integer {0..3}) * 16 + row;
        let expected = if !converted_is_left then
            CooperativeTMATMULGolden(group_row, 0)
            else CooperativeTMATMULLeftGolden(group_row, transpose_left);
        assert ReadTileElement(destination, row, 0) == expected;
    end;
end;

func RunCooperativeTMATMULCohort(converted_is_left: boolean,
    transpose_left: boolean)
begin
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        ExecuteCooperativeTMATMULPE(pe as MemoryAgentId,
            converted_is_left, transpose_left);
    end;
end;

func main() => integer
begin
    ResetProfileState();
    PrepareCooperativeTMATMULSharedRight();
    PublishCooperativeConvertedShared(64);
    RunCooperativeTMATMULCohort(TRUE, FALSE);
    ResetProfileState();
    PrepareCooperativeTMATMULSharedRight();
    PublishCooperativeConvertedShared(64);
    RunCooperativeTMATMULCohort(TRUE, TRUE);
    ResetProfileState();
    PrepareCooperativeTMATMULSharedRight();
    PublishCooperativeConvertedShared(1);
    RunCooperativeTMATMULCohort(FALSE, FALSE);
    return 0;
end;
