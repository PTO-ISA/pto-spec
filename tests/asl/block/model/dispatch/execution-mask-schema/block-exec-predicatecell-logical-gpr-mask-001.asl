// PTO-TEST: {"id":"PTO-AVS-BLOCK-PREDICATECELL-LOGICAL-GPR-MASK-001","source":"asl/block/model/dispatch/execution-mask-schema.asl","requirements":["PTO-TAND-CONTRACT-001","PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001","PTO-B-IOR-BINDING-001","PTO-B-IOT-STREAM-001"],"kind":"execution","summary":"Decoded PredicateCell logical data interacts with GPR ExecutionMask, inversion and control checks","pass_condition":"all-zero, all-one, inverted masks and active legality follow coordinate rules; malformed GPR destination control rejects before publication","related_sources":["asl/tile/model/legality/predicate-carriers.asl","asl/tile/model/execution/execution-mask-state.asl"]}
func RunPredicateGPR(case_id: integer {0..4})
begin
    ResetProfileState();
    let left = ConfigurePredicateCell(10,128,1,2,TileDataType_U32,TileLayout_CUBE_M16);
    let right = ConfigurePredicateCell(11,128,1,2,TileDataType_FP32,TileLayout_CUBE_M16);
    assert left && right;
    InstallRelativeTileFixture(10,10); InstallRelativeTileFixture(11,11);
    if case_id != 0 then
        WriteTileElement(10,0,0,if case_id == 2 || case_id == 3 then Zeros{PTO_XLEN} + 3 else Zeros{PTO_XLEN} + 1);
        WriteTileElement(11,0,0,Zeros{PTO_XLEN} + 1);
        WriteTileElement(10,0,1,Zeros{PTO_XLEN} + 1);
        WriteTileElement(11,0,1,Zeros{PTO_XLEN} + 1);
    end;
    var mask = Zeros{PTO_XLEN};
    if case_id != 0 then mask[0] = '1'; end;
    if case_id == 1 || case_id == 3 || case_id == 4 then mask[16] = '1'; end;
    WritePEGPR(0,2,mask); WritePEGPR(0,3,Zeros{PTO_XLEN});
    var start = Zeros{64} + 0x00019181;
    start[24:20] = Zeros{5} + 6; start[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    let started = ExecuteCommandInstruction(start,32);
    var attrs = Zeros{64} + 0x00001023;
    attrs[24:20] = DTYPE_NONE; attrs[11:7] = Zeros{5} + 31;
    attrs[13] = '1'; attrs[14] = if case_id == 2 then '1' else '0';
    let attributed = ExecuteCommandInstruction(attrs,32);
    var ior = Zeros{64} + 0x00000013;
    ior[19:15] = Zeros{5} + 2; ior[24:20] = Zeros{5} + 3;
    ior[26] = '1'; ior[11:7] = if case_id == 4 then Zeros{5} + 1 else Zeros{5};
    let masked = ExecuteCommandInstruction(ior,32);
    var iot = Zeros{64} + 0x00004013;
    iot[25:20] = Zeros{6} + 10; iot[31:26] = Zeros{6} + 11;
    iot[19] = '1'; iot[18:15] = Zeros{4} + 1; iot[11:9] = '001';
    let bound = ExecuteCommandInstruction(iot,32);
    SetBundleDimension(0,Zeros{PTO_XLEN} + 2); SetBundleDimension(1,Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2,Zeros{PTO_XLEN} + 8);
    assert started == CommandExecution_Executed && attributed == CommandExecution_Executed &&
           masked == CommandExecution_Executed && bound == CommandExecution_Executed;
    let done = ExecuteBundleTileOperation();
    if case_id >= 3 then
        assert !done && _LastFault == Fault_TileLegality && !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    else
        assert done && _LastFault == Fault_None;
        let output = _BundleTileBindings[[0]].destination;
        assert _Tiles[[output]].storage_kind == TileStorage_PredicateCell;
        assert ReadTileElement(output,0,0) == (if case_id == 1 then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
        assert ReadTileElement(output,0,1) == (if case_id == 0 then Zeros{PTO_XLEN} else Zeros{PTO_XLEN} + 1);
    end;
end;
func main() => integer
begin
    for case_id = 0 to 4 do RunPredicateGPR(case_id as integer {0..4}); end;
    return 0;
end;
