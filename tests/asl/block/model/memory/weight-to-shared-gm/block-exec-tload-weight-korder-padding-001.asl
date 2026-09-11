// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-WEIGHT-KORDER-PADDING-001","source":"asl/block/model/memory/weight-to-shared-gm.asl","requirements":["PTO-BSTART-TLOAD-WEIGHT-KORDER-001","PTO-BSTART-TLOAD-WEIGHT-DEFINEDNESS-001"],"kind":"execution","summary":"Weight TLOAD emits golden dtype-dependent K order with no GM reads for Cin padding.","pass_condition":"FP16 Cin=17 KernelH=2 KernelW=2 is checked in aligned 16-column windows and U8 Cin=33 is checked at its 32-column C0 boundary: source loads follow [kh][kw][c1][c0], Cin padding is defined raw zero without GM access, and each physical tail remains undefined.","related_sources":["asl/block/model/dispatch/weight-to-shared-execution.asl"]}
func WeightKStart(data_type_code: integer {0..31}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + data_type_code;
    return instruction;
end;

func WeightKAttributes() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 10;
    return instruction;
end;

func WeightKIOR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func WeightKShared() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 12;
    instruction[18:15] = '0011';
    instruction[11:9] = '001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let cin = 17;
    let kernel_h = 2;
    let kernel_w = 2;
    let c0 = 16;
    let c1 = 2;
    for kh = 0 to 1 looplimit 2 do
        for kw = 0 to 1 looplimit 2 do
            for ci = 0 to cin - 1 looplimit 17 do
                let source_index = ((kh * kernel_w + kw) * cin + ci);
                let value = 1 + kh * 1000 + kw * 100 + ci;
                Store(Zeros{PTO_XLEN} + source_index * 2, 2,
                    Zeros{PTO_XLEN} + value);
            end;
        end;
    end;
    let shape = Zeros{64} + cin + (1 << 16) +
        (kernel_h << 32) + (kernel_w << 40);
    var cumulative_loads: integer {0..128} = 0;
    for window = 0 to 7 looplimit 8 do
        let k_start = window * c0;
        WriteGPR(2, Zeros{PTO_XLEN});
        WriteGPR(3, shape);
        WriteGPR(4, Zeros{64} + (k_start << 32));
        let start_status = ExecuteCommandInstruction(WeightKStart(4), 32);
        let datr_status = ExecuteCommandInstruction(WeightKAttributes(), 32);
        assert start_status == CommandExecution_Executed;
        assert datr_status == CommandExecution_Executed;
        SetBundleDimension(0, Zeros{PTO_XLEN} + c0);
        SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
        SetBundleDimension(2, Zeros{PTO_XLEN} + 128);
        let ior_status = ExecuteCommandInstruction(WeightKIOR(), 32);
        let shared_status = ExecuteCommandInstruction(WeightKShared(), 32);
        assert ior_status == CommandExecution_Executed;
        assert shared_status == CommandExecution_Executed;
        StartMemoryEventCapture(0);
        let completed = ExecuteBundleTileOperation();
        assert completed && _LastFault == Fault_None;
        let expected_loads = if (k_start MOD 32) == 0 then 16 else 1;
        assert _MemoryEventCount == expected_loads;
        cumulative_loads = (cumulative_loads + _MemoryEventCount) as
            integer {0..128};
        let shared_id = (Zeros{6} + 12) as SharedTileID;
        let tile = SharedTileRecord(shared_id).tile;
        assert tile.layout == TileLayout_RowMajor;
        assert tile.columns == 128 && tile.valid_columns == 16 &&
            tile.valid_rows == 1;
        for col = 0 to 15 looplimit 16 do
            let global_k = k_start + col;
            let kernel_offset = global_k DIVRM (c1 * c0);
            let channel_block_offset = global_k MOD (c1 * c0);
            let kh = kernel_offset DIVRM kernel_w;
            let kw = kernel_offset MOD kernel_w;
            let c1_index = channel_block_offset DIVRM c0;
            let c0_lane = channel_block_offset MOD c0;
            let ci = c1_index * c0 + c0_lane;
            let element = TileLogicalLinearIndex(tile, 0, col);
            assert TileLogicalElementDefined(tile, element);
            if ci < cin then
                assert TileReadLogicalElement(tile, element) ==
                    Zeros{PTO_XLEN} + 1 + kh * 1000 + kw * 100 + ci;
            else
                assert TileReadLogicalElement(tile, element) ==
                    Zeros{PTO_XLEN};
            end;
        end;
        assert !TileLogicalElementDefined(tile,
            TileLogicalLinearIndex(tile, 0, 16));
        StopMemoryEventCapture();
        if window != 7 then ClearBundleHeaderState(); end;
    end;
    assert cumulative_loads == 68;

    // U8 uses C0=32. A window beginning at the second channel block contains
    // one real Cin lane followed by 31 defined padding lanes and performs only
    // the one corresponding byte load.
    ResetProfileState();
    Store(Zeros{PTO_XLEN} + 32, 1, Zeros{PTO_XLEN} + 0x5A);
    WriteGPR(2, Zeros{PTO_XLEN});
    WriteGPR(3, Zeros{64} + 33 + (1 << 16) + (1 << 32) + (1 << 40));
    WriteGPR(4, Zeros{64} + (32 << 32));
    let u8_start = ExecuteCommandInstruction(WeightKStart(27), 32);
    let u8_datr = ExecuteCommandInstruction(WeightKAttributes(), 32);
    assert u8_start == CommandExecution_Executed;
    assert u8_datr == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 64);
    let u8_ior = ExecuteCommandInstruction(WeightKIOR(), 32);
    let u8_shared = ExecuteCommandInstruction(WeightKShared(), 32);
    assert u8_ior == CommandExecution_Executed;
    assert u8_shared == CommandExecution_Executed;
    StartMemoryEventCapture(0);
    let u8_completed = ExecuteBundleTileOperation();
    assert u8_completed && _LastFault == Fault_None;
    assert _MemoryEventCount == 1;
    let u8_tile = SharedTileRecord((Zeros{6} + 12) as SharedTileID).tile;
    assert u8_tile.data_type == TileDataType_U8;
    assert u8_tile.columns == 64 && u8_tile.valid_columns == 32;
    for col = 0 to 31 looplimit 32 do
        let element = TileLogicalLinearIndex(u8_tile, 0, col);
        assert TileLogicalElementDefined(u8_tile, element);
        assert TileReadLogicalElement(u8_tile, element) ==
            (if col == 0 then Zeros{PTO_XLEN} + 0x5A else Zeros{PTO_XLEN});
    end;
    assert !TileLogicalElementDefined(u8_tile,
        TileLogicalLinearIndex(u8_tile, 0, 32));
    StopMemoryEventCapture();
    return 0;
end;
