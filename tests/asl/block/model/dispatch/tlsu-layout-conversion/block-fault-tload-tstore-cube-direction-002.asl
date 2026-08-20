// PTO-TEST: {"id":"PTO-AVS-BLOCK-TLOAD-TSTORE-CUBE-DIRECTION-002","source":"asl/block/model/dispatch/tlsu-layout-conversion.asl","requirements":["PTO-CUBE-CELL-TRANSPORT-001"],"kind":"fault","summary":"Every CUBE Layout code is legal only with its assigned TLOAD or TSTORE direction","pass_condition":"Codes 21 through 23 reject TSTORE and codes 24 through 26 reject TLOAD before operand effects","related_sources":["asl/block/attributes/B.DATR.asl"]}
pure func CubeDirectionStart(load: boolean) => bits(64)
begin
    var instruction: bits(64) = if load then
        Zeros{64} + 0x00011181 else Zeros{64} + 0x00111181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

pure func CubeDirectionAttributes(code: integer {21..26}) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + code;
    return instruction;
end;

func CubeDirectionLegal(load: boolean, code: integer {21..26}) => boolean
begin
    ResetProfileState();
    let start_status = ExecuteCommandInstruction(
        CubeDirectionStart(load), 32);
    let datr_status = ExecuteCommandInstruction(
        CubeDirectionAttributes(code), 32);
    if start_status != CommandExecution_Executed ||
       datr_status != CommandExecution_Executed then return FALSE; end;
    return BundleCubeTransportDataAttributesLegal();
end;

func main() => integer
begin
    for code = 21 to 23 do
        let load_legal = CubeDirectionLegal(
            TRUE, code as integer {21..26});
        assert load_legal;
        let store_legal = CubeDirectionLegal(
            FALSE, code as integer {21..26});
        assert !store_legal;
    end;
    for code = 24 to 26 do
        let load_legal = CubeDirectionLegal(
            TRUE, code as integer {21..26});
        assert !load_legal;
        let store_legal = CubeDirectionLegal(
            FALSE, code as integer {21..26});
        assert store_legal;
    end;
    return 0;
end;
