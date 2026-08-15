// PTO-INSTRUCTION: {"assembly":["acre rra_type"],"block":[],"catalog_indices":[1],"catalog_records":[{"asm":"acre rra_type","constraints":[{"field":"RRA_Type","operator":"one-of","values":[0,1]}],"encoding":[{"index":0,"mask":"0xff0fffff","match":"0x0100302b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RRA_Type","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4}],"form_id":"acre_32_54b80944d32d","length_bits":32,"mnemonic":"ACRE","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ArchitectureEnterRequest","semantic_summary":"ACRE atomically commits the active SYS block and recovers one validated architecture context.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["ACRE executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["acre rra_type"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["acre rra_type"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"RRA_Type":"Encoded zero selects value zero of the return-address record type."},"legality":["Request values 0 and 1 are exact aliases; values 2 through 15 are reserved.","ACRE is the implicit stop and terminating scalar instruction of the active SYS block."],"memory_effects":["none"],"operands":[{"field":"RRA_Type","role":"return-address record type"}],"ordering":["Validate the complete recovery context without mutation before committing the current SYS block.","Commit the block successfully, then consume and restore the saved context atomically."],"standalone_opcode":true,"state_effects":["On success, retire the SYS block, restore the complete validated context, consume its validity, record the request type, and increment the request epoch.","Failed validation or commit preserves the saved context and performs no partial recovery."]},"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS"],"id":"PTO-SCALAR-ACRE","mnemonic":"ACRE","summary":"ACRE atomically commits the active SYS block and recovers one validated architecture context.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_ACRE()
    => ScalarOperation
begin
    return ScalarOperation_ACRE;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_ACRE()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureEnterRequest;
end;

pure func InstructionContractRequiresSystemBlock_ACRE()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractRequestTypeLegal_ACRE(
    request_type: bits(4)) => boolean
begin
    return request_type == '0000' || request_type == '0001';
end;

pure func InstructionContractIsImplicitBlockStop_ACRE()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
