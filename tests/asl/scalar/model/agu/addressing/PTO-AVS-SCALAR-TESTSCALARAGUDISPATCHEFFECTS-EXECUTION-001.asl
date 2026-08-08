// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-TESTSCALARAGUDISPATCHEFFECTS-EXECUTION-001","source":"asl/scalar/model/agu/addressing.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for TestScalarAGUDispatchEffects","pass_condition":"TestScalarAGUDispatchEffects completes without assertion failure","related_sources":[]}
func TestScalarAGUDispatchEffects()
begin
    ClearFault();
    WriteGPR(2, Zeros{PTO_XLEN} + 512);
    WriteGPR(3, Zeros{PTO_XLEN} + 1);
    WriteMemoryByte(Zeros{PTO_XLEN} + 516, Zeros{8} + 0x80);
    var register_load: bits(48) = Zeros{48} + 0x00000009;
    register_load[11:7] = Zeros{5} + 5;
    register_load[19:15] = Zeros{5} + 2;
    register_load[24:20] = Zeros{5} + 3;
    register_load[31:27] = Zeros{5} + 2;
    let register_load_status = ExecuteScalarInstruction(register_load, 32);
    assert register_load_status == ScalarExecution_Executed;
    assert ReadGPR(5) == SignExtend{PTO_XLEN}(Zeros{8} + 0x80);

    WriteGPR(2, Zeros{PTO_XLEN} + 520);
    Store(Zeros{PTO_XLEN} + 524, 2, Zeros{PTO_XLEN} + 0x8001);
    var scaled_immediate_load: bits(48) = Zeros{48} + 0x00001019;
    scaled_immediate_load[11:7] = Zeros{5} + 6;
    scaled_immediate_load[19:15] = Zeros{5} + 2;
    scaled_immediate_load[31:20] = Zeros{12} + 2;
    let scaled_load_status =
        ExecuteScalarInstruction(scaled_immediate_load, 32);
    assert scaled_load_status == ScalarExecution_Executed;
    assert ReadGPR(6) == SignExtend{PTO_XLEN}(Zeros{16} + 0x8001);

    Store(Zeros{PTO_XLEN} + 522, 2, Zeros{PTO_XLEN} + 0x1234);
    var unscaled_immediate_load: bits(48) = Zeros{48} + 0x00001029;
    unscaled_immediate_load[11:7] = Zeros{5} + 7;
    unscaled_immediate_load[19:15] = Zeros{5} + 2;
    unscaled_immediate_load[31:20] = Zeros{12} + 2;
    let unscaled_load_status =
        ExecuteScalarInstruction(unscaled_immediate_load, 32);
    assert unscaled_load_status == ScalarExecution_Executed;
    assert ReadGPR(7) == Zeros{PTO_XLEN} + 0x1234;

    WritePC(Zeros{PTO_XLEN} + 600);
    WriteMemoryByte(Zeros{PTO_XLEN} + 604, Zeros{8} + 0x7f);
    var pc_relative_load: bits(48) = Zeros{48} + 0x00000039;
    pc_relative_load[11:7] = Zeros{5} + 8;
    pc_relative_load[31:15] = Zeros{17} + 1;
    let pc_relative_status = ExecuteScalarInstruction(pc_relative_load, 32);
    assert pc_relative_status == ScalarExecution_Executed;
    assert ReadGPR(8) == Zeros{PTO_XLEN} + 0x7f;

    WriteGPR(2, Zeros{PTO_XLEN} + 620);
    Store(Zeros{PTO_XLEN} + 624, 4, Zeros{PTO_XLEN} + 0x80000002);
    var compressed_load: bits(48) = Zeros{48} + 0x000a;
    compressed_load[10:6] = Zeros{5} + 2;
    compressed_load[15:11] = Zeros{5} + 1;
    let compressed_load_status = ExecuteScalarInstruction(compressed_load, 16);
    assert compressed_load_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) ==
        SignExtend{PTO_XLEN}(Zeros{32} + 0x80000002);

    WriteGPR(2, Zeros{PTO_XLEN} + 640);
    WriteGPR(3, Zeros{PTO_XLEN} + 2);
    Store(Zeros{PTO_XLEN} + 648, 4, Zeros{PTO_XLEN} + 0x80000003);
    var register_preload: bits(48) = Zeros{48} + 0x00002009002e;
    register_preload[27:23] = Zeros{5} + 9;
    register_preload[15:11] = Zeros{5} + 10;
    register_preload[35:31] = Zeros{5} + 2;
    register_preload[40:36] = Zeros{5} + 3;
    register_preload[47:43] = Zeros{5} + 2;
    let register_preload_status =
        ExecuteScalarInstruction(register_preload, 48);
    assert register_preload_status == ScalarExecution_Executed;
    assert ReadGPR(9) == SignExtend{PTO_XLEN}(Zeros{32} + 0x80000003);
    assert ReadGPR(10) == Zeros{PTO_XLEN} + 648;

    WriteGPR(2, Zeros{PTO_XLEN} + 660);
    Store(Zeros{PTO_XLEN} + 660, 4, Zeros{PTO_XLEN} + 0x44556677);
    var immediate_postload: bits(48) = Zeros{48} + 0x00002029003e;
    immediate_postload[27:23] = Zeros{5} + 11;
    immediate_postload[15:11] = Zeros{5} + 12;
    immediate_postload[35:31] = Zeros{5} + 2;
    immediate_postload[47:36] = Zeros{12} + 4;
    let immediate_postload_status =
        ExecuteScalarInstruction(immediate_postload, 48);
    assert immediate_postload_status == ScalarExecution_Executed;
    assert ReadGPR(11) == Zeros{PTO_XLEN} + 0x44556677;
    assert ReadGPR(12) == Zeros{PTO_XLEN} + 664;

    WriteGPR(2, Zeros{PTO_XLEN} + 680);
    Store(Zeros{PTO_XLEN} + 684, 4, Zeros{PTO_XLEN} + 0x11111111);
    Store(Zeros{PTO_XLEN} + 688, 4, Zeros{PTO_XLEN} + 0x22222222);
    var pair_load: bits(48) = Zeros{48} + 0x00002029001e;
    pair_load[27:23] = Zeros{5} + 13;
    pair_load[15:11] = Zeros{5} + 14;
    pair_load[35:31] = Zeros{5} + 2;
    pair_load[47:36] = Zeros{12} + 4;
    let pair_load_status = ExecuteScalarInstruction(pair_load, 48);
    assert pair_load_status == ScalarExecution_Executed;
    assert ReadGPR(13) == Zeros{PTO_XLEN} + 0x11111111;
    assert ReadGPR(14) == Zeros{PTO_XLEN} + 0x22222222;

    WriteGPR(2, Zeros{PTO_XLEN} + 704);
    WriteGPR(3, Zeros{PTO_XLEN} + 2);
    WriteGPR(4, Zeros{PTO_XLEN} + 0x11223344);
    var scaled_store: bits(48) = Zeros{48} + 0x00002049;
    scaled_store[31:27] = Zeros{5} + 4;
    scaled_store[19:15] = Zeros{5} + 2;
    scaled_store[24:20] = Zeros{5} + 3;
    let scaled_store_status = ExecuteScalarInstruction(scaled_store, 32);
    assert scaled_store_status == ScalarExecution_Executed;
    let scaled_store_value = LoadUnsigned(Zeros{PTO_XLEN} + 712, 4);
    assert scaled_store_value == Zeros{PTO_XLEN} + 0x11223344;

    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    WriteGPR(4, Zeros{PTO_XLEN} + 0x55667788);
    var unscaled_store: bits(48) = Zeros{48} + 0x00006049;
    unscaled_store[31:27] = Zeros{5} + 4;
    unscaled_store[19:15] = Zeros{5} + 2;
    unscaled_store[24:20] = Zeros{5} + 3;
    let unscaled_store_status = ExecuteScalarInstruction(unscaled_store, 32);
    assert unscaled_store_status == ScalarExecution_Executed;
    let unscaled_store_value = LoadUnsigned(Zeros{PTO_XLEN} + 708, 4);
    assert unscaled_store_value == Zeros{PTO_XLEN} + 0x55667788;

    WriteGPR(2, Zeros{PTO_XLEN} + 720);
    WriteGPR(4, Zeros{PTO_XLEN} + 0xaabbccdd);
    var immediate_prestore: bits(48) = Zeros{48} + 0x00002059002e;
    immediate_prestore[15:11] = Zeros{5} + 15;
    immediate_prestore[35:31] = Zeros{5} + 4;
    immediate_prestore[40:36] = Zeros{5} + 2;
    immediate_prestore[47:41] = Zeros{7} + 2;
    let immediate_prestore_status =
        ExecuteScalarInstruction(immediate_prestore, 48);
    assert immediate_prestore_status == ScalarExecution_Executed;
    assert ReadGPR(15) == Zeros{PTO_XLEN} + 728;
    let immediate_prestore_value = LoadUnsigned(Zeros{PTO_XLEN} + 728, 4);
    assert immediate_prestore_value == Zeros{PTO_XLEN} + 0xaabbccdd;

    WriteGPR(2, Zeros{PTO_XLEN} + 736);
    WriteGPR(4, Zeros{PTO_XLEN} + 0x01020304);
    WriteGPR(5, Zeros{PTO_XLEN} + 0x05060708);
    var pair_store: bits(48) = Zeros{48} + 0x00006059001e;
    pair_store[35:31] = Zeros{5} + 4;
    pair_store[10:6] = Zeros{5} + 5;
    pair_store[40:36] = Zeros{5} + 2;
    pair_store[47:41] = Zeros{7} + 4;
    let pair_store_status = ExecuteScalarInstruction(pair_store, 48);
    assert pair_store_status == ScalarExecution_Executed;
    let pair_store_first = LoadUnsigned(Zeros{PTO_XLEN} + 740, 4);
    let pair_store_second = LoadUnsigned(Zeros{PTO_XLEN} + 744, 4);
    assert pair_store_first == Zeros{PTO_XLEN} + 0x01020304;
    assert pair_store_second == Zeros{PTO_XLEN} + 0x05060708;

    WriteGPR(2, Zeros{PTO_XLEN} + 760);
    WriteGPR(3, Zeros{PTO_XLEN} + 3);
    var prefetch_address: bits(48) = Zeros{48} + 0x00007009001e;
    prefetch_address[27:23] = Zeros{5} + 16;
    prefetch_address[35:31] = Zeros{5} + 2;
    prefetch_address[40:36] = Zeros{5} + 3;
    prefetch_address[15:11] = Zeros{5} + 5;
    prefetch_address[47:43] = Zeros{5} + 2;
    let prefetch_status = ExecuteScalarInstruction(prefetch_address, 48);
    assert prefetch_status == ScalarExecution_Executed;
    assert ReadGPR(16) == Zeros{PTO_XLEN} + 772;
    assert _LastFault == Fault_None;
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarAGUDispatchEffects();
    return 0;
end;
