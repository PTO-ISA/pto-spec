// PTO-INSTRUCTION: {"assembly":["BSTART.TEPL Mode, Function, DataType"],"block":[],"catalog_indices":[33],"catalog_records":[{"accepted_assembly_mnemonics":["BSTART.TEPL","BSTART.VEC","BSTART.SFU"],"asm":"BSTART.TEPL Mode, Function, DataType","canonical_assembly_by_engine":{"SFU":"BSTART.SFU","VEC":"BSTART.VEC"},"carrier_mnemonic":"BSTART.TEPL","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x000fffff","match":"0x00019181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"Mode","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"Function","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_tepl_32_d022db6dacb3","length_bits":32,"mnemonic":"BSTART.TEPL","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.TEPL is the unchanged Mode:Function carrier. It retires any active predecessor, installs one Tile-element block descriptor, and accepts either the VEC or SFU operation assigned to that selector.","BSTART.TEPL remains accepted compatibility input, but canonical assembly and disassembly select BSTART.VEC or BSTART.SFU from the operation's execution engine."],"canonical_assembly":["BSTART.TEPL Mode, Function, DataType"],"defaults":["No operand field is omitted; every encoded field has the value carried by the selected form."],"encoding_class":"standalone-encoded","examples":["BSTART.TEPL 0, 0, FP32"],"exceptions":["Reserved DataType codes, unassigned Mode:Function selectors, non-TEPL operations, or invalid descriptors raise before predecessor retirement or new BARG effects.","An accepted selector whose operation is not assigned to VEC or SFU is illegal for this carrier."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"DataType":"Encoded zero selects FP64."},"legality":["Mode:Function is a seven-bit selector with Mode in bits 6:5 and Function in bits 4:0.","Only assigned TEPL-carried operations are legal; unassigned selector holes reject before effects.","DataType accepts 0..14, 16..20, and 24..28; 15, 21..23, and 29..31 are reserved.","BSTART.TEPL is compatibility input only; canonical output uses the operation's VEC or SFU alias."],"memory_effects":["none"],"operands":[{"field":"DataType","role":"tile element data type selector"},{"field":"Mode","role":"execution mode selector"},{"field":"Function","role":"tile operation function selector"}],"ordering":["Carrier field, selector, operation, engine, and descriptor legality precede predecessor retirement and BARG publication."],"standalone_opcode":true,"state_effects":["After successful predecessor retirement, installs the selected Tile-element descriptor and a BARG whose BlockType denotes the Tile-element block.","The selected operation executes only when BSTOP or the next BSTART commits the completed block."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING","PTO-ARCH-OVERVIEW-INSTRUCTION-CLASSIFICATION"],"id":"PTO-BLOCK-BSTART-TEPL","mnemonic":"BSTART.TEPL","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_TEPL(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tepl_32_d022db6dacb3);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_TEPL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

pure func InstructionContractAcceptsEngineAlias_BSTART_TEPL(
    engine: TileExecutionEngine) => boolean
begin
    return TileEngineHasCanonicalBundleStartAlias(engine);
end;

pure func InstructionContractAcceptsTileOperation_BSTART_TEPL(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileTEPLAliasAcceptsOperation(TileTEPLAlias_TEPL, operation);
end;
// DOC-END: operation
