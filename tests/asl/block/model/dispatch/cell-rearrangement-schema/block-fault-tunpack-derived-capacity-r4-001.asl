// PTO-TEST: {"id":"PTO-AVS-BLOCK-TUNPACK-DERIVED-CAPACITY-R4-001","source":"asl/block/model/dispatch/cell-rearrangement-schema.asl","requirements":["PTO-TUNPACK-CONTRACT-001"],"kind":"fault","summary":"Decoded TUNPACK reports allocation failure when the selected destination TSize cannot hold all derived raw-word outputs.","pass_condition":"U8 CUBE_M32 [32,9] derives U8 [32,12]; destination TSize 1 faults with Fault_TileAllocation before allocation or status publication.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/layout-rearrangement.asl","asl/tile/model/state/allocation.asl"]}
pure func CapacityTUNPACKStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = Zeros{5} + 24;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func CapacityLayoutAttribute() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 29;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let source = ConfigureCubeTile(1, 512, 32, 9,
        TileDataType_U8, TileLayout_CUBE_M32);
    assert source;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 8 looplimit 9 do
            WriteTileElement(1, row, column,
                Zeros{PTO_XLEN} + 1 + row + column);
        end;
    end;
    let started = ExecuteCommandInstruction(CapacityTUNPACKStart(), 32);
    let attributed = ExecuteCommandInstruction(
        CapacityLayoutAttribute(), 32);
    assert started == CommandExecution_Executed;
    assert attributed == CommandExecution_Executed;
    WriteGPR(2, Zeros{PTO_XLEN} + 0x00000100);
    SetBundleScalarBinding(0, 0, 2, 0, 0, 1);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileAllocation;
    assert !_Tiles[[0]].allocated;
    assert NumericStatusFlags() == Zeros{5};
    return 0;
end;
