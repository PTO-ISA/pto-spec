// PTO-INSTRUCTION: {"assembly":["B.IOR [RegSrc0, RegSrc1, RegSrc2],[RegDst]"],"block":[],"catalog_indices":[7],"catalog_records":[{"asm":"B.IOR [RegSrc0, RegSrc1, RegSrc2],[RegDst]","constraints":[{"field":"RegDst","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc0","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc1","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc2","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}],"encoding":[{"index":0,"mask":"0x0600707f","match":"0x00000013","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc0","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc1","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc2","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"b_ior_32_c3ea71404eb3","length_bits":32,"mnemonic":"B.IOR","semantic_family":"CMD","semantic_group":"Bundle Input & Output","semantic_handler":"BindBundleScalarIO","semantic_summary":"Binds encoded scalar inputs and outputs to the current bundle interface.","status":"accepted"}],"classification":["operands"],"mnemonic":"B.IOR","summary":"Binds encoded scalar inputs and outputs to the current bundle interface.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_IOR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_ior_32_c3ea71404eb3);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_B_IOR() => CommandSemanticHandler
begin
    return CommandHandler_BindBundleScalarIO;
end;
// DOC-END: operation
