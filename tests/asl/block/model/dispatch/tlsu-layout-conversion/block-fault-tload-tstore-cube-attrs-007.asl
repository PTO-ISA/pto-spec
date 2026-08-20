// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-TSTORE-CUBE-ATTRS-007","source":"asl/block/model/dispatch/tlsu-layout-conversion.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001"],"kind":"fault","summary":"CUBE transport requires DTYPE_NONE and zero non-padding data attributes","pass_condition":"all four PadValue encodings are legal while concrete DataType CMode RMode Sat and Canonicalize are independently rejected","related_sources":["asl/block/attributes/B.DATR.asl"]}
pure func CubeAttributeStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00011181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func CubeAttributes(data_type: bits(5), pad: bits(2),
                         c_mode: bits(3), r_mode: bits(3),
                         saturating: boolean,
                         canonicalize: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = data_type;
    instruction[11:7] = Zeros{5} + 22;
    instruction[28:27] = pad;
    instruction[31:29] = c_mode;
    instruction[17:15] = r_mode;
    instruction[26] = if saturating then '1' else '0';
    instruction[25] = if canonicalize then '1' else '0';
    return instruction;
end;

func CubeAttributesLegal(data_type: bits(5), pad: bits(2),
                         c_mode: bits(3), r_mode: bits(3),
                         saturating: boolean,
                         canonicalize: boolean) => boolean
begin
    ResetProfileState();
    let start_status = ExecuteCommandInstruction(CubeAttributeStart(), 32);
    let datr_status = ExecuteCommandInstruction(CubeAttributes(
        data_type, pad, c_mode, r_mode, saturating, canonicalize), 32);
    if start_status != CommandExecution_Executed ||
       datr_status != CommandExecution_Executed then return FALSE; end;
    return BundleCubeTransportDataAttributesLegal();
end;

func main() => integer
begin
    for pad = 0 to 3 do
        let legal = CubeAttributesLegal(
            DTYPE_NONE, Zeros{2} + pad, Zeros{3}, Zeros{3}, FALSE, FALSE);
        assert legal;
    end;
    let concrete = CubeAttributesLegal(
        Zeros{5} + 4, Zeros{2}, Zeros{3}, Zeros{3}, FALSE, FALSE);
    assert !concrete;
    let comparison = CubeAttributesLegal(
        DTYPE_NONE, Zeros{2}, Zeros{3} + 1, Zeros{3}, FALSE, FALSE);
    assert !comparison;
    let rounding = CubeAttributesLegal(
        DTYPE_NONE, Zeros{2}, Zeros{3}, Zeros{3} + 1, FALSE, FALSE);
    assert !rounding;
    let saturating = CubeAttributesLegal(
        DTYPE_NONE, Zeros{2}, Zeros{3}, Zeros{3}, TRUE, FALSE);
    assert !saturating;
    let canonical = CubeAttributesLegal(
        DTYPE_NONE, Zeros{2}, Zeros{3}, Zeros{3}, FALSE, TRUE);
    assert !canonical;
    return 0;
end;
