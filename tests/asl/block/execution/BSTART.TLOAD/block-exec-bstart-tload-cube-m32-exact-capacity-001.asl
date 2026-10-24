// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-CUBE-M32-EXACT-CAPACITY-001","source":"asl/block/execution/BSTART.TLOAD.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001","PTO-CUBE-CELL-STATE-001","PTO-INST-BLOCK-BSTART-TLOAD"],"kind":"execution","summary":"Decoded CUBE_M32/U8 TLOAD derives its complete physical destination from the exact 512-byte TSize.","pass_condition":"valid 32x12 U8 data is loaded into physical 32x16 CUBE_M32 storage without reading the first physical padding byte at the mapped-page boundary.","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/block/model/dispatch/tlsu-layout-conversion.asl","asl/tile/model/memory/load-store.asl"]}
pure func ExactCapacityM32TLoadStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_U8);
    return instruction;
end;

pure func ExactCapacityM32TLoadAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 21;
    return instruction;
end;

pure func ExactCapacityM32TLoadDestination() => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[11:9] = '001';
    instruction[18:15] = Zeros{4} + 3;
    instruction[19] = '1';
    instruction[8:7] = '10';
    return instruction;
end;

pure func ExactCapacityM32TLoadIOR(source0: bits(5),
                                   source1: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    // The final valid byte lands at address 4095. Reading padding column 12
    // from the final row would cross into an unmapped page at address 4096.
    let base = Zeros{PTO_XLEN} + 3712;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 11 looplimit 12 do
            let value = ((row * 13 + column + 1) MOD 251) + 1;
            Store(base + row * 12 + column, 1,
                Zeros{PTO_XLEN} + value);
        end;
    end;
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN} + 12);

    let started = ExecuteCommandInstruction(
        ExactCapacityM32TLoadStart(), 32);
    let attributes = ExecuteCommandInstruction(
        ExactCapacityM32TLoadAttributes(), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 12);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    let destination = ExecuteCommandInstruction(
        ExactCapacityM32TLoadDestination(), 32);
    let stride = ExecuteCommandInstruction(
        ExactCapacityM32TLoadIOR(Zeros{5} + 2, Zeros{5} + 3), 32);
    assert destination == CommandExecution_Executed &&
           stride == CommandExecution_Executed;

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let tile = _Tiles[[_BundleTileBindings[[0]].destination]];
    assert _BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert tile.layout == TileLayout_CUBE_M32 &&
           tile.data_type == TileDataType_U8 &&
           tile.capacity_bytes == 512 && tile.cube_storage_bytes == 512 &&
           tile.rows == 32 && tile.columns == 16 &&
           tile.valid_rows == 32 && tile.valid_columns == 12;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 11 looplimit 12 do
            let value = ((row * 13 + column + 1) MOD 251) + 1;
            assert ReadTileElement(
                _BundleTileBindings[[0]].destination,
                row as integer {0..31}, column as integer {0..11}) ==
                Zeros{PTO_XLEN} + value;
        end;
    end;
    return 0;
end;
