// PTO-TEST: {"id":"PTO-AVS-BLOCK-TSTORE-CUBE-DESCRIPTOR-004","source":"asl/block/execution/BSTART.TSTORE.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001"],"kind":"fault","summary":"CUBE TSTORE requires an exact persistent Matrix descriptor","pass_condition":"layout dtype valid-shape and location mismatches independently reject before GM events while preserving the source","related_sources":["asl/tile/model/legality/descriptor-shape.asl","asl/block/model/dispatch/tlsu-layout-conversion.asl"]}
pure func CubeDescriptorTStoreStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func CubeDescriptorTStoreAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 25;
    return instruction;
end;

pure func CubeDescriptorTStoreSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[18:15] = '0000';
    instruction[11:9] = '100';
    instruction[19] = '1';
    return instruction;
end;

func PrepareDescriptorSource(
    capacity: integer {128,256},
    rows: integer {2}, columns: integer {3,4},
    data_type: TileDataType, layout: TileLayout,
    corrupt_location: boolean)
begin
    let configured = ConfigureCubeTileForMask(0, capacity, rows, columns,
        data_type, layout, TileLocation_Matrix, '0001');
    assert configured;
    var tile = _Tiles[[0]];
    for row = 0 to rows - 1 do
        for column = 0 to columns - 1 do
            let element = TileStorageIndex(tile,
                row as integer {0..65535},
                column as integer {0..65535});
            tile.payload[[element]] = Zeros{PTO_XLEN} + 1;
            tile.defined_elements[element] = '1';
        end;
    end;
    tile.defined_valid_elements = (rows * columns) as integer {0..16384};
    tile.contents_defined = TRUE;
    if corrupt_location then tile.location = TileLocation_Any; end;
    _Tiles[[0]] = tile;
end;

func DescriptorMismatchRejects(
    capacity: integer {128,256},
    columns: integer {3,4}, data_type: TileDataType,
    layout: TileLayout, corrupt_location: boolean) => boolean
begin
    ResetProfileState();
    PrepareDescriptorSource(
        capacity, 2, columns, data_type, layout, corrupt_location);
    _Memory[[0]] = Zeros{8} + 0xa5;
    let start_status = ExecuteCommandInstruction(
        CubeDescriptorTStoreStart(), 32);
    let datr_status = ExecuteCommandInstruction(
        CubeDescriptorTStoreAttributes(), 32);
    if start_status != CommandExecution_Executed ||
       datr_status != CommandExecution_Executed then return FALSE; end;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let source_status = ExecuteCommandInstruction(
        CubeDescriptorTStoreSource(), 32);
    if source_status != CommandExecution_Executed then return FALSE; end;
    StartMemoryEventCapture(0);
    let completed = ExecuteBundleTileOperation();
    let rejected = !completed && _LastFault == Fault_TileLegality &&
        _MemoryEventCount == 0 && _Memory[[0]] == Zeros{8} + 0xa5 &&
        _Tiles[[0]].allocated && _Tiles[[0]].contents_defined;
    StopMemoryEventCapture();
    return rejected;
end;

func main() => integer
begin
    let layout = DescriptorMismatchRejects(
        256, 3, TileDataType_FP16, TileLayout_CUBE_M32, FALSE);
    assert layout;
    let data_type = DescriptorMismatchRejects(
        256, 3, TileDataType_FP32, TileLayout_CUBE_M16, FALSE);
    assert data_type;
    let shape = DescriptorMismatchRejects(
        128, 4, TileDataType_FP16, TileLayout_CUBE_M16, FALSE);
    assert shape;
    let location = DescriptorMismatchRejects(
        128, 3, TileDataType_FP16, TileLayout_CUBE_M16, TRUE);
    assert location;
    return 0;
end;
