// PTO-TEST: {"id":"PTO-AVS-BLOCK-MGATHER-GATHER-001","source":"asl/block/execution/BSTART.MGATHER.asl","requirements":["PTO-BSTART-MGATHER-SCHEMA-001","PTO-MGATHER-BYTE-DISPLACEMENT-001","PTO-INST-TILE-MGATHER","PTO-INST-BLOCK-BSTART-MGATHER"],"kind":"execution","summary":"MGATHER uses U32 byte displacements, applies dimension defaults, and pads the full physical destination.","pass_condition":"Two U32 indices load base+0 and base+3 into a U8 destination whose omitted LB1/LB2 defaults are 1 and LB0; every non-valid physical element receives Max padding.","related_sources":["asl/block/model/dispatch/tlsu-mgather.asl","asl/tile/model/memory/gather-scatter.asl"]}
pure func GatherStart(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00411181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func GatherBinding(pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = pe_mode;
    instruction[8:7] = '00';
    return instruction;
end;

pure func GatherIOR(register: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = register;
    return instruction;
end;

pure func GatherMaxPad() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[28:27] = '01';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 3);
    Store(Zeros{PTO_XLEN} + 0x100, 1, Zeros{PTO_XLEN} + 0x11);
    Store(Zeros{PTO_XLEN} + 0x103, 1, Zeros{PTO_XLEN} + 0x44);
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x100);
    let started = ExecuteCommandInstruction(
        GatherStart(Zeros{5} + 27), 32);
    assert started == CommandExecution_Executed;
    let attributed = ExecuteCommandInstruction(GatherMaxPad(), 32);
    assert attributed == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    let tiles = ExecuteCommandInstruction(GatherBinding('001'), 32);
    assert tiles == CommandExecution_Executed;
    let scalar = ExecuteCommandInstruction(GatherIOR(Zeros{5} + 2), 32);
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 2;
    assert _Tiles[[destination]].columns == 2;
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x100;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x103;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 0x11;
    assert ReadTileElement(destination, 0, 1) == Zeros{PTO_XLEN} + 0x44;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 0xff;
    assert ReadTileElement(destination,
        (_Tiles[[destination]].rows - 1) as integer {0..65535}, 1) ==
            Zeros{PTO_XLEN} + 0xff;
    StopMemoryEventCapture();
    return 0;
end;
