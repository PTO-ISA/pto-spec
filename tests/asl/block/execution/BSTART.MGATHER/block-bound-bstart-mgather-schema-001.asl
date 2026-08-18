// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-SCHEMA-001","source":"asl/block/execution/BSTART.MGATHER.asl","requirements":["PTO-BSTART-MGATHER-SCHEMA-001","PTO-MGATHER-BYTE-DISPLACEMENT-001"],"kind":"boundary","summary":"MGATHER rejects missing required controls and packed transfer types before effects.","pass_condition":"Missing B.IOR, floating IndexTile, and U4X2 transfer each fault without destination allocation or memory events.","related_sources":["asl/block/model/dispatch/tlsu-mgather.asl"]}
pure func SchemaGatherStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00411181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func SchemaGatherBinding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func SchemaGatherIOR() => bits(64)
begin
    return Zeros{64} + 0x00000013;
end;

func ConfigureSchemaIndex(data_type: TileDataType)
begin
    ConfigureTile(0, 128, 1, 1, 1, 1, data_type,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
end;

func BindSchemaGather(include_ior: boolean)
begin
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    let tiles = ExecuteCommandInstruction(SchemaGatherBinding(), 32);
    assert tiles == CommandExecution_Executed;
    if include_ior then
        let scalar = ExecuteCommandInstruction(SchemaGatherIOR(), 32);
        assert scalar == CommandExecution_Executed;
    end;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureSchemaIndex(TileDataType_U32);
    let missing_ior_start = ExecuteCommandInstruction(
        SchemaGatherStart(Zeros{5} + 27), 32);
    assert missing_ior_start == CommandExecution_Executed;
    BindSchemaGather(FALSE);
    StartMemoryEventCapture(0);
    let missing_ior = ExecuteBundleTileOperation();
    assert !missing_ior;
    assert _LastFault == Fault_TileLegality;
    assert CoreTileCapacityInUse() == 128;
    assert _MemoryEventCount == 0;

    ResetProfileState();
    ConfigureSchemaIndex(TileDataType_FP32);
    let floating_start = ExecuteCommandInstruction(
        SchemaGatherStart(Zeros{5} + 27), 32);
    assert floating_start == CommandExecution_Executed;
    BindSchemaGather(TRUE);
    StartMemoryEventCapture(0);
    let floating = ExecuteBundleTileOperation();
    assert !floating;
    assert _LastFault == Fault_TileLegality;
    assert CoreTileCapacityInUse() == 128;
    assert _MemoryEventCount == 0;

    ResetProfileState();
    ConfigureSchemaIndex(TileDataType_U32);
    let packed_start = ExecuteCommandInstruction(
        SchemaGatherStart(Zeros{5} + 28), 32);
    assert packed_start == CommandExecution_Executed;
    BindSchemaGather(TRUE);
    StartMemoryEventCapture(0);
    let packed = ExecuteBundleTileOperation();
    assert !packed;
    assert _LastFault == Fault_TileLegality;
    assert CoreTileCapacityInUse() == 128;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    return 0;
end;
