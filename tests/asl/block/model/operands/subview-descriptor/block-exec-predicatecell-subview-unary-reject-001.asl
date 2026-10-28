// PTO-TEST: {"id":"PTO-AVS-BLOCK-PREDICATECELL-SUBVIEW-UNARY-REJECT-001","source":"asl/block/model/operands/subview-descriptor.asl","requirements":["PTO-B-SUBVIEW-DESCRIPTOR-001","PTO-TNOT-CONTRACT-001"],"kind":"execution","summary":"Decoded TNOT rejects a typed PredicateCell source view","pass_condition":"a typed predicate view cannot escape to Numeric unary execution and rejection leaves the parent unchanged","related_sources":["asl/block/model/dispatch/destination-operation.asl","asl/tile/model/legality/destination-value.asl"]}
pure func LogicalAssemblyStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[24:20] = Zeros{5} + 16;
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
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
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
pure func LogicalSubview(select: boolean) => bits(64)
begin
    var instruction = Zeros{64} + 0x001000d3;
    instruction[31] = if select then '1' else '0';
    return instruction;
end;
func main() => integer
begin
    ResetProfileState();
    let left = ConfigurePredicateCellForMask(1,256,2,11,TileDataType_U32,TileLayout_CUBE_M16,'1111');
    let right = ConfigurePredicateCellForMask(2,256,2,11,TileDataType_FP32,TileLayout_CUBE_M16,'1111');
    assert left && right;
    InstallRelativeTileFixture(1,1);
    InstallRelativeTileFixture(2,2);
    for row = 0 to 1 do
        for column = 0 to 10 do
            WriteTileElement(1,row as integer {0..65535},column as integer {0..65535},
                if column MOD 2 == 0 then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
            WriteTileElement(2,row as integer {0..65535},column as integer {0..65535},Zeros{PTO_XLEN} + 1);
        end;
    end;
    MarkTileValidRegionDefined(1); MarkTileValidRegionDefined(2);
    let started = ExecuteCommandInstruction(LogicalAssemblyStart(),32);
    let attrs = ExecuteCommandInstruction(Zeros{64} + 0x01f01fa3,32);
    SetBundleDimension(0,Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1,Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2,Zeros{PTO_XLEN} + 8);
    var binder = Zeros{64} + 0x00005013;
    binder[25:20] = Zeros{6} + 1; binder[19] = '1';
    binder[18:15] = Zeros{4} + 1; binder[11:9] = '111';
    let bound = ExecuteCommandInstruction(binder,32);
    let view = ExecuteCommandInstruction(LogicalSubview(FALSE),32);
    assert started == CommandExecution_Executed && attrs == CommandExecution_Executed &&
           bound == CommandExecution_Executed && view == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality &&
           !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert _Tiles[[1]].storage_kind == TileStorage_PredicateCell &&
           _Tiles[[1]].predicate_basis_type == TileDataType_U32 &&
           ReadTileElement(1,0,8) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
