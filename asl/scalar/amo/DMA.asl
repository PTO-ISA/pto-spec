// PTO-INSTRUCTION: {"assembly":["dma [SrcL], SrcR"],"block":[],"catalog_indices":[89],"catalog_records":[{"asm":"dma [SrcL], SrcR","constraints":[],"encoding":[{"index":0,"mask":"0xfe007fff","match":"0x0000700b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"dma_32_a168aeca5fa5","length_bits":32,"mnemonic":"DMA","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"ExecuteScalarDMACopy64","status":"accepted","semantic_summary":"DMA - Copy the scalar-described 64-bit DMA region."}],"classification":["amo"],"mnemonic":"DMA","summary":"DMA - Copy the scalar-described 64-bit DMA region.","surface":"scalar","id":"PTO-SCALAR-DMA","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_DMA() => ScalarOperation
begin
    return ScalarOperation_DMA;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_DMA() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDMACopy64;
end;
// DOC-END: operation
