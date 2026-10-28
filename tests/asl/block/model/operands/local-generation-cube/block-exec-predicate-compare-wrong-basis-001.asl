// PTO-TEST: {"id":"PTO-AVS-BLOCK-PREDICATE-COMPARE-WRONG-BASIS-001","source":"asl/block/model/operands/local-generation-cube.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-TAND-CONTRACT-001","PTO-TCMP-CONTRACT-001"],"kind":"execution","summary":"Decoded TCMP continuation rejects a PredicateCell parent with incompatible producer basis","pass_condition":"a U32 comparison cannot write a matching U8-basis logical parent and publishes no generation","related_sources":["asl/block/model/dispatch/destination-operation.asl","asl/tile/model/legality/destination-value.asl"]}
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
    let bound = ExecuteCommandInstruction(LogicalAssemblyInputs(init), 32);
    var parent = CommandExecution_Executed;
    if !init then
        parent = ExecuteCommandInstruction(Zeros{64} + 0x01085e13, 32);
    end;
    let assembled = ExecuteCommandInstruction(LogicalAssemblyModifier(init,last,offset), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    assert parent == CommandExecution_Executed;
    assert assembled == CommandExecution_Executed;
    let completed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x100 + offset * 16);
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
    let left = ConfigureCubeTileForMask(10,128,2,2,TileDataType_U32,TileLayout_CUBE_M16,'1111');
    let right = ConfigureCubeTileForMask(11,128,2,2,TileDataType_U32,TileLayout_CUBE_M16,'1111');
    assert left && right;
    InstallRelativeTileFixture(10,10); InstallRelativeTileFixture(11,11);
    for row = 0 to 1 do
        for column = 0 to 1 do
            WriteTileElement(10,row as integer {0..65535},column as integer {0..65535},Zeros{PTO_XLEN} + 1);
            WriteTileElement(11,row as integer {0..65535},column as integer {0..65535},Zeros{PTO_XLEN} + 1);
        end;
    end;
    MarkTileValidRegionDefined(10); MarkTileValidRegionDefined(11);
    assert TileCubeNumericShapeMatch(10,11) && TileCubeNumericSourceLegalAs(10,TileDataType_U32) &&
           TileCubeNumericSourceLegalAs(11,TileDataType_U32) && TilePredicateCellDescriptorLegal(parent) &&
           _Tiles[[parent]].predicate_basis_type == TileDataType_U8;
    let (writer_valid, writer) = BundleLocalGenerationCubeWriterView(_Tiles[[parent]],1,1,2,2);
    assert writer_valid && TilePredicateCellValueDescriptorLegal(writer,TileDataType_U8) &&
           writer.valid_rows == _Tiles[[10]].valid_rows && writer.valid_columns == _Tiles[[10]].valid_columns &&
           writer.layout == _Tiles[[10]].layout;
    var compare_writer = writer; compare_writer.predicate_basis_type = TileDataType_U32;
    assert TilePredicateCellValueDescriptorLegal(compare_writer,TileDataType_U32);
    var start = Zeros{64} + 0x00019181;
    start[24:20] = Zeros{5} + 13; start[31:27] = TileDataTypeToEncoding(TileDataType_U32);
    let started = ExecuteCommandInstruction(start,32);
    var attrs = Zeros{64} + 0x00001023; attrs[24:20] = DTYPE_NONE;
    let attributed = ExecuteCommandInstruction(attrs,32);
    SetBundleDimension(0,Zeros{PTO_XLEN} + 2); SetBundleDimension(1,Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2,Zeros{PTO_XLEN} + 2);
    var inputs = Zeros{64} + 0x00004013;
    inputs[25:20] = Zeros{6} + 10; inputs[31:26] = Zeros{6} + 11; inputs[11:9] = '111';
    let bound = ExecuteCommandInstruction(inputs,32);
    let parentref = ExecuteCommandInstruction(Zeros{64} + 0x01085e13,32);
    let assembled = ExecuteCommandInstruction(LogicalAssemblyModifier(FALSE,TRUE,1),32);
    assert started == CommandExecution_Executed && attributed == CommandExecution_Executed &&
           bound == CommandExecution_Executed && parentref == CommandExecution_Executed &&
           assembled == CommandExecution_Executed;
    let completed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x200);
    assert !completed && _LastFault == Fault_TileLegality && !_LocalGenerations[[slot]].published;
    return 0;
end;
