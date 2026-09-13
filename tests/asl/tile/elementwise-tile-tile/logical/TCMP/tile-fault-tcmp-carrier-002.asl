// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-CARRIER-FAULT-002","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-TCMP-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"fault","summary":"Decoded TCMP rejects width-mismatched and packed reinterpret carriers before allocation","pass_condition":"S32 over FP16 backings and U8 over distinct U4X2/S4X2 backings both raise Tile legality without allocating a predicate destination","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/tile/model/legality/operand-schema.asl"]}
func RunTCMPCarrierFault(
    operation_instruction: Word,
    left_type: TileDataType,
    right_type: TileDataType)
begin
    ResetProfileState();
    ConfigureTile(1, 128, 2, 2, 1, 2, left_type,
        TileLayout_RowMajor);
    ConfigureTile(2, 128, 2, 2, 1, 2, right_type,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 2);
    let started = ExecuteCommandInstruction(operation_instruction, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
end;

func main() => integer
begin
    RunTCMPCarrierFault(
        Zeros{PTO_XLEN} + 0x88d19181,
        TileDataType_FP16, TileDataType_FP16);
    RunTCMPCarrierFault(
        Zeros{PTO_XLEN} + 0xd8d19181,
        TileDataType_U4X2, TileDataType_S4X2);
    return 0;
end;
