// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-STAGE2-WIDTH-001","source":"asl/block/execution/BSTART.MGATHER.asl","requirements":["PTO-BSTART-MGATHER-SCHEMA-001","PTO-MGATHER-BYTE-DISPLACEMENT-001","PTO-INST-TILE-MGATHER","PTO-INST-BLOCK-BSTART-MGATHER"],"kind":"execution","summary":"decoded MGATHER accepts B64/U64 full-width pairing, rejects S16 indices, and moves invalid raw TF32 memory bits","pass_condition":"B64 data with U64 byte displacement gathers with an 8-byte event, an upper-half U64 displacement faults at its full-width address rather than truncating, U16 indices fault before allocation, and an invalid TF32 memory encoding is published unchanged","related_sources":["asl/block/model/dispatch/tlsu-mgather.asl","asl/tile/model/memory/gather-scatter.asl","asl/tile/model/memory/addressing.asl"]}

pure func MgatherStage2Start(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00411181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func MgatherStage2Binding() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func MgatherStage2IOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    return instruction;
end;

func PrepareMgatherStage2(index_type: TileDataType,
                          index_value: Word,
                          data_type: bits(5))
begin
    ResetProfileState();
    ConfigureTile(
        0,
        128,
        1,
        1,
        1,
        1,
        index_type,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, index_value);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x100);
    let started = ExecuteCommandInstruction(
        MgatherStage2Start(data_type),
        32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    let bound = ExecuteCommandInstruction(MgatherStage2Binding(), 32);
    assert bound == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(MgatherStage2IOR(), 32);
    assert scalar == CommandExecution_Executed;
end;

func main() => integer
begin
    let wide_address = Zeros{PTO_XLEN} + 0x100;
    let expected_u64 = Zeros{PTO_XLEN} + 0x1122334455667788;
    PrepareMgatherStage2(
        TileDataType_U64,
        Zeros{PTO_XLEN},
        Zeros{5} + 24);
    Store(wide_address, 8, expected_u64);
    StartMemoryEventCapture(0);
    let wide_completed = ExecuteBundleTileOperation();
    assert wide_completed;
    let wide_destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[wide_destination]].data_type == TileDataType_U64;
    assert ReadTileElement(wide_destination, 0, 0) == expected_u64;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == wide_address;
    assert _MemoryEvents[[0]].size_bytes == 8;
    StopMemoryEventCapture();

    // A nonzero upper half must remain part of the byte displacement.  The
    // bounded reference memory therefore faults at the full-width address;
    // truncation to 32 bits would incorrectly reach 0x103 and complete.
    let full_width_index = Zeros{PTO_XLEN} + 0x0000000100000000;
    let full_width_address = Zeros{PTO_XLEN} + 0x0000000100000100;
    PrepareMgatherStage2(
        TileDataType_U64,
        full_width_index,
        Zeros{5} + 24);
    StartMemoryEventCapture(0);
    let full_width_rejected = ExecuteBundleTileOperation();
    assert !full_width_rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == full_width_address;
    assert _MemoryEventCount == 0;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    StopMemoryEventCapture();

    PrepareMgatherStage2(
        TileDataType_U16,
        Zeros{PTO_XLEN},
        Zeros{5} + 27);
    StartMemoryEventCapture(0);
    let rejected = ExecuteBundleTileOperation();
    assert !rejected;
    assert _LastFault == Fault_TileLegality;
    assert _MemoryEventCount == 0;
    assert CoreTileCapacityInUse() == 128;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    StopMemoryEventCapture();

    PrepareMgatherStage2(
        TileDataType_U32,
        Zeros{PTO_XLEN},
        Zeros{5} + 2);
    let invalid_tf32 = Zeros{PTO_XLEN} + 0x3f800001;
    Store(Zeros{PTO_XLEN} + 0x100, 4, invalid_tf32);
    let raw_completed = ExecuteBundleTileOperation();
    assert raw_completed;
    let raw_destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[raw_destination]].data_type == TileDataType_TF32;
    assert ReadTileElement(raw_destination, 0, 0) == invalid_tf32;

    ResetProfileState();
    ConfigureTile(
        0,
        128,
        2,
        2,
        2,
        1,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1,
        128,
        2,
        1,
        2,
        1,
        TileDataType_U16,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x31);
    WriteTileElement(0, 1, 0, Zeros{PTO_XLEN} + 0x42);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN});
    var tgather_start: bits(64) = Zeros{64} + 0x00019181;
    tgather_start[26:25] = '11';
    tgather_start[24:20] = '01111';
    tgather_start[31:27] = Zeros{5} + 27;
    let tgather_started = ExecuteCommandInstruction(tgather_start, 32);
    assert tgather_started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, TRUE, 0, 1, TRUE);
    let tgather_completed = ExecuteBundleTileOperation();
    assert tgather_completed;
    let tgather_destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(tgather_destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x42;
    assert ReadTileElement(tgather_destination, 1, 0) ==
        Zeros{PTO_XLEN} + 0x31;
    return 0;
end;
