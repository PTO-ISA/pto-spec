// PTO-BLOCK-B-FPATR: the encoded PostProcessConfig owned by B.FPATR.
// This unit fixes field decoding and structural legality. Exact FP19 and
// target numerical results remain behind the selected numeric profile.

type PostProcessConfig of record {
    pre_quant_mode: bits(6),
    relu_mode: bits(3),
    group_n_code: bits(4),
    row_max_enabled: boolean,
    group_max_enabled: boolean,
    row_max_init: boolean,
    max_abs_enabled: boolean
};

pure func DecodePostProcessConfig(instruction: bits(32))
        => PostProcessConfig
begin
    return PostProcessConfig {
        pre_quant_mode = instruction[31:26],
        relu_mode = instruction[25:23],
        group_n_code = instruction[22:19],
        row_max_enabled = instruction[18] == '1',
        group_max_enabled = instruction[17] == '1',
        row_max_init = instruction[16] == '1',
        max_abs_enabled = instruction[15] == '1'
    };
end;

pure func PostProcessPreQuantModeAccepted(mode: bits(6)) => boolean
begin
    let code = UInt(mode);
    return code == 0 || code == 1 || code == 2 || code == 3 ||
           code == 4 || code == 5 || code == 12 || code == 13 ||
           code == 16 || code == 17 || code == 18 || code == 19 ||
           code == 20 || code == 23 || code == 24 || code == 25 ||
           code == 26 || code == 27 || code == 28 || code == 32 ||
           code == 33 || code == 34 || code == 35 || code == 36 ||
           code == 37 || code == 38 || code == 39;
end;

pure func PostProcessReluModeAccepted(mode: bits(3)) => boolean
begin
    return UInt(mode) <= 3;
end;

pure func PostProcessGroupNCodeAccepted(code: bits(4)) => boolean
begin
    return UInt(code) <= 9;
end;

pure func PostProcessConfigEncodingLegal(postprocess: PostProcessConfig)
        => boolean
begin
    if !PostProcessPreQuantModeAccepted(postprocess.pre_quant_mode) ||
       !PostProcessReluModeAccepted(postprocess.relu_mode) ||
       !PostProcessGroupNCodeAccepted(postprocess.group_n_code) then
        return FALSE;
    end;
    if postprocess.group_max_enabled then
        if postprocess.group_n_code == Zeros{4} then return FALSE; end;
    elsif postprocess.group_n_code != Zeros{4} then
        return FALSE;
    end;
    if postprocess.row_max_init && !postprocess.row_max_enabled then
        return FALSE;
    end;
    if postprocess.max_abs_enabled &&
       !postprocess.row_max_enabled && !postprocess.group_max_enabled then
        return FALSE;
    end;
    return TRUE;
end;

pure func PostProcessConfigCanonicalNone(postprocess: PostProcessConfig)
        => boolean
begin
    return postprocess.pre_quant_mode == Zeros{6} &&
           postprocess.relu_mode == Zeros{3} &&
           postprocess.group_n_code == Zeros{4} &&
           !postprocess.row_max_enabled &&
           !postprocess.group_max_enabled &&
           !postprocess.row_max_init &&
           !postprocess.max_abs_enabled;
end;

pure func PostProcessGroupN(postprocess: PostProcessConfig)
        => integer {0,8,16,32,48,64,80,96,112,128}
begin
    case postprocess.group_n_code of
        when '0000' => return 0;
        when '0001' => return 8;
        when '0010' => return 16;
        when '0011' => return 32;
        when '0100' => return 48;
        when '0101' => return 64;
        when '0110' => return 80;
        when '0111' => return 96;
        when '1000' => return 112;
        when '1001' => return 128;
        otherwise => unreachable;
    end;
end;
