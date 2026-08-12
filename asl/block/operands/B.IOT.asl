// PTO-INSTRUCTION: {"assembly":["B.IOT SrcTile0, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>","B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOT SrcTile0, mask=PE_MASK, <last>","B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>"],"block":[],"catalog_indices":[8,9,10,11,12],"catalog_records":[{"asm":"B.IOT SrcTile0, mask=PE_MASK, <last>, ->DstTile<TSize>","constraints":[{"field":"PE_MASK","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]},{"field":"TSize","operator":"one-of","values":[1,2,3,4,5,6,7]},{"field":"DstTile","operator":"one-of","values":[0,1,2,3]}],"encoding":[{"index":0,"mask":"0xfc00707f","match":"0x00005013","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcTile0","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"L","pieces":[{"instruction_lsb":19,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"PE_MASK","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4},{"name":"TSize","pieces":[{"instruction_lsb":9,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3},{"name":"DstTile","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"b_iot_32_10db6db84f5d","length_bits":32,"mnemonic":"B.IOT","semantic_family":"CMD","semantic_group":"Bundle Input & Output","semantic_handler":"BindBundleTileIO","semantic_summary":"Binds v5 PE_MASK, ordered Local tile sources, last-use, and optional TSize/2-bit Local destination metadata; reuse bits do not exist.","status":"accepted"},{"asm":"B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>","constraints":[{"field":"PE_MASK","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]}],"encoding":[{"index":0,"mask":"0x00007e7f","match":"0x00004013","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcTile1","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"SrcTile0","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"L","pieces":[{"instruction_lsb":19,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"PE_MASK","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4}],"form_id":"b_iot_32_2c07e7177fad","length_bits":32,"mnemonic":"B.IOT","semantic_family":"CMD","semantic_group":"Bundle Input & Output","semantic_handler":"BindBundleTileIO","semantic_summary":"Binds v5 PE_MASK, ordered Local tile sources, last-use, and optional TSize/2-bit Local destination metadata; reuse bits do not exist.","status":"accepted"},{"asm":"B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>, ->DstTile<TSize>","constraints":[{"field":"PE_MASK","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]},{"field":"TSize","operator":"one-of","values":[1,2,3,4,5,6,7]},{"field":"DstTile","operator":"one-of","values":[0,1,2,3]}],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00004013","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcTile1","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"SrcTile0","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"L","pieces":[{"instruction_lsb":19,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"PE_MASK","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4},{"name":"TSize","pieces":[{"instruction_lsb":9,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3},{"name":"DstTile","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"b_iot_32_8b8bce6bffe8","length_bits":32,"mnemonic":"B.IOT","semantic_family":"CMD","semantic_group":"Bundle Input & Output","semantic_handler":"BindBundleTileIO","semantic_summary":"Binds v5 PE_MASK, ordered Local tile sources, last-use, and optional TSize/2-bit Local destination metadata; reuse bits do not exist.","status":"accepted"},{"asm":"B.IOT SrcTile0, mask=PE_MASK, <last>","constraints":[{"field":"PE_MASK","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]}],"encoding":[{"index":0,"mask":"0xfc007e7f","match":"0x00005013","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcTile0","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"L","pieces":[{"instruction_lsb":19,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"PE_MASK","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4}],"form_id":"b_iot_32_c11eb189dd83","length_bits":32,"mnemonic":"B.IOT","semantic_family":"CMD","semantic_group":"Bundle Input & Output","semantic_handler":"BindBundleTileIO","semantic_summary":"Binds v5 PE_MASK, ordered Local tile sources, last-use, and optional TSize/2-bit Local destination metadata; reuse bits do not exist.","status":"accepted"},{"asm":"B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>","constraints":[{"field":"PE_MASK","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]},{"field":"TSize","operator":"one-of","values":[1,2,3,4,5,6,7]},{"field":"DstTile","operator":"one-of","values":[0,1,2,3]}],"encoding":[{"index":0,"mask":"0xfff0707f","match":"0x00006013","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"L","pieces":[{"instruction_lsb":19,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"PE_MASK","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4},{"name":"TSize","pieces":[{"instruction_lsb":9,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3},{"name":"DstTile","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"b_iot_32_efa0fe3fe49a","length_bits":32,"mnemonic":"B.IOT","semantic_family":"CMD","semantic_group":"Bundle Input & Output","semantic_handler":"BindBundleTileIO","semantic_summary":"Binds a destination-only Local Tile operand with per-PE TSize, PE_MASK, and last-use metadata; PE_MASK=0000 is a strict no-op and there is no mask-only Shared companion form.","status":"accepted"}],"classification":["operands"],"mnemonic":"B.IOT","summary":"Binds v5 PE_MASK, ordered Local tile sources, last-use, and optional TSize/2-bit Local destination metadata; reuse bits do not exist.","surface":"block","id":"PTO-BLOCK-B-IOT","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_IOT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_iot_32_10db6db84f5d) ||
           (operation == CommandOperation_b_iot_32_2c07e7177fad) ||
           (operation == CommandOperation_b_iot_32_8b8bce6bffe8) ||
           (operation == CommandOperation_b_iot_32_c11eb189dd83) ||
           (operation == CommandOperation_b_iot_32_efa0fe3fe49a);
end;
// DOC-END: decode
// DOC-BEGIN: operation
// Complete-bundle matrix consumers use the compact Local stream documented by
// PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA and
// spec/evidence/bundle-command-totality.json: existing mathematical sources,
// optional RowMaxIn, vector QuantParam, vector PReLUParam, then D followed by
// optional RowMaxOut and GroupMaxOut.  The carrier is bounded at eight source
// and three destination ordinals; static operation catalogs remain unchanged.
pure func InstructionContractCompleteBundleLocalSourceCapacity_B_IOT() => integer
begin
    return 8;
end;

pure func InstructionContractCompleteBundleLocalDestinationCapacity_B_IOT() => integer
begin
    return 3;
end;

pure func InstructionContractZeroMaskIsNoOp_B_IOT(
    pe_mask: bits(4)) => boolean
begin
    return pe_mask == Zeros{4};
end;

pure func InstructionContractHasMaskOnlySharedCompanion_B_IOT() => boolean
begin
    return FALSE;
end;

pure func InstructionContractPerPECapacity_B_IOT(
    size_code: integer {1..7}) => integer
begin
    return TileSizeCodeBytes(size_code);
end;

pure func InstructionContractCoreCapacity_B_IOT(
    size_code: integer {1..7}, pe_mask: bits(4)) => integer
begin
    return TileCoreAllocationBytes(pe_mask,
        InstructionContractPerPECapacity_B_IOT(size_code));
end;

readonly func InstructionContractHandler_B_IOT() => CommandSemanticHandler
begin
    return CommandHandler_BindBundleTileIO;
end;
// DOC-END: operation
