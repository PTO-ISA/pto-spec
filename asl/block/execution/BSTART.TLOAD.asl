// PTO-INSTRUCTION: {"assembly":["BSTART.TLOAD DataType"],"block":[],"catalog_indices":[40],"catalog_records":[{"asm":"BSTART.TLOAD DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00011181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_tload_32_d0c18bb0ab15","length_bits":32,"mnemonic":"BSTART.TLOAD","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["Local destination: BSTART.TLOAD DataType; optional B.DATR Layout; B.DIM supplies ValidCol, ValidRow, and physical Col; optional B.IOR supplies per-PE base and byte row stride; exactly one terminating destination B.IOT allocates the Local result; BSTOP commits.","Shared destination: replace destination B.IOT with one destination B.IOS naming S0..S255, TSize, and PE_MASK. Each selected quarter uses that PE's private GPR base and stride.","Local CUBE destination: encode B.DATR Layout ND2M32, ND2M16, or ND2N8 with DataType=DTYPE_NONE; require LB0=valid columns and LB1=valid rows, omit LB2, and use one terminating destination B.IOT."],"canonical_assembly":["BSTART.TLOAD DataType"],"defaults":["DataType is explicit. Optional B.DATR omission retains the default NORM layout.","LB0/ValidCol and LB1/ValidRow default through the common destination-shape contract; omitted LB2/Col defaults to ValidCol. Rows are derived from TSize, Col, and DataType and must be at least ValidRow.","Omitted B.IOR supplies base zero. Ordinary forms use resolved Col and CUBE forms use LB0 valid columns to derive dense byte row stride as ceil(columns * element_bits / 8). An explicitly encoded zero selector reads the zero GPR value and therefore supplies a real zero base or zero stride."],"encoding_class":"standalone-encoded","examples":["BSTART.TLOAD U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR zero, a0; B.IOT mask=1111, ->T<1>; BSTOP","BSTART.TLOAD FP16; B.DIM LB0, 32; B.DIM LB1, 4; B.IOS mask=0011, ->S7<1>; BSTOP","BSTART.TLOAD FP16; B.DATR {ND2M16, DTYPE_NONE, Null, EQ, Default, 0, 0}; B.DIM LB0=K; B.DIM LB1=M; B.IOT mask=1111, <last>, ->M<1>; BSTOP"],"exceptions":["Reserved DataType, unsupported Layout, invalid dimensions, capacity/shape overflow, inconsistent or illegal PE masks, malformed binding schema, allocation failure, or memory translation/permission/alignment fault rejects before destination publication.","The complete selected-PE footprint is preflighted before any Local or Shared destination payload or descriptor becomes visible."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"DataType":"Encoded zero selects FP64."},"legality":["DataType accepts 0..14, 16..20, and 24..28; all other codes are reserved before effects.","Exactly one destination domain is used: a terminating destination B.IOT for Local or one destination B.IOS for Shared. Source Tile bindings and mixed Local/Shared destinations are illegal.","ValidCol and ValidRow must be nonzero and no greater than derived physical Col and Rows; Col and Rows are powers of two under the common Tile descriptor contract.","PE_MASK=0000 is a strict no-op before GPR reads, allocation, memory access, faults, or descriptor changes.","CUBE conversion accepts only Layout codes 21 through 23, requires explicit DTYPE_NONE, explicit nonzero LB0/LB1, absent LB2, one Local destination B.IOT, a supported non-64-bit non-HiF4X2 dtype, and no B.IOS."],"memory_effects":["For every selected PE and every element in ValidRow x ValidCol, read GM at base + row * row_stride_bytes + column * element_size, with packed four-bit columns adding floor(column / 2) to the byte-strided row base and selecting low/high by column parity.","All accesses participate in PTO-TSO with the block's aq/rl attributes and are precise and restartable."],"operands":[{"field":"DataType","role":"destination element data type"},{"field":"B.IOR.RegSrc0","role":"per-PE private-GPR GM base address"},{"field":"B.IOR.RegSrc1","role":"per-PE private-GPR byte row stride"},{"field":"B.DIM.LB0","role":"ordinary ValidCol or CUBE valid columns"},{"field":"B.DIM.LB1","role":"ordinary ValidRow or CUBE valid rows"},{"field":"B.DIM.LB2","role":"ordinary physical Col; forbidden for CUBE conversion"},{"field":"B.IOT/B.IOS","role":"Local or Shared destination, per-PE TSize, and participation mask"}],"ordering":["Resolve and validate the full schema, dimensions, masks, per-PE GPR inputs, destination allocation, and complete memory footprint before the first architectural load effect.","On success publish the complete destination atomically at block commit; on failure preserve prior destination and block-visible state for restart."],"standalone_opcode":true,"state_effects":["Allocates/renames one Local destination or reallocates the named Shared destination with Rows derived from TSize, Col, and DataType, then fills selected valid elements and marks their definedness.","Unselected PE regions remain unchanged for Shared partial-mask updates; a Local result is published through its architectural destination hand only after successful commit.","A successful CUBE form installs a persistent Matrix-location descriptor with CELL geometry derived from Layout, BSTART DataType, LB1 valid rows, and LB0 valid columns; TSize remains capacity only."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-TLOAD","mnemonic":"BSTART.TLOAD","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-TLOAD-MEMORY-001
// ndf: kind=contract level=L1 layer=block status=accepted
// TLOAD MUST retain B.IOR RegSrc0 as the per-PE GM base and RegSrc1 as the
// byte row stride, MUST preflight the complete selected footprint,
// and MUST publish its Local or Shared destination only after success.
// NDF-END: PTO-BSTART-TLOAD-MEMORY-001
// NDF-BEGIN: PTO-BSTART-TLOAD-CUBE-001
// ndf: kind=contract level=L1 layer=block status=accepted
// An explicit ND2M32, ND2M16, or ND2N8 B.DATR MUST select Local CUBE
// conversion, MUST use the BSTART DataType through DTYPE_NONE, MUST interpret
// LB1 as valid rows and LB0 as valid columns, and MUST reject LB2 or B.IOS.
// NDF-END: PTO-BSTART-TLOAD-CUBE-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_TLOAD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tload_32_d0c18bb0ab15);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_TLOAD() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_TLOAD()
    => TileOperation
begin
    return TileOperation_TLOAD;
end;

pure func InstructionContractStartsTileBundle_BSTART_TLOAD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCubeLayoutLegal_BSTART_TLOAD(
    data_layout: bits(5)) => boolean
begin
    return TileDataLayoutConversionIsLoad(data_layout);
end;
// DOC-END: operation
