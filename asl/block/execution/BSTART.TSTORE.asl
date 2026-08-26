// PTO-INSTRUCTION: {"assembly":["BSTART.TSTORE DataType"],"block":[],"catalog_indices":[50],"catalog_records":[{"asm":"BSTART.TSTORE DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00111181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_tstore_32_4048b6e8b0f4","length_bits":32,"mnemonic":"BSTART.TSTORE","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["Local source: BSTART.TSTORE DataType; optional B.DATR Layout; optional B.DIM; optional B.IOR; exactly one terminating source B.IOT; BSTOP commits.","Shared source: BSTART.TSTORE DataType; optional B.DATR/B.DIM/B.IOR; exactly one source B.IOS with any nonzero consumer PE_MASK; optional B.SUBVIEW selects an explicit per-PE source range; BSTOP commits.","Local CUBE source: Function 1 encodes B.DATR Layout M322ND, M162ND, or N82ND with DataType=DTYPE_NONE; requires LB0=valid columns and LB1=valid rows, omits LB2, and uses one terminating source B.IOT."],"canonical_assembly":["BSTART.TSTORE DataType"],"defaults":["DataType is explicit. Optional B.DATR omission retains the default NORM layout.","For an allocated source, omitted LB0, LB1, and LB2 inherit ValidCol, ValidRow, and physical Col from its descriptor. For a pending Shared source they default to 1, 1, and ValidCol.","An unallocated Shared source derives the smallest legal 128 B through 8 KiB per-PE capacity that contains the completed shape; Rows are then derived from capacity, Col, and DataType. Every selected source element is an undefined-register value and the temporary descriptor is never written back.","Omitted B.IOR supplies base zero. Ordinary forms use resolved Col and CUBE forms use LB0 valid columns to derive dense byte row stride as ceil(columns * element_bits / 8). An explicitly encoded zero selector reads the zero GPR value and therefore supplies a real zero base or zero stride."],"encoding_class":"standalone-encoded","examples":["BSTART.TSTORE U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR a0, a1; B.IOT T1, mask=1111, last; BSTOP","BSTART.TSTORE FP16; B.IOS S7, mask=0011; B.SUBVIEW 0, a0, 0, 7; BSTOP","BSTART.TSTORE FP16; B.IOS S7, mask=1111; BSTOP"],"exceptions":["Reserved DataType, unsupported Layout, invalid dimensions, source descriptor mismatch, malformed bindings, illegal PE mask, unpublished or not-whole-parent-ready Shared source, or GM translation, permission, or alignment fault raises the applicable fault before the first GM write.","A Shared source is hardware-waiting/no-effect until whole-parent readiness and publication are true; undefined Shared payload is not a legal source path."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"DataType":"Encoded zero selects FP64."},"legality":["TSTORE is selected only by TLSU Function 1 and has no standalone opcode. Former independent Shared movement encodings are reserved.","DataType accepts 0..14, 16..20, and 24..28; codes 15, 21..23, and 29..31 are reserved and reject before effects.","The completed block has exactly one source domain. Function 1 accepts one Local B.IOT or one Shared B.IOS. Shared PE_MASK selects participating consumer PEs and does not infer quarters or ranges; B.SUBVIEW carries explicit source geometry.","PE_MASK=0000 is a strict no-op before schema, descriptor, GPR, memory, fault, or source-consumption effects.","ValidCol and ValidRow are nonzero, ValidCol does not exceed physical Col, and the valid rectangle fits the persistent source descriptor."],"memory_effects":["For every selected PE and every selected element in ValidRow x ValidCol, write GM at base + row * row_stride_bytes + column * element_size, with packed four-bit columns adding floor(column / 2) to the byte-strided row base and selecting low/high by column parity.","The complete selected-PE footprint is preflighted before the first GM write, so a fault produces no partial store. After successful preflight individual store beats need not be atomic or ordered to observers."],"operands":[{"field":"DataType","role":"source element data type"},{"field":"B.IOR.RegSrc0","role":"per-PE private-GPR GM base address"},{"field":"B.IOR.RegSrc1","role":"per-PE private-GPR byte row stride"},{"field":"B.DIM.LB0","role":"ordinary ValidCol or CUBE valid columns"},{"field":"B.DIM.LB1","role":"ordinary ValidRow or CUBE valid rows"},{"field":"B.DIM.LB2","role":"ordinary physical Col; forbidden for CUBE conversion"},{"field":"B.IOT/B.IOS","role":"Local or Shared source and participation mask"}],"ordering":["Resolve and validate the complete schema, source descriptor or temporary descriptor, dimensions, masks, per-PE GPR inputs, and every memory access before the first architectural store effect.","Selected Shared-store PEs have no architecture-defined relative issue or commit order; software avoids overlapping GM regions or establishes ordering separately."],"standalone_opcode":true,"state_effects":["Reads one Local or published, whole-parent-ready Shared source without modifying its payload, descriptor, producer mask, readiness, or lifetime.","On success only GM and memory-event state change; the source binding is consumed by normal block completion.","A Shared source that is pending or incomplete causes no payload read and no GM effect."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-TSTORE","mnemonic":"BSTART.TSTORE","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-TSTORE-MEMORY-001
// ndf: kind=contract level=L1 layer=block status=accepted
// TSTORE MUST interpret B.IOR RegSrc1 as a byte row stride, MUST preflight the
// complete selected GM footprint before any store, MUST preserve its Local or
// Shared source, and MUST derive a non-mutating
// minimum-capacity descriptor when a pending Shared source is read.
// Function 1 Shared access MUST accept any nonzero participating PE subset;
// mask zero MUST have no effect.
// NDF-END: PTO-BSTART-TSTORE-MEMORY-001
// NDF-BEGIN: PTO-BSTART-TSTORE-CUBE-001
// ndf: kind=contract level=L1 layer=block status=accepted
// An explicit M322ND, M162ND, or N82ND B.DATR MUST select Local CUBE
// conversion, MUST use the BSTART DataType through DTYPE_NONE, MUST interpret
// LB1 as valid rows and LB0 as valid columns, and MUST reject LB2 or B.IOS.
// NDF-END: PTO-BSTART-TSTORE-CUBE-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_TSTORE(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tstore_32_4048b6e8b0f4);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_TSTORE() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_TSTORE()
    => TileOperation
begin
    return TileOperation_TSTORE;
end;

pure func InstructionContractStartsTileBundle_BSTART_TSTORE()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCubeLayoutLegal_BSTART_TSTORE(
    data_layout: bits(5)) => boolean
begin
    return TileDataLayoutConversionIsStore(data_layout);
end;
// DOC-END: operation
