// PTO-TEST: {"id":"PTO-AVS-BLOCK-MASK-AWARE-EXPANSION-DECODED-003","source":"asl/block/model/dispatch/expansion-schema.asl","requirements":["PTO-TROWEXPAND-CONTRACT-001","PTO-TCOLEXPAND-CONTRACT-001","PTO-TROWEXPANDDIV-CONTRACT-001","PTO-TCOLEXPANDDIV-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-DATR-FIELDS-001","PTO-B-IOR-BINDING-001"],"kind":"execution","summary":"Decoded row and column expansion preflight maps broadcast reads through ExecutionMask-active output coordinates","pass_condition":"row and column COPY accept broadcast sources smaller than their output shape, wholly inactive integer DIV accepts undefined and zero operands, and activating a zero or undefined mapped denominator rejects before destination allocation","related_sources":["asl/block/model/dispatch/execution-mask-schema.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/expansion.asl"]}
pure func MaskedExpansionStart(selector: bits(10)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    return instruction;
end;

pure func MaskedExpansionAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 31;
    instruction[13] = '1';
    return instruction;
end;

pure func MaskedExpansionIOR(mask: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = mask;
    instruction[26] = '1';
    return instruction;
end;

pure func MaskedExpansionIOT(source0: bits(6), source1: bits(6),
    source1_valid: boolean) => bits(64)
begin
    var instruction = if source1_valid then
        Zeros{64} + 0x00004013 else Zeros{64} + 0x00005013;
    instruction[25:20] = source0;
    instruction[31:26] = source1;
    instruction[19] = '1';
    instruction[18:15] = '0010';
    instruction[11:9] = '001';
    return instruction;
end;

func BeginMaskedExpansion(selector: bits(10),
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535})
begin
    let started = ExecuteCommandInstruction(
        MaskedExpansionStart(selector), 32);
    let attributes = ExecuteCommandInstruction(
        MaskedExpansionAttributes(), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + valid_columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + valid_rows);
    SetBundleDimension(2, Zeros{PTO_XLEN} + valid_columns);
end;

func RunMaskedExpansionCopy(row_axis: boolean)
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        10, 256,
        if row_axis then 2 else 1,
        if row_axis then 1 else 3,
        TileDataType_U32, TileLayout_CUBE_M16);
    let mask_ready = ConfigurePredicateCell(
        12, 256, 2, 3, TileDataType_U32, TileLayout_CUBE_M16);
    assert source_ready && mask_ready;
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(12, 12);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(12, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(12, 0, 2, Zeros{PTO_XLEN});
    WriteTileElement(12, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(12, 1, 1, Zeros{PTO_XLEN});
    WriteTileElement(12, 1, 2, Zeros{PTO_XLEN});
    MarkTileValidRegionDefined(12);
    BeginMaskedExpansion(
        if row_axis then Zeros{10} + 0x044 else Zeros{10} + 0x054,
        2, 3);
    let binding = ExecuteCommandInstruction(
        MaskedExpansionIOT(Zeros{6} + 10, Zeros{6} + 12, TRUE), 32);
    assert binding == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].valid_rows == 2;
    assert _Tiles[[destination]].valid_columns == 3;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert ReadTileElement(destination, 1, 2) == Zeros{PTO_XLEN};
end;

// active_case zero selects a wholly inactive output, one selects a defined
// zero denominator, and two selects an undefined mapped denominator.
func RunMaskedExpansionDIV(row_axis: boolean,
    active_case: integer {0..2})
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(
        10, 256, 2, 2, TileDataType_U32, TileLayout_CUBE_M16);
    let broadcast_ready = ConfigureCubeTile(
        11, 256,
        if row_axis then 2 else 1,
        if row_axis then 1 else 2,
        TileDataType_U32, TileLayout_CUBE_M16);
    assert source_ready && broadcast_ready;
    InstallRelativeTileFixture(10, 10);
    InstallRelativeTileFixture(11, 11);
    var mask = Zeros{PTO_XLEN};
    if active_case == 1 then
        mask[0] = '1';
        WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 8);
        WriteTileElement(11, 0, 0, Zeros{PTO_XLEN});
    elsif active_case == 2 then
        if row_axis then
            mask[1] = '1';
            WriteTileElement(10, 1, 0, Zeros{PTO_XLEN} + 8);
        else
            mask[16] = '1';
            WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 8);
        end;
    end;
    WritePEGPR(0, 2, mask);
    BeginMaskedExpansion(
        if row_axis then Zeros{10} + 0x048 else Zeros{10} + 0x058,
        2, 2);
    let execution_mask = ExecuteCommandInstruction(
        MaskedExpansionIOR(Zeros{5} + 2), 32);
    let binding = ExecuteCommandInstruction(
        MaskedExpansionIOT(
            Zeros{6} + 10, Zeros{6} + 11, TRUE), 32);
    assert execution_mask == CommandExecution_Executed &&
           binding == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed == (active_case == 0);
    if active_case == 0 then
        assert _LastFault == Fault_None;
        let destination = _BundleTileBindings[[0]].destination;
        assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN};
        assert ReadTileElement(destination, 1, 1) == Zeros{PTO_XLEN};
    else
        assert _LastFault == Fault_TileLegality;
        assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    end;
end;

func main() => integer
begin
    RunMaskedExpansionCopy(TRUE);
    RunMaskedExpansionCopy(FALSE);
    RunMaskedExpansionDIV(TRUE, 0);
    RunMaskedExpansionDIV(TRUE, 1);
    RunMaskedExpansionDIV(TRUE, 2);
    RunMaskedExpansionDIV(FALSE, 0);
    RunMaskedExpansionDIV(FALSE, 1);
    RunMaskedExpansionDIV(FALSE, 2);
    return 0;
end;
