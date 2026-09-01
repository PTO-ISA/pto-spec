// PTO-INSTRUCTION: {"assembly":["BSTART.RED.DEC DataType"],"block":["BSTART.RED.DEC DataType","B.DIM LB0=ValidCol","B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"catalog_indices":[89],"catalog_records":[{"asm":"BSTART.RED.DEC DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x01711181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_red_dec_32_gm23","length_bits":32,"mnemonic":"BSTART.RED.DEC","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Starts GM indexed red.dec operation.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.RED.DEC DataType","B.DIM LB0=ValidCol","B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"canonical_assembly":["BSTART.RED.DEC DataType"],"defaults":["PE_MASK=0000 is a strict no-effect case; B.IOR and valid dimensions are required otherwise."],"encoding_class":"standalone-encoded","examples":["BSTART.RED.DEC DataType"],"exceptions":["Reserved DataTypes fault IllegalInstruction; unsupported operation/type tuples fault TileLegality; access faults are preflighted."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"DataType":"Encoded zero is interpreted by the selected operation."},"legality":["GM-only operation; Shared and vector forms are excluded."],"memory_effects":["Complete preflight precedes atomic effects."],"operands":[{"field":"DataType","role":"GM operation type"}],"ordering":["Duplicate effective addresses serialize in implementation-defined order."],"standalone_opcode":true,"state_effects":["Opens a complete GM indexed block."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-RED-DEC","mnemonic":"BSTART.RED.DEC","summary":"Starts GM indexed red.dec operation.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_RED_DEC(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_red_dec_32_gm23);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_RED_DEC() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_RED_DEC()
    => TileOperation
begin
    return TileOperation_RED_DEC;
end;

pure func InstructionContractStartsTileBundle_BSTART_RED_DEC()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
