// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-WEIGHT-EQUIVALENCE-001","source":"asl/block/execution/BSTART.TLOAD.asl","requirements":["PTO-BSTART-TLOAD-WEIGHT-NK-CONTRACT-001","PTO-BSTART-TLOAD-WEIGHT-SOURCE-001","PTO-BSTART-TLOAD-WEIGHT-KORDER-001","PTO-BSTART-TLOAD-WEIGHT-DEFINEDNESS-001"],"kind":"execution","summary":"OHWI2NK and OIHW2NK singleton weight TLOADs publish equivalent Shared NK contents.","pass_condition":"The two explicit weight layouts load the same convolution weights into two row-major Shared descriptors with identical valid contents and K-contiguous geometry.","related_sources":["asl/block/model/dispatch/weight-to-shared-execution.asl","asl/block/model/memory/weight-to-shared-gm.asl"]}
func WeightStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func WeightAttributes(layout: integer {10..11}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + layout;
    return instruction;
end;

func WeightIOR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func WeightShared(shared_tile_id: integer {0..63}) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = Zeros{6} + shared_tile_id;
    instruction[18:15] = '0001';
    instruction[11:9] = '001';
    return instruction;
end;

func StoreOHWI(base: integer, cin: integer, cout: integer,
              kernel_h: integer, kernel_w: integer)
begin
    for oc = 0 to cout - 1 looplimit 4 do
        for kh = 0 to kernel_h - 1 looplimit 4 do
            for kw = 0 to kernel_w - 1 looplimit 4 do
                for ci = 0 to cin - 1 looplimit 32 do
                    let index = (((oc * kernel_h + kh) * kernel_w + kw) * cin + ci);
                    let value = 1 + (oc * 1000) + (kh * 100) +
                        (kw * 10) + ci;
                    Store(Zeros{PTO_XLEN} + base + index * 2, 2,
                        Zeros{PTO_XLEN} + value);
                end;
            end;
        end;
    end;
end;

func StoreOIHW(base: integer, cin: integer, cout: integer,
              kernel_h: integer, kernel_w: integer)
begin
    for oc = 0 to cout - 1 looplimit 4 do
        for ci = 0 to cin - 1 looplimit 32 do
            for kh = 0 to kernel_h - 1 looplimit 4 do
                for kw = 0 to kernel_w - 1 looplimit 4 do
                    let index = (((oc * cin + ci) * kernel_h + kh) *
                        kernel_w + kw);
                    let value = 1 + (oc * 1000) + (kh * 100) +
                        (kw * 10) + ci;
                    Store(Zeros{PTO_XLEN} + base + index * 2, 2,
                        Zeros{PTO_XLEN} + value);
                end;
            end;
        end;
    end;
end;

func IssueWeight(layout: integer {10..11}, shared_tile_id: integer {0..63},
                 gm_base: integer, shape: bits(64)) => boolean
begin
    WriteGPR(2, Zeros{PTO_XLEN} + gm_base);
    WriteGPR(3, shape);
    WriteGPR(4, Zeros{PTO_XLEN});
    let start_status = ExecuteCommandInstruction(WeightStart(), 32);
    let datr_status = ExecuteCommandInstruction(WeightAttributes(layout), 32);
    assert start_status == CommandExecution_Executed;
    assert datr_status == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 16);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 16);
    let ior_status = ExecuteCommandInstruction(WeightIOR(), 32);
    let shared_status = ExecuteCommandInstruction(
        WeightShared(shared_tile_id), 32);
    assert ior_status == CommandExecution_Executed;
    assert shared_status == CommandExecution_Executed;
    return ExecuteBundleTileOperation();
end;

func main() => integer
begin
    ResetProfileState();
    let cin = 3;
    let cout = 2;
    let kernel_h = 2;
    let kernel_w = 2;
    let shape = Zeros{64} + cin + (cout << 16) +
        (kernel_h << 32) + (kernel_w << 40);
    StoreOHWI(0, cin, cout, kernel_h, kernel_w);
    StoreOIHW(512, cin, cout, kernel_h, kernel_w);
    let ohwi_completed = IssueWeight(10, 8, 0, shape);
    assert ohwi_completed;
    let ohwi = SharedTileRecord((Zeros{6} + 8) as SharedTileID);
    assert ohwi.tile.layout == TileLayout_RowMajor;
    assert ohwi.tile.columns == 16 && ohwi.tile.valid_rows == 2 &&
        ohwi.tile.valid_columns == 16;
    ClearBundleHeaderState();
    let oihw_completed = IssueWeight(11, 9, 512, shape);
    assert oihw_completed;
    let oihw = SharedTileRecord((Zeros{6} + 9) as SharedTileID);
    assert oihw.tile.layout == TileLayout_RowMajor;
    for row = 0 to 1 looplimit 2 do
        for col = 0 to 15 looplimit 16 do
            let left = TileReadLogicalElement(ohwi.tile,
                TileLogicalLinearIndex(ohwi.tile, row, col));
            let right = TileReadLogicalElement(oihw.tile,
                TileLogicalLinearIndex(oihw.tile, row, col));
            assert left == right;
        end;
    end;
    return 0;
end;
