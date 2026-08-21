// PTO-BLOCK-B-FPATR, PTO-REQ-BUNDLE-STATE-001, PTO-REQ-CUBE-001:
// B.FPATR owns the encoded PostProcessConfig and its bundle lifecycle.

pure func PostProcessTestInstruction(
    pre_quant_mode: bits(6), relu_mode: bits(3), group_n_code: bits(4),
    row_max_enabled: boolean, group_max_enabled: boolean,
    row_max_init: boolean, max_abs_enabled: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00002023;
    instruction[31:26] = pre_quant_mode;
    instruction[25:23] = relu_mode;
    instruction[22:19] = group_n_code;
    instruction[18] = if row_max_enabled then '1' else '0';
    instruction[17] = if group_max_enabled then '1' else '0';
    instruction[16] = if row_max_init then '1' else '0';
    instruction[15] = if max_abs_enabled then '1' else '0';
    return instruction;
end;

pure func PostProcessTestCUBEStart(function: bits(5), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[24:20] = function;
    instruction[31:27] = data_type;
    return instruction;
end;

func TestBundlePostProcessAttributeLifecycle()
begin
    let canonical_none = PostProcessTestInstruction(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    assert canonical_none == Zeros{64} + 0x00002023;

    for mode = 0 to 63 do
        let accepted = mode == 0 || mode == 1 || mode == 2 || mode == 3 ||
            mode == 4 || mode == 5 || mode == 12 || mode == 13 ||
            mode == 16 || mode == 17 || mode == 18 || mode == 19 ||
            mode == 20 || mode == 23 || mode == 24 || mode == 25 ||
            mode == 26 || mode == 27 || mode == 28 || mode == 32 ||
            mode == 33 || mode == 34 || mode == 35 || mode == 36 ||
            mode == 37 || mode == 38 || mode == 39;
        assert PostProcessPreQuantModeAccepted(Zeros{6} + mode) == accepted;
    end;
    for mode = 0 to 7 do
        assert PostProcessReluModeAccepted(Zeros{3} + mode) == (mode <= 3);
    end;
    for code = 0 to 15 do
        assert PostProcessGroupNCodeAccepted(Zeros{4} + code) == (code <= 9);
    end;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let start = ExecuteCommandInstruction(
        PostProcessTestCUBEStart(Zeros{5}, Zeros{5} + 1), 32);
    assert start == CommandExecution_Executed;
    let canonical = ExecuteCommandInstruction(canonical_none, 32);
    assert canonical == CommandExecution_Executed;
    assert BundlePostProcessPresent();
    let postprocess = CurrentBundlePostProcessConfig();
    assert postprocess.pre_quant_mode == Zeros{6};
    assert postprocess.relu_mode == Zeros{3};
    assert postprocess.group_n_code == Zeros{4};
    assert !postprocess.row_max_enabled;
    assert !postprocess.group_max_enabled;
    assert !postprocess.row_max_init;
    assert !postprocess.max_abs_enabled;

    let duplicate = ExecuteCommandInstruction(PostProcessTestInstruction(
        Zeros{6} + 1, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE), 32);
    assert duplicate == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    let preserved_postprocess = CurrentBundlePostProcessConfig();
    assert preserved_postprocess.pre_quant_mode == Zeros{6};

    ResetBundleControlState();
    assert !BundlePostProcessPresent();
end;

func TestBundlePostProcessPresenceAndLegality()
begin
    let canonical = DecodePostProcessConfig(Zeros{32} + 0x00002023);
    assert PostProcessConfigEncodingLegal(canonical);
    assert PostProcessConfigCanonicalNone(canonical);

    let row_max = DecodePostProcessConfig(Zeros{32} + 0x00042023);
    assert PostProcessConfigEncodingLegal(row_max);
    assert !PostProcessConfigCanonicalNone(row_max);

    let reserved_pre_quant = DecodePostProcessConfig(
        Zeros{32} + 0x18002023);
    assert !PostProcessConfigEncodingLegal(reserved_pre_quant);

    let illegal_group_enable = DecodePostProcessConfig(
        Zeros{32} + 0x00022023);
    assert !PostProcessConfigEncodingLegal(illegal_group_enable);

    ResetProfileState();
    assert !BundlePostProcessPresenceLegal(BundleOperation_TileMatrix);
    SetBundlePostProcessAttributeState(canonical);
    assert _LastFault == Fault_None;
    assert BundlePostProcessPresenceLegal(BundleOperation_TileMatrix);
    assert !BundlePostProcessPresenceLegal(BundleOperation_TileElement);
    assert !BundlePostProcessPresenceLegal(BundleOperation_TileMemory);
end;
