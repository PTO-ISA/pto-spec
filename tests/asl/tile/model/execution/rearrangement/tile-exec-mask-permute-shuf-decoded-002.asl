// PTO-TEST: {"id":"PTO-AVS-TILE-EXECUTION-MASK-PERMUTE-SHUF-DECODED-002","source":"asl/tile/model/execution/rearrangement.asl","requirements":["PTO-TPERMUTE-CONTRACT-001","PTO-TSHUF-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001"],"kind":"execution","summary":"Decoded TPERMUTE and TSHUF apply ExecutionMask before mapped reads and destination effects","pass_condition":"All-inactive and partially active ZERO operations skip undefined or invalid inactive index, control, and source payload; activating the same undefined or invalid coordinate rejects; MERGE preserves inactive destination elements for both operations","related_sources":["asl/tile/model/legality/layout-rearrangement.asl","asl/block/model/dispatch/cell-rearrangement-schema.asl","asl/block/model/dispatch/execution-mask-schema.asl"]}
pure func MaskedRearrangementStart(selector: bits(10)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func MaskedRearrangementAttributes(zero_inactive: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 29;
    instruction[13] = if zero_inactive then '1' else '0';
    return instruction;
end;

pure func MaskedRearrangementIOT(
    source0: bits(6), source1: bits(6), source1_valid: boolean,
    destination_valid: boolean, last: boolean) => bits(64)
begin
    var instruction = if source1_valid then
        Zeros{64} + 0x00004013 else Zeros{64} + 0x00005013;
    instruction[31:26] = source1;
    instruction[25:20] = source0;
    instruction[19] = if last then '1' else '0';
    instruction[18:15] = if destination_valid then '0010' else '0000';
    instruction[11:9] = '001';
    instruction[8:7] = Zeros{2};
    return instruction;
end;

pure func MaskedRearrangementIOR(source0: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = source0;
    return instruction;
end;

func BeginMaskedRearrangement(selector: bits(10), zero_inactive: boolean)
begin
    let started = ExecuteCommandInstruction(
        MaskedRearrangementStart(selector), 32);
    let attributes = ExecuteCommandInstruction(
        MaskedRearrangementAttributes(zero_inactive), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
end;

func BindMaskedTPERMUTE()
begin
    let sources = ExecuteCommandInstruction(
        MaskedRearrangementIOT(
            Zeros{6}, Zeros{6} + 1, TRUE, FALSE, FALSE), 32);
    let indices_mask = ExecuteCommandInstruction(
        MaskedRearrangementIOT(
            Zeros{6} + 2, Zeros{6} + 3, TRUE, TRUE, TRUE), 32);
    assert sources == CommandExecution_Executed;
    assert indices_mask == CommandExecution_Executed;
end;

func ConfigureMaskedTPERMUTE(active0: boolean, active1: boolean,
    define_active_payload: boolean, define_inactive_invalid_index: boolean)
begin
    let left_ready = ConfigureCubeTile(
        10, 4096, 1, 2, TileDataType_U32, TileLayout_CUBE_M32);
    let right_ready = ConfigureCubeTile(
        11, 4096, 1, 2, TileDataType_U32, TileLayout_CUBE_M32);
    let indices_ready = ConfigureCubeTile(
        12, 4096, 1, 8, TileDataType_U8, TileLayout_CUBE_M32);
    let mask_ready = ConfigurePredicateCell(
        13, 4096, 1, 2, TileDataType_U32, TileLayout_CUBE_M32);
    assert left_ready && right_ready && indices_ready && mask_ready;
    InstallRelativeTileFixture(0, 10);
    InstallRelativeTileFixture(1, 11);
    InstallRelativeTileFixture(2, 12);
    InstallRelativeTileFixture(3, 13);
    if define_active_payload then
        WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x04030201);
        WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 0x08070605);
        WriteTileElement(12, 0, 0, Zeros{PTO_XLEN});
        WriteTileElement(12, 0, 1, Zeros{PTO_XLEN} + 4);
        WriteTileElement(12, 0, 2, Zeros{PTO_XLEN} + 1);
        WriteTileElement(12, 0, 3, Zeros{PTO_XLEN} + 5);
    end;
    if define_inactive_invalid_index then
        WriteTileElement(12, 0, 4, Zeros{PTO_XLEN} + 8);
    end;
    WriteTileElement(13, 0, 0,
        if active0 then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
    WriteTileElement(13, 0, 1,
        if active1 then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
    _Tiles[[13]].contents_defined = TRUE;
end;

func RunMaskedTPERMUTEZero(active0: boolean, active1: boolean,
    define_active_payload: boolean, should_complete: boolean)
begin
    ResetProfileState();
    ConfigureMaskedTPERMUTE(
        active0, active1, define_active_payload, TRUE);
    BeginMaskedRearrangement(Zeros{10} + 0x075, TRUE);
    BindMaskedTPERMUTE();
    let completed = ExecuteBundleTileOperation();
    assert completed == should_complete;
    if should_complete then
        assert _LastFault == Fault_None;
        let destination = _BundleTileBindings[[1]].destination;
        assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN};
    else
        assert _LastFault == Fault_TileLegality;
    end;
end;

func RunMaskedTPERMUTEMerge()
begin
    ResetProfileState();
    ConfigureMaskedTPERMUTE(TRUE, FALSE, TRUE, FALSE);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 0x88776655);
    MarkTileValidRegionDefined(10);
    BeginMaskedRearrangement(Zeros{10} + 0x075, FALSE);
    BindMaskedTPERMUTE();
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[1]].destination;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x06020501;
    assert ReadTileElement(destination, 0, 1) ==
        Zeros{PTO_XLEN} + 0x88776655;
end;

func BindMaskedTSHUF()
begin
    let sources = ExecuteCommandInstruction(
        MaskedRearrangementIOT(
            Zeros{6}, Zeros{6} + 1, TRUE, FALSE, FALSE), 32);
    let mask = ExecuteCommandInstruction(
        MaskedRearrangementIOT(
            Zeros{6} + 2, Zeros{6}, FALSE, TRUE, TRUE), 32);
    let control = ExecuteCommandInstruction(
        MaskedRearrangementIOR(Zeros{5} + 2), 32);
    assert sources == CommandExecution_Executed;
    assert mask == CommandExecution_Executed;
    assert control == CommandExecution_Executed;
end;

func ConfigureMaskedTSHUF(active0: boolean, active1: boolean,
    define_row0: boolean, define_row1: boolean)
begin
    let source_ready = ConfigureCubeTile(
        10, 128, 2, 1, TileDataType_U32, TileLayout_CUBE_M32);
    let controls_ready = ConfigureCubeTile(
        11, 128, 2, 1, TileDataType_U32, TileLayout_CUBE_M32);
    let mask_ready = ConfigurePredicateCell(
        12, 128, 2, 1, TileDataType_U32, TileLayout_CUBE_M32);
    assert source_ready && controls_ready && mask_ready;
    InstallRelativeTileFixture(0, 10);
    InstallRelativeTileFixture(1, 11);
    InstallRelativeTileFixture(2, 12);
    if define_row0 then
        WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 11);
        WriteTileElement(11, 0, 0, Zeros{PTO_XLEN});
    end;
    if define_row1 then
        WriteTileElement(10, 1, 0, Zeros{PTO_XLEN} + 22);
        WriteTileElement(11, 1, 0, Zeros{PTO_XLEN} + 1);
    end;
    WriteTileElement(12, 0, 0,
        if active0 then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
    WriteTileElement(12, 1, 0,
        if active1 then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
    _Tiles[[12]].contents_defined = TRUE;
    WriteGPR(2, Zeros{PTO_XLEN} + 0x00000303);
end;

func RunMaskedTSHUFZero(active0: boolean, active1: boolean,
    define_row0: boolean, define_row1: boolean, should_complete: boolean)
begin
    ResetProfileState();
    ConfigureMaskedTSHUF(active0, active1, define_row0, define_row1);
    BeginMaskedRearrangement(Zeros{10} + 0x076, TRUE);
    BindMaskedTSHUF();
    let completed = ExecuteBundleTileOperation();
    assert completed == should_complete;
    if should_complete then
        assert _LastFault == Fault_None;
        let destination = _BundleTileBindings[[1]].destination;
        assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN};
    else
        assert _LastFault == Fault_TileLegality;
    end;
end;

func RunMaskedTSHUFMerge()
begin
    ResetProfileState();
    ConfigureMaskedTSHUF(FALSE, TRUE, TRUE, TRUE);
    MarkTileValidRegionDefined(10);
    BeginMaskedRearrangement(Zeros{10} + 0x076, FALSE);
    BindMaskedTSHUF();
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[1]].destination;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 11;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 22;
end;

func main() => integer
begin
    RunMaskedTPERMUTEZero(FALSE, FALSE, FALSE, TRUE);
    RunMaskedTPERMUTEZero(TRUE, FALSE, TRUE, TRUE);
    RunMaskedTPERMUTEZero(TRUE, TRUE, TRUE, FALSE);
    RunMaskedTPERMUTEMerge();
    RunMaskedTSHUFZero(FALSE, FALSE, FALSE, FALSE, TRUE);
    RunMaskedTSHUFZero(FALSE, TRUE, FALSE, TRUE, TRUE);
    RunMaskedTSHUFZero(TRUE, TRUE, FALSE, TRUE, FALSE);
    RunMaskedTSHUFMerge();
    return 0;
end;
