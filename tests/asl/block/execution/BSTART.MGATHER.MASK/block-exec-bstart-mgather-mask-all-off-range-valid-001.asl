// PTO-TEST: {"id":"PTO-AVS-BLOCK-I414-MGATHER-MASK-ALL-OFF-RANGE-001","source":"asl/block/execution/BSTART.MGATHER.MASK.asl","requirements":["PTO-INDEXED-TLSU-RANGE-BINDING-001","PTO-B-IOR-BINDING-001","PTO-BSTART-MGATHER-MASK-SCHEMA-001","PTO-MGATHER-MASK-PREDICATE-001","PTO-MGATHER-MASK-PUBLICATION-001","PTO-INST-BLOCK-BSTART-MGATHER-MASK","PTO-INST-TILE-MGATHER-MASK"],"kind":"execution","summary":"A present valid descriptor preserves MGATHER.MASK all-off Max-fill behavior.","pass_condition":"With all predicate lanes disabled and Min=Max=0, the operation completes without GM events and fills valid inactive and physical padding elements with Max.","related_sources":["asl/block/model/dispatch/indexed-tlsu-range-schema.asl","asl/block/model/dispatch/tlsu-mgather-mask.asl","asl/tile/model/memory/addressing.asl","asl/tile/model/memory/gather-scatter.asl"]}
pure func MaskGatherStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00611181;
    instruction[31:27] = Zeros{5} + 26;
    return instruction;
end;

pure func MaskGatherBinding() => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 1;
    instruction[19] = '1';
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

pure func MaskGatherIOR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func MaskGatherMaxPad() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[28:27] = '01';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 4, 1, 3, TileDataType_S32,
        TileLayout_RowMajor);
    ConfigureTile(1, 128, 1, 4, 1, 3, TileDataType_U8,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x7fff);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x7fff);
    WriteTileElement(0, 0, 2, Zeros{PTO_XLEN} + 0x7fff);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN});
    WritePEGPR(0, 2, Zeros{PTO_XLEN} + 0x100);
    WritePEGPR(0, 3, Zeros{64});
    WritePEGPR(0, 4, Zeros{64});
    let started = ExecuteCommandInstruction(MaskGatherStart(), 32);
    let padded = ExecuteCommandInstruction(MaskGatherMaxPad(), 32);
    assert started == CommandExecution_Executed;
    assert padded == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    let binding = ExecuteCommandInstruction(MaskGatherBinding(), 32);
    let scalar = ExecuteCommandInstruction(MaskGatherIOR(), 32);
    assert binding == CommandExecution_Executed;
    assert scalar == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert _MemoryEventCount == 0;
    let destination = _BundleTileBindings[[0]].destination;
    for column = 0 to 3 looplimit 4 do
        assert ReadTileElement(destination, 0, column) ==
            Zeros{PTO_XLEN} + 0xffff;
    end;
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN} + 0xffff;
    StopMemoryEventCapture();
    return 0;
end;
