// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-WEIGHT-WINDOWS-001","source":"asl/block/model/memory/weight-to-shared-gm.asl","requirements":["PTO-BSTART-TLOAD-WEIGHT-KORDER-001","PTO-BSTART-TLOAD-WEIGHT-SOURCE-001","PTO-BSTART-TLOAD-WEIGHT-NK-CONTRACT-001"],"kind":"execution","summary":"Weight TLOAD accepts middle and terminal aligned K windows with an arbitrary NStart.","pass_condition":"FP16 Cout=3 Cin=3 KernelH=3 KernelW=1 publishes KStart=16 and KStart=32 windows for NStart=1, preserving K-contiguous row-major geometry and the expected source rows.","related_sources":["asl/block/model/dispatch/weight-to-shared-execution.asl","asl/block/model/dispatch/weight-to-shared-schema.asl"]}
func WindowStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func WindowDATR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 10;
    return instruction;
end;

func WindowIOR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func WindowShared() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + 13;
    instruction[18:15] = '0011';
    instruction[11:9] = '001';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let cin = 3;
    let cout = 3;
    let kernel_h = 3;
    let kernel_w = 1;
    for oc = 0 to cout - 1 looplimit 3 do
        for kh = 0 to kernel_h - 1 looplimit 3 do
            for ci = 0 to cin - 1 looplimit 3 do
                let index = ((oc * kernel_h + kh) * cin + ci);
                let value = 10000 * oc + 100 * kh + ci + 1;
                Store(Zeros{PTO_XLEN} + index * 2, 2,
                    Zeros{PTO_XLEN} + value);
            end;
        end;
    end;
    for window = 0 to 1 looplimit 2 do
        let k_start = 16 + window * 16;
        WriteGPR(2, Zeros{PTO_XLEN});
        WriteGPR(3, Zeros{64} + cin + (cout << 16) +
            (kernel_h << 32) + (kernel_w << 40));
        WriteGPR(4, Zeros{64} + 1 + (k_start << 32));
        let started = ExecuteCommandInstruction(WindowStart(), 32);
        let datr = ExecuteCommandInstruction(WindowDATR(), 32);
        assert started == CommandExecution_Executed;
        assert datr == CommandExecution_Executed;
        SetBundleDimension(0, Zeros{PTO_XLEN} + 16);
        SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
        SetBundleDimension(2, Zeros{PTO_XLEN} + 64);
        let ior = ExecuteCommandInstruction(WindowIOR(), 32);
        let shared = ExecuteCommandInstruction(WindowShared(), 32);
        assert ior == CommandExecution_Executed;
        assert shared == CommandExecution_Executed;
        let completed = ExecuteBundleTileOperation();
        assert completed && _LastFault == Fault_None;
        let tile = SharedTileRecord((Zeros{6} + 13) as SharedTileID).tile;
        assert tile.layout == TileLayout_RowMajor;
        assert tile.columns == 64 && tile.valid_rows == 1 &&
            tile.valid_columns == 16;
        let kh = k_start DIVRM 16;
        for col = 0 to 15 looplimit 16 do
            let ci = col;
            let element = TileLogicalLinearIndex(tile, 0, col);
            assert TileLogicalElementDefined(tile, element);
            if ci < cin then
                assert TileReadLogicalElement(tile, element) ==
                    Zeros{PTO_XLEN} + 10000 + 100 * kh + ci + 1;
            else
                assert TileReadLogicalElement(tile, element) ==
                    Zeros{PTO_XLEN};
            end;
        end;
        assert !TileLogicalElementDefined(tile,
            TileLogicalLinearIndex(tile, 0, 16));
        if window == 0 then ClearBundleHeaderState(); end;
    end;
    return 0;
end;
