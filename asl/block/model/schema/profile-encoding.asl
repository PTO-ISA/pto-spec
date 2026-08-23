// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING","surface":"block","classification":["model","schema","profile-encoding"],"depends_on":["PTO-ARCH-PROFILE-REFERENCE-PROFILE"],"catalog_projection":{"catalog":"command-forms","isa":"PTO Instruction Set Architecture","reviewed_encoding_overlaps":[{"broad_form_id":"b_iot_32_10db6db84f5d","narrow_form_id":"b_iot_32_c11eb189dd83","reason":"source-only form fixes SizeCode to zero; destination form requires SizeCode 1..12 and a 2-bit DstTile"},{"broad_form_id":"b_iot_32_8b8bce6bffe8","narrow_form_id":"b_iot_32_2c07e7177fad","reason":"source-only form fixes SizeCode to zero; destination form requires SizeCode 1..12 and a 2-bit DstTile"},{"broad_form_id":"c_bstart_std_16_8b40f078c14a","narrow_form_id":"c_bstop_16_ca4743d8a95e","reason":"C.BSTOP fixes the broad C.BSTART.STD BrType field to excluded value 0"}],"schema_version":2,"surface":"command-and-boundary"}}
pure func PTOv0BundleKindCode(kind: BundleKind) => bits(4)
begin
    case kind of
        when BundleKind_Standard => return '0000';
        when BundleKind_Floating => return '0001';
        when BundleKind_System => return '0010';
        when BundleKind_TileElement => return '0101';
        when BundleKind_TileMemory => return '0110';
        when BundleKind_TileMatrix => return '0111';
        when BundleKind_FrameTemplate => return '1000';
    end;
end;

pure func PTOv0BundleKindOf(code: bits(4)) => BundleKind
begin
    if code == '0001' then return BundleKind_Floating;
    elsif code == '0010' then return BundleKind_System;
    elsif code == '0101' then return BundleKind_TileElement;
    elsif code == '0110' then return BundleKind_TileMemory;
    elsif code == '0111' then return BundleKind_TileMatrix;
    elsif code == '1000' then return BundleKind_FrameTemplate;
    else return BundleKind_Standard;
    end;
end;

pure func PTOv0PEMaskOfPEMode(mode: bits(3)) => bits(4)
begin
    case mode of
        when '000' => return '0000';
        when '001' => return '1000';
        when '010' => return '0100';
        when '011' => return '0010';
        when '100' => return '0001';
        when '101' => return '1100';
        when '110' => return '1110';
        when '111' => return '1111';
    end;
end;

pure func PTOv0BundleTransferCode(transfer: BundleTransfer) => bits(3)
begin
    case transfer of
        when BundleTransfer_Fallthrough => return '000';
        when BundleTransfer_Direct => return '001';
        when BundleTransfer_Conditional => return '010';
        when BundleTransfer_Call => return '011';
        when BundleTransfer_Return => return '100';
        when BundleTransfer_Indirect => return '101';
        when BundleTransfer_IndirectCall => return '110';
    end;
end;

pure func PTOv0BundleTransferOf(code: bits(3)) => BundleTransfer
begin
    if code == '001' then return BundleTransfer_Direct;
    elsif code == '010' then return BundleTransfer_Conditional;
    elsif code == '011' then return BundleTransfer_Call;
    elsif code == '100' then return BundleTransfer_Return;
    elsif code == '101' then return BundleTransfer_Indirect;
    elsif code == '110' then return BundleTransfer_IndirectCall;
    else return BundleTransfer_Fallthrough;
    end;
end;

pure func PTOv0EBARGControlLegal(control: Word) => boolean
begin
    let kind_code = UInt(control[10:7]);
    return control[63:15] == Zeros{49} &&
           (kind_code <= 2 || (kind_code >= 5 && kind_code <= 8)) &&
           UInt(control[13:11]) <= 6 &&
           (control[6] == '0' || control[5] == '1');
end;
