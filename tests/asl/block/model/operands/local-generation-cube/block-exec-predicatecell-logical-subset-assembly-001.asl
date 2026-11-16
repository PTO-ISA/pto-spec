// PTO-TEST: {"id":"PTO-AVS-BLOCK-PREDICATECELL-LOGICAL-SUBSET-ASSEMBLY-001","source":"asl/block/model/operands/local-generation-cube.asl","requirements":["PTO-B-ASSEMBLE-CUBE-PARENT-GEOMETRY-001","PTO-TAND-CONTRACT-001"],"kind":"execution","summary":"Decoded subset PE continuation composes and publishes a PredicateCell parent","pass_condition":"a 1110 MIDDLE writer is accepted between 1111 INIT and LAST and the final published descriptor uses the common prefix","related_sources":["asl/block/model/dispatch/destination-operation.asl","asl/tile/model/legality/destination-value.asl"]}
pure func LogicalAssemblyStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00019181;
    instruction[24:20] = Zeros{5} + 6;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;
pure func LogicalAssemblyInputs(init: boolean, pe_mode: bits(3), source0: integer {0..63}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[25:20] = Zeros{6} + source0;
    instruction[31:26] = Zeros{6} + (source0 + 1);
    instruction[19] = if init then '1' else '0';
    instruction[18:15] = if init then Zeros{4} + 2 else Zeros{4};
    instruction[11:9] = pe_mode; instruction[8:7] = if init then '01' else '00';
    return instruction;
end;
pure func LogicalAssemblyModifier(init: boolean, last: boolean,
    offset: integer {0..2}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = if init then '1' else '0';
    instruction[11] = if last then '1' else '0';
    instruction[10:7] = '0001';
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;
func LogicalAssemblyWriter(init: boolean, last: boolean,
    offset: integer {0..2}, columns: integer {1..8}, pe_mode: bits(3), source0: integer {0..63})
    => boolean
begin
    let started = ExecuteCommandInstruction(LogicalAssemblyStart(), 32);
    let attributes = ExecuteCommandInstruction(Zeros{64} + 0x01f01fa3, 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 8);
    let bound = ExecuteCommandInstruction(LogicalAssemblyInputs(init,pe_mode,source0), 32);
    var parent = CommandExecution_Executed;
    if !init then
        var parent_instruction = Zeros{64} + 0x01085e13;
        parent_instruction[11:9] = pe_mode;
        parent = ExecuteCommandInstruction(parent_instruction, 32);
    end;
    let assembled = ExecuteCommandInstruction(LogicalAssemblyModifier(init,last,offset), 32);
    assert started == CommandExecution_Executed;
    assert attributes == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    assert parent == CommandExecution_Executed;
    assert assembled == CommandExecution_Executed;
    let completed = CompleteBundleAt(Zeros{PTO_XLEN} + 0x100 + offset * 16);
    if !completed then return FALSE; end;
    let slot = BundleLocalGenerationSlot(1, '1111');
    let ready = CompleteBundleLocalGenerationWriterEvent(slot, _BundleExecutionDomainToken, offset, 1);
    return ready;
end;
func main() => integer
begin
    ResetProfileState();
    let configured1 = ConfigurePredicateCellForMask(1,128,2,8,TileDataType_U32,TileLayout_CUBE_M16,'1111');
    let configured2 = ConfigurePredicateCellForMask(2,128,2,8,TileDataType_FP32,TileLayout_CUBE_M16,'1111');
    let configured3 = ConfigurePredicateCellForMask(3,128,2,3,TileDataType_U32,TileLayout_CUBE_M16,'1111');
    let configured4 = ConfigurePredicateCellForMask(4,128,2,3,TileDataType_FP32,TileLayout_CUBE_M16,'1111');
    let configured5 = ConfigurePredicateCellForMask(5,128,2,3,TileDataType_U32,TileLayout_CUBE_M16,'1111');
    let configured6 = ConfigurePredicateCellForMask(6,128,2,3,TileDataType_FP32,TileLayout_CUBE_M16,'1111');
    assert configured1 && configured2 && configured3 && configured4 && configured5 && configured6;
    for index = 1 to 6 do
        for row = 0 to 1 do
            for column = 0 to _Tiles[[index]].valid_columns - 1 looplimit 8 do
                WriteTileElement(index as TileIndex, row as integer {0..65535},
                    column as integer {0..65535}, if column MOD 2 == 0 then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
            end;
        end;
        MarkTileValidRegionDefined(index as TileIndex);
        InstallRelativeTileFixture(index as TileIndex, index as TileIndex);
    end;
    let init_ready = LogicalAssemblyWriter(TRUE,FALSE,0,8,'111',1);
    let slot = BundleLocalGenerationSlot(1, '1111');
    let parent = _LocalGenerations[[slot]].working_destination;
    let middle_ready = LogicalAssemblyWriter(FALSE,FALSE,1,3,'110',3);
    let last_ready = LogicalAssemblyWriter(FALSE,TRUE,1,3,'100',5);
    assert init_ready && middle_ready && last_ready;
    assert _LocalGenerations[[slot]].published && _Tiles[[parent]].storage_kind == TileStorage_PredicateCell &&
           _Tiles[[parent]].predicate_basis_type == TileDataType_U8 && _Tiles[[parent]].rows == 16 &&
           _Tiles[[parent]].columns == 16 && _Tiles[[parent]].valid_rows == 2 && _Tiles[[parent]].valid_columns == 11;
    assert ReadTileElement(parent,0,8) == Zeros{PTO_XLEN} + 1 &&
           ReadTileElement(parent,0,9) == Zeros{PTO_XLEN};
    return 0;
end;
