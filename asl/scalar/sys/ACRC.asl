// PTO-INSTRUCTION: {"assembly":["acrc rst_type"],"block":[],"catalog_indices":[0],"catalog_records":[{"asm":"acrc rst_type","constraints":[],"encoding":[{"index":0,"mask":"0xff0fffff","match":"0x0000302b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RST_Type","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4}],"form_id":"acrc_32_a9c0e33f9904","length_bits":32,"mnemonic":"ACRC","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ArchitectureCloseRequest","semantic_summary":"ACRC requests context close and marks the final scalar position of the active SYS block.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["ACRC executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["acrc rst_type"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["acrc rst_type"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"RST_Type":"Encoded zero selects value zero of the return-stack record type."},"legality":["Every fixed bit and explicit field constraint is checked before operation semantics.","All four-bit request values are encoded; manager routing and current-ACR permission determine instruction-local acceptance."],"memory_effects":["none"],"operands":[{"field":"RST_Type","role":"return-stack record type"}],"ordering":["Preflight request routing before setting the terminal marker or entering the service-request trap.","On permission success, set the SYS terminal marker before trap entry so recovery preserves the final-position rule."],"standalone_opcode":true,"state_effects":["A permitted request publishes the service-request trap, request type, and architecture-request epoch.","After recovery, only BSTOP or a following BSTART may commit the block; another instruction raises Illegal Block Exception before effects."]},"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS"],"id":"PTO-SCALAR-ACRC","mnemonic":"ACRC","summary":"ACRC requests context close and marks the final scalar position of the active SYS block.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_ACRC()
    => ScalarOperation
begin
    return ScalarOperation_ACRC;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_ACRC()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureCloseRequest;
end;

pure func InstructionContractRequiresSystemBlock_ACRC()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractRequestWidth_ACRC()
    => integer {4}
begin
    return 4;
end;

pure func InstructionContractIsTerminalScalar_ACRC()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
