// PTO-INSTRUCTION: {"assembly":["B.DATR {layout, datatype, padvalue_or_byteid, cmode, rmode, sat, canonicalize}"],"block":[],"catalog_indices":[1],"catalog_records":[{"asm":"B.DATR {layout, datatype, padvalue_or_byteid, cmode, rmode, sat, canonicalize}","constraints":[{"field":"CMode","operator":"one-of","values":[0,1,2,3,4,5]},{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]},{"field":"Layout","operator":"one-of","values":[0,1,3,4,6,8,9,17,18,20,27,28,30]}],"encoding":[{"index":0,"mask":"0x000c707f","match":"0x00001023","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"CMode","pieces":[{"instruction_lsb":29,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3},{"name":"PadValueOrByteId","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"Sat","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"Canonicalize","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"DataType","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RMode","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3},{"name":"Layout","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"b_datr_32_c161a042ff38","length_bits":32,"mnemonic":"B.DATR","semantic_family":"CMD","semantic_group":"Bundle Data Attribute","semantic_handler":"SetBundleDataAttributes","semantic_summary":"Latches tile layout, data type, padding, conversion, rounding, and saturation attributes.","status":"accepted"}],"classification":["attributes"],"mnemonic":"B.DATR","summary":"Latches tile layout, data type, padding, conversion, rounding, and saturation attributes.","surface":"block","id":"PTO-BLOCK-B-DATR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_DATR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_datr_32_c161a042ff38);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_B_DATR() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleDataAttributes;
end;
// DOC-END: operation
