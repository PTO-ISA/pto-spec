// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-IOT-CAPACITY-003","source":"asl/block/operands/B.IOT.asl","requirements":["PTO-INST-BLOCK-B-IOT","PTO-INST-TILE-TLOAD","PTO-TILE-CAPACITY-PER-PE"],"kind":"boundary","summary":"Multiple separate Local SizeCode-10 objects can fill one PE's aggregate 256 KiB pool.","pass_condition":"Four separate 64 KiB Local B.IOT destinations commit without fault, reaching 256 KiB in every selected PE without using a Local SizeCode-12 object.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/state/allocation.asl","asl/tile/model/capacity/local.asl"]}
pure func BIOTCapacityStart(data_type: bits(5)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BIOTCapacityDestination(size_code: bits(4), pe_mode: bits(3),
                                  destination: bits(2)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[18:15] = size_code;
    instruction[11:9] = pe_mode;
    instruction[8:7] = destination;
    instruction[19] = '1';
    return instruction;
end;

func RunLocalSizeCode10(destination: integer)
begin
    let started = ExecuteCommandInstruction(
        BIOTCapacityStart(Zeros{5} + 24), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let bound = ExecuteCommandInstruction(
        BIOTCapacityDestination('1010', '111',
            (Zeros{2} + destination) as bits(2)), 32);
    assert started == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
end;

func main() => integer
begin
    ResetProfileState();
    assert TileSizeCodeBytes(10) == 65536;
    assert !LocalTileSizeCodeIsLegal(11);
    assert TileSizeCodeBytes(12) == 262144;

    for destination = 0 to 3 looplimit 4 do
        if destination != 0 then ResetBundleControlState(); end;
        RunLocalSizeCode10(destination);
    end;

    for destination = 0 to 3 looplimit 4 do
        let tile_index = destination * 16;
        assert _Tiles[[tile_index]].allocated;
        assert _Tiles[[tile_index]].capacity_bytes == 65536;
        assert _TileAllocationMasks[[tile_index]] == '1111';
    end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        assert TileCapacityInUseForPE(pe) == 262144;
    end;
    assert TileCapacityInUse() == 1048576;
    return 0;
end;
