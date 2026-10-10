// PTO-TEST: {"id":"PTO-AVS-TILE-LOCAL-CAPACITY-PE-BANK-003","source":"asl/tile/model/capacity/local.asl","requirements":["PTO-TILE-CAPACITY-PER-PE","PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-ARCH-LOCAL-VTAG-LIFETIME-001"],"kind":"boundary","summary":"Selected-PE Local allocation consults only the executing PE bank while capacity reports read each requested bank.","pass_condition":"Four cloned full banks begin at 256 KiB; PE0 last-use frees 64 KiB, an encoded full-mask SizeCode-10 allocation refills PE0, and PE1 remains full with no corresponding destination allocation.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/state/allocation.asl","asl/arch/state/pe-execution-context.asl"]}
pure func PEBankCapacityStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

pure func PEBankCapacityDestination() => bits(64)
begin
    var instruction = Zeros{64} + 0x00006013;
    instruction[18:15] = '1010';
    instruction[11:9] = '111';
    instruction[8:7] = '01';
    instruction[19] = '1';
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    for index = 0 to 3 looplimit 4 do
        ConfigureTileForMask(index as TileIndex, 65536, 8192, 1, 1, 1,
            TileDataType_U64, TileLayout_RowMajor, '1111');
    end;

    SelectExecutionContext(0, 0);
    for pe = 0 to 3 do
        assert TileCapacityInUseForPE(pe) == 262144;
    end;
    AddBundleTileBindingWithReuse(FALSE, 0, 0, '1111',
        TRUE, FALSE, 0, 0, FALSE, TRUE, TRUE);
    FinalizeBundleTileAttempt(TileExecution_Executed);
    assert TileCapacityInUseForPE(0) == 196608;
    assert TileCapacityInUseForPE(1) == 262144;

    ClearBundleHeaderState();
    let started = ExecuteCommandInstruction(PEBankCapacityStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let bound = ExecuteCommandInstruction(PEBankCapacityDestination(), 32);
    assert started == CommandExecution_Executed;
    assert bound == CommandExecution_Executed;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert _Tiles[[16]].allocated;
    assert _Tiles[[16]].capacity_bytes == 65536;
    assert TileCapacityInUseForPE(0) == 262144;
    assert TileCapacityInUseForPE(1) == 262144;

    SelectExecutionContext(0, 1);
    assert !_Tiles[[16]].allocated;
    assert TileCapacityInUseForPE(0) == 262144;
    assert TileCapacityInUseForPE(1) == 262144;
    return 0;
end;
