// PTO-INSTRUCTION: {"assembly":["BSTART.TIMG2COL DataType"],"block":["BSTART.TIMG2COL DataType","B.DATR Layout, DataType (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow","B.DIM LB2=TotalCol","B.IOR GMBase, zero, zero","B.IOR ParamGPR0, ParamGPR1, ParamGPR2","B.IOS or B.IOT destination","B.ASSEMBLE (Shared multi-PE only)","BSTOP"],"catalog_indices":[94],"catalog_records":[{"asm":"BSTART.TIMG2COL DataType","constraints":[{"field":"DataType","operator":"one-of","values":[1,2,3,4,5,6,7,8,13,17,18,19,25,26,27]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x01c11181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_timg2col_32_7a0f8d6c3e21","length_bits":32,"mnemonic":"BSTART.TIMG2COL","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Begins the TLSU feature-map IMG2COL block and selects its element DataType.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.TIMG2COL DataType; optional B.DATR; exactly one write-once binding for each of LB0/LB1/LB2; exactly two immediately contiguous source-only B.IOR records; Shared singleton uses one B.IOS; Shared multi-PE uses one B.IOS with PE_MASK=1111 followed by B.ASSEMBLE; Local direct output uses one B.IOT with PE_MASK=1111; BSTOP or the next BSTART completes the block."],"canonical_assembly":["BSTART.TIMG2COL DataType"],"defaults":["Omitted B.DATR is equivalent to NORM/ND2ND with DTYPE_NONE, Zero pad, and zero controls. Explicit B.DATR must use DTYPE_NONE and zero controls."],"encoding_class":"standalone-encoded","standalone_opcode":true,"examples":["BSTART.TIMG2COL FP16; B.DIM LB0, ValidCol; B.DIM LB1, ValidRow; B.DIM LB2, TotalCol; B.IOR GMBase, zero, zero; B.IOR ParamGPR0, ParamGPR1, ParamGPR2; B.IOS PE_MASK, ->S0<SizeCode>; B.ASSEMBLE 1, 1, zero, 0, ParentSizeCode; BSTOP"],"exceptions":["Reserved or unsupported DataType, malformed B.IOR sequence, wrong layout direction, invalid dimensions/crop/capacity, unsupported destination binding, address overflow, translation/permission, readiness, allocation, or PE consistency raises the applicable fault before GM access or visible target effects."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"DataType":"Encoded zero selects FP64 and is inapplicable to TIMG2COL; explicit B.DATR DTYPE_NONE inherits the BSTART type."},"legality":["TLSU Function=28 with mask 0x07ffffff and match 0x01c11181.","The operation accepts only FP32, TF32, HF32, FP16, BF16, HiF8, E4M3, E5M2, E8M0, S32, S16, S8, U32, U16, and U8.","B.DATR accepts exactly NORM/ND2ND, DN2ND, ND2M16, ND2M32, DN2M16, and DN2M32; Shared uses ND output and Local uses explicit CUBE M16/M32.","LB0, LB1, LB2 bind ValidCol, ValidRow, TotalCol exactly once each.","Exactly two contiguous source-only B.IOR records bind GMBase and ParamGPR0..2; no source or destination binding is accepted for GM.","The four-PE mask is 1111 for cooperative forms; zero-row PEs remain collective participants but perform no allocation or memory effect."],"memory_effects":["Dense NCHW/DN and NHWC/ND source indices are computed with wide unsigned arithmetic; spatial OOB and Cin padding lanes produce defined raw zero without a GM access.","Physical storage tails are not written or marked defined."],"operands":[{"field":"DataType","role":"element DataType selector"},{"field":"B.DATR.Layout","role":"dense GM source view and output destination path"},{"field":"B.DIM.LB0/LB1/LB2","role":"ValidCol, ValidRow, TotalCol"},{"field":"B.IOR","role":"GMBase and packed parameter GPRs"},{"field":"B.IOS/B.IOT","role":"Shared ND or Local CUBE destination"},{"field":"B.ASSEMBLE","role":"Shared cooperative row-range coverage"}],"ordering":["All schema, dimensions, crop, distribution, address, capacity, translation, permission, readiness, allocation, alias, and PE consistency checks precede source reads, destination payload, definedness, or publication.","Shared output publishes a complete generation atomically; failure preserves the previous generation."],"state_effects":["Writes the expanded-and-cropped logical rectangle with defined zeros for spatial OOB and Cin padding.","Direct Local CUBE materialization is equivalent to Shared ND followed by existing ND2CUBE for every valid element and definedness result."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TIMG2COL-SCHEMA","PTO-BLOCK-MODEL-MEMORY-TIMG2COL-GM"],"id":"PTO-BLOCK-BSTART-TIMG2COL","mnemonic":"BSTART.TIMG2COL","summary":"Begins the TLSU feature-map IMG2COL block and selects its element DataType.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-TIMG2COL-CONTRACT-001
// ndf: kind=contract level=L1 layer=block status=accepted
// The BSTART.TIMG2COL contract is source-view aware: ND/DN selects dense GM
// indexing and ND/DN-to-M16/M32 selects the final Local CUBE destination.
// IMG2COL linearizes Hout*Wout rows against kernel/channel columns in 32-byte
// C0 groups. Repeat, transpose, dual-source, and hidden descriptor state are
// outside this portable per-bundle interface.
// NDF-END: PTO-BSTART-TIMG2COL-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_TIMG2COL(
    operation: CommandOperation) => boolean
begin
    return operation ==
        CommandOperation_bstart_timg2col_32_7a0f8d6c3e21;
end;

// The standalone TLSU carrier is Function 28 with mask 0x07ffffff and match
// 0x01c11181; DataType occupies instruction bits [31:27].
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_TIMG2COL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

pure func InstructionContractTIMG2COLLayoutLegal(layout: bits(5)) => boolean
begin
    return layout == Zeros{5} + 0 ||
           layout == Zeros{5} + 6 ||
           layout == Zeros{5} + 21 ||
           layout == Zeros{5} + 22 ||
           layout == Zeros{5} + 29 ||
           layout == Zeros{5} + 31;
end;

pure func InstructionContractTIMG2COLIsLocalCube(layout: bits(5)) => boolean
begin
    return layout == Zeros{5} + 21 || layout == Zeros{5} + 22 ||
           layout == Zeros{5} + 29 || layout == Zeros{5} + 31;
end;

pure func InstructionContractTIMG2COLIsM32(layout: bits(5)) => boolean
begin
    return layout == Zeros{5} + 21 || layout == Zeros{5} + 29;
end;

pure func InstructionContractTIMG2COLDATRLegal(
    layout: bits(5), data_type: bits(5), pad: bits(2), cmode: bits(3),
    rmode: bits(3), sat: boolean, canonicalize: boolean) => boolean
begin
    return InstructionContractTIMG2COLLayoutLegal(layout) &&
           data_type == DTYPE_NONE && pad == Zeros{2} &&
           cmode == Zeros{3} && rmode == Zeros{3} && !sat && !canonicalize;
end;

pure func InstructionContractTIMG2COLCoreMaskLegal(mask: bits(4)) => boolean
begin
    return mask == '1111';
end;
// DOC-END: operation

// Symbolic layout applicability is the pre-encoding decode result.  Codes
// 27/28 remain the already-assigned NZ transforms and are not repurposed.
pure func InstructionContractTIMG2COLLayoutModeLegal(
    layout: TileDataLayout) => boolean
begin
    return TileDataLayoutBSTARTTIMG2COLApplicable(layout);
end;

pure func InstructionContractTIMG2COLCellEffect(
    layout: TileDataLayout, data_type: TileDataType,
    parameters: BundleTIMG2COLParameters,
    row: integer {0..127}, col: integer {0..65534})
    => BundleTIMG2COLCellResult
begin
    return BundleTIMG2COLCell(layout, data_type, parameters, row, col);
end;
