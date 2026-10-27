// PTO-TEST: {"id":"PTO-AVS-BLOCK-PREDICATECELL-LOGICAL-MERGE-NONCANONICAL-001","source":"asl/block/model/operands/local-generation-cube.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-TAND-CONTRACT-001"],"kind":"execution","summary":"Decoded assembly rejects invalid PredicateCell hand MERGE base without writing the parent","pass_condition":"an invalid newest hand base rejects before payload effects","related_sources":["asl/block/model/dispatch/destination-operation.asl","asl/tile/model/legality/destination-value.asl"]}
pure func LogicalAssemblyStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[24:20] = Zeros{5} + 6;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;
pure func LogicalAssemblyInputs(init: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[25:20] = if init then Zeros{6} + 1 else Zeros{6} + 3;
    instruction[31:26] = if init then Zeros{6} + 2 else Zeros{6} + 4;
    instruction[19] = if init then '1' else '0';
    instruction[18:15] = if init then Zeros{4} + 2 else Zeros{4};
    instruction[11:9] = '111'; instruction[8:7] = if init then '01' else '00';
    return instruction;
end;
pure func LogicalAssemblyModifier(init: boolean, last: boolean,
    offset: integer {0,1}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = '0001';
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;
func LogicalAssemblyWriter(init: boolean, last: boolean,
    offset: integer {0,1}, columns: integer {1..8})
begin
    let started = ExecuteCommandInstruction(LogicalAssemblyStart(), 32);
    let attributes = ExecuteCommandInstruction(Zeros{64} + 0x01f01fa3, 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + columns);
    var mask = CommandExecution_Executed;
    if !init then
        var ior = Zeros{64} + 0x00000013;
        ior[19:15] = Zeros{5} + 2;
        ior[26] = '1';
        mask = ExecuteCommandInstruction(ior, 32);
    end;
    let bound = ExecuteCommandInstruction(LogicalAssemblyInputs(init), 32);
    var parent = CommandExecution_Executed;
    if !init then
        parent = ExecuteCommandInstruction(Zeros{64} + 0x01185e13, 32);
    end;
    let assembled = ExecuteCommandInstruction(LogicalAssemblyModifier(init,last,offset), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    assert mask == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    assert parent == CommandExecution_Executed;
    assert assembled == CommandExecution_Executed;
    let completed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x100 + offset * 16);
    if !init then
        assert !completed && _LastFault == Fault_TileLegality;
        return;
    end;
    assert completed;
    let slot = BundleLocalGenerationSlot(1, '1111');
    let ready = CompleteBundleLocalGenerationWriterEvent(slot, _BundleExecutionDomainToken, offset, 1);
    assert ready;
end;
func main() => integer
begin
    ResetProfileState();
    let configured1 = ConfigurePredicateCellForMask(1,128,2,8,TileDataType_U32,TileLayout_CUBE_M16,'1111');
    let configured2 = ConfigurePredicateCellForMask(2,128,2,8,TileDataType_FP32,TileLayout_CUBE_M16,'1111');
    let configured3 = ConfigurePredicateCellForMask(3,128,2,3,TileDataType_U32,TileLayout_CUBE_M16,'1111');
    let configured4 = ConfigurePredicateCellForMask(4,128,2,3,TileDataType_FP32,TileLayout_CUBE_M16,'1111');
    assert configured1 && configured2 && configured3 && configured4;
    for index = 1 to 4 do
        for row = 0 to 1 do
            for column = 0 to _Tiles[[index]].valid_columns - 1 looplimit 8 do
                WriteTileElement(index as TileIndex, row as integer {0..65535},
                    column as integer {0..65535}, if column MOD 2 == 0 then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
            end;
        end;
        MarkTileValidRegionDefined(index as TileIndex);
        InstallRelativeTileFixture(index as TileIndex, index as TileIndex);
    end;
    LogicalAssemblyWriter(TRUE,FALSE,0,8);
    let slot = BundleLocalGenerationSlot(1, '1111');
    let parent = _LocalGenerations[[slot]].working_destination;
    let base_ready = ConfigurePredicateCellForMask(17,128,2,3,
        TileDataType_U32,TileLayout_CUBE_M16,'1111');
    assert base_ready;
    for row = 0 to 1 do
        for column = 0 to 2 do
            WriteTileElement(17, row as integer {0..65535}, column as integer {0..65535}, Zeros{PTO_XLEN} + 1);
        end;
    end;
    WriteTileElement(17,0,2,Zeros{PTO_XLEN} + 3);
    MarkTileValidRegionDefined(17);
    InstallRelativeTileFixture(17,parent);
    InstallRelativeTileFixture(16,17);
    WritePEGPR(0,2,Zeros{PTO_XLEN});
    WritePEGPR(1,2,Zeros{PTO_XLEN});
    WritePEGPR(2,2,Zeros{PTO_XLEN});
    WritePEGPR(3,2,Zeros{PTO_XLEN});
    LogicalAssemblyWriter(FALSE,TRUE,1,3);
    assert _Tiles[[17]].storage_kind == TileStorage_PredicateCell &&
           ReadTileElement(17,0,0) == Zeros{PTO_XLEN} + 1 &&
           !_LocalGenerations[[slot]].published;
    return 0;
end;
