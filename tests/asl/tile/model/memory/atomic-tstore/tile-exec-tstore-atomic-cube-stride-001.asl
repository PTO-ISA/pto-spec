// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-ATOMIC-CUBE-STRIDE-001","source":"asl/tile/model/memory/atomic-tstore.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-CUBE-CELL-TRANSPORT-001"],"kind":"execution","summary":"Atomic TSTORE preserves padded M32 row pitches, CUBE logical mapping, and M16 valid-row clipping","pass_condition":"a nonuniform 32x256 FP32 M32 source updates only its logical coordinates at 1280-byte pitches and a 15x2 FP32 M16 valid region leaves clipped/padded rows untouched","related_sources":["asl/tile/model/shape/cube-cell.asl","asl/block/model/dispatch/tlsu-atomic-tstore.asl"]}
pure func CubeStrideSourceFP32(linear: integer {0..8191}) => Word
begin
    return Zeros{PTO_XLEN} + 0x3f800000 + linear;
end;

pure func CubeStrideExpectedFP32(linear: integer {0..8191}) => Word
begin
    return Zeros{PTO_XLEN} + 0x3fc00000 + linear;
end;

pure func CubeStrideStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_FP32);
    return instruction;
end;

pure func CubeStrideDATR(layout: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = layout;
    return instruction;
end;

pure func CubeStrideSource() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func CubeStrideIOR() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func RunCubeStride(layout: bits(5), valid_rows: integer {1..32},
                   valid_columns: integer {1..256}, base: Word,
                   stride: Word, dynamic_pc: Word)
begin
    ResetBundleControlState();
    WriteGPR(2, base);
    WriteGPR(3, stride);
    _PC = dynamic_pc;
    _BPC = dynamic_pc;
    let start = ExecuteCommandInstruction(CubeStrideStart(), 32);
    let datr = ExecuteCommandInstruction(CubeStrideDATR(layout), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + valid_columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + valid_rows);
    let source = ExecuteCommandInstruction(CubeStrideSource(), 32);
    let ior = ExecuteCommandInstruction(CubeStrideIOR(), 32);
    assert start == CommandExecution_Executed &&
           datr == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           ior == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
end;

func main() => integer
begin
    assert PTO_MODEL_MEMORY_BYTES == 65536;
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    let configured = ConfigureCubeTileForMaskWithPhysical(0, 32768,
        32, 256, 32, 256, TileDataType_FP32, TileLayout_CUBE_M32, '1111');
    assert configured && TileCubeDescriptorLegal(_Tiles[[0]]);
    InstallRelativeTileFixture(0, 0);
    var tile = _Tiles[[0]];
    for row = 0 to 31 do
        for column = 0 to 255 do
            let element = TileStorageIndex(tile,
                row as integer {0..65535},
                column as integer {0..65535});
            tile.payload[[element]] = CubeStrideSourceFP32(
                (row * 256 + column) as integer {0..8191});
            tile.defined_elements[element] = '1';
        end;
    end;
    tile.defined_valid_elements = 8192;
    tile.contents_defined = TRUE;
    _Tiles[[0]] = tile;
    let base = Zeros{PTO_XLEN} + 4096;
    for row = 0 to 31 do
        for column = 0 to 319 do
            let initial = if column < 256 then
                Zeros{PTO_XLEN} + 0x3f000000
                else Zeros{PTO_XLEN} + 0xdeadbeef;
            Store(base + row * 1280 + column * 4, 4,
                initial);
        end;
    end;
    assert TileReadLogicalElement(tile, TileLogicalLinearIndex(tile, 0, 0)) ==
           Zeros{PTO_XLEN} + 0x3f800000;
    assert TileReadLogicalElement(tile, TileLogicalLinearIndex(tile, 0, 1)) ==
           CubeStrideSourceFP32(1);
    assert TileReadLogicalElement(tile, TileLogicalLinearIndex(tile, 31, 255)) ==
           CubeStrideSourceFP32(8191);
    RunCubeStride(Zeros{5} + 24, 32, 256, base,
        Zeros{PTO_XLEN} + 1280, entry + 0x20);
    assert !_MemoryEventCaptureEnabled && _MemoryEventCount == 0;
    for row = 0 to 31 do
        for column = 0 to 319 do
            let actual = LoadUnsigned(base + row * 1280 + column * 4, 4);
            let expected = if column < 256 then
                CubeStrideExpectedFP32((row * 256 + column)
                    as integer {0..8191})
                else Zeros{PTO_XLEN} + 0xdeadbeef;
            assert actual == expected;
        end;
    end;

    ResetProfileState();
    let m16_entry = Zeros{PTO_XLEN} + 0x100;
    let m16_launch = LaunchKernelInvocation(0, m16_entry);
    assert m16_launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    let m16_configured = ConfigureCubeTileForMaskWithPhysical(0, 128,
        16, 2, 15, 2, TileDataType_FP32, TileLayout_CUBE_M16, '1111');
    assert m16_configured && TileCubeDescriptorLegal(_Tiles[[0]]);
    InstallRelativeTileFixture(0, 0);
    tile = _Tiles[[0]];
    for row = 0 to 14 do
        for column = 0 to 1 do
            let element = TileStorageIndex(tile,
                row as integer {0..65535},
                column as integer {0..65535});
            tile.payload[[element]] = Zeros{PTO_XLEN} +
                if column == 0 then 0x3f800000 else 0x40000000;
            tile.defined_elements[element] = '1';
        end;
    end;
    tile.defined_valid_elements = 30;
    tile.contents_defined = TRUE;
    _Tiles[[0]] = tile;
    let m16_base = Zeros{PTO_XLEN} + 0x800;
    for row = 0 to 15 do
        for column = 0 to 3 do
            let initial = if row < 15 && column < 2 then
                Zeros{PTO_XLEN} + 0x3f000000
                else Zeros{PTO_XLEN} + 0xdeadbeef;
            Store(m16_base + row * 16 + column * 4, 4,
                initial);
        end;
    end;
    RunCubeStride(Zeros{5} + 25, 15, 2, m16_base,
        Zeros{PTO_XLEN} + 16, m16_entry + 0x20);
    for row = 0 to 15 do
        for column = 0 to 3 do
            let actual = LoadUnsigned(m16_base + row * 16 + column * 4, 4);
            let expected = if row < 15 && column < 2 then
                if column == 0 then Zeros{PTO_XLEN} + 0x3fc00000
                    else Zeros{PTO_XLEN} + 0x40200000
                else Zeros{PTO_XLEN} + 0xdeadbeef;
            assert actual == expected;
        end;
    end;
    assert _MemoryEventCount == 0;
    return 0;
end;
