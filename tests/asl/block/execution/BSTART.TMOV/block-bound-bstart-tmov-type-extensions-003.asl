// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-TMOV-TYPE-EXTENSIONS-003","source":"asl/block/execution/BSTART.TMOV.asl","requirements":["PTO-INST-BLOCK-BSTART-TMOV"],"kind":"boundary","summary":"BSTART.TMOV admits E6M2 and RCPE6M2 while retaining reserved type codes","pass_condition":"DataType 15 and 21 decode and start canonical BSTART.TMOV, while 22, 23, 29, and 30 reject before opening a bundle","related_sources":["asl/arch/data-types/tile-data-types.asl"]}
pure func BSTARTTMOVTypeWord(data_type: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00211181;
    instruction[31:27] = data_type;
    return instruction;
end;

func ExpectAcceptedBSTARTTMOVType(data_type: bits(5))
begin
    ResetProfileState();
    let instruction = BSTARTTMOVTypeWord(data_type);
    let form = DecodeCommandForm(instruction, 32);
    let form_index = form as integer {0..PTO_COMMAND_FORM_COUNT-1};
    assert form == 47 && CommandOperandPresent(form_index, CommandField_DataType) &&
           UInt(DecodeCommandOperandRaw(instruction, form_index,
               CommandField_DataType)[4:0]) == UInt(data_type);
    let status = ExecuteCommandInstruction(instruction, 32);
    assert status == CommandExecution_Executed &&
           _LastFault == Fault_None && _BundleActive &&
           _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector[4:0] == Zeros{5} + 2;
end;

func ExpectRejectedBSTARTTMOVType(data_type: bits(5))
begin
    ResetProfileState();
    let instruction = BSTARTTMOVTypeWord(data_type);
    assert DecodeCommandForm(instruction, 32) == 47;
    let status = ExecuteCommandInstruction(instruction, 32);
    assert status == CommandExecution_Rejected &&
           _LastFault == Fault_IllegalInstruction && !_BundleActive;
end;

func main() => integer
begin
    ExpectAcceptedBSTARTTMOVType(Zeros{5} + 15);
    ExpectAcceptedBSTARTTMOVType(Zeros{5} + 21);
    ExpectRejectedBSTARTTMOVType(Zeros{5} + 22);
    ExpectRejectedBSTARTTMOVType(Zeros{5} + 23);
    ExpectRejectedBSTARTTMOVType(Zeros{5} + 29);
    ExpectRejectedBSTARTTMOVType(Zeros{5} + 30);
    return 0;
end;
