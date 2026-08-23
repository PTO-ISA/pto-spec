// PTO-TEST: {"id":"PTO-AVS-BLOCK-SHARED-TLSU-PER-PE-GM-EXECUTION-001","source":"asl/block/model/dispatch/shared-tlsu.asl","requirements":["PTO-ARCH-GM-ACCESS-001","PTO-INST-TILE-TLOAD"],"kind":"execution","summary":"Shared TLOAD resolves B.IOR base and stride independently in every selected PE GPR file.","pass_condition":"Four fixed Shared quarters load from four PE-private base/stride pairs selected by the same encoded RegSrc fields.","related_sources":["asl/tile/model/memory/shared-movement.asl","asl/arch/programming-model/scalar-registers.asl"]}
pure func PerPETestTLSUStart(function: bits(5), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[24:20] = function;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func PerPETestSharedBinding(shared_tile_id: bits(6), size_code: bits(4),
                                pe_mode: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    return instruction;
end;

pure func PerPETestScalarBinding(source0: bits(5), source1: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00000013;
    instruction[19:15] = source0;
    instruction[24:20] = source1;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    WritePEGPR(0, 2, Zeros{PTO_XLEN});
    WritePEGPR(1, 2, Zeros{PTO_XLEN} + 0x200);
    WritePEGPR(2, 2, Zeros{PTO_XLEN} + 0x400);
    WritePEGPR(3, 2, Zeros{PTO_XLEN} + 0x600);
    WritePEGPR(0, 3, Zeros{PTO_XLEN} + 256);
    WritePEGPR(1, 3, Zeros{PTO_XLEN} + 320);
    WritePEGPR(2, 3, Zeros{PTO_XLEN} + 384);
    WritePEGPR(3, 3, Zeros{PTO_XLEN} + 448);

    _Memory[[0]] = Zeros{8} + 0x11;
    _Memory[[0x280]] = Zeros{8} + 0x22;
    _Memory[[0x580]] = Zeros{8} + 0x33;
    _Memory[[0x840]] = Zeros{8} + 0x44;

    let start = ExecuteCommandInstruction(
        PerPETestTLSUStart('00000', Zeros{5} + 24), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 32);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 32);
    let shared = ExecuteCommandInstruction(
        PerPETestSharedBinding(Zeros{6} + 31, '0011', '111'), 32);
    let scalar = ExecuteCommandInstruction(
        PerPETestScalarBinding(Zeros{5} + 2, Zeros{5} + 3), 32);
    assert start == CommandExecution_Executed;
    assert shared == CommandExecution_Executed;
    assert scalar == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed;

    assert ReadSharedTileWord((Zeros{6} + 31) as SharedTileID, 0) ==
        Zeros{PTO_XLEN} + 0x11;
    assert ReadSharedTileWord((Zeros{6} + 31) as SharedTileID, 16 as PackedTileElementIndex) ==
        Zeros{PTO_XLEN} + 0x22;
    assert ReadSharedTileWord((Zeros{6} + 31) as SharedTileID, 32 as PackedTileElementIndex) ==
        Zeros{PTO_XLEN} + 0x33;
    assert ReadSharedTileWord((Zeros{6} + 31) as SharedTileID, 48 as PackedTileElementIndex) ==
        Zeros{PTO_XLEN} + 0x44;
    return 0;
end;
