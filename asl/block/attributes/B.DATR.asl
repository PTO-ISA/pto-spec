// PTO-INSTRUCTION: {"assembly":["B.DATR {layout, datatype, padvalue_or_byteid, cmode, rmode, sat, canonicalize}"],"block":[],"catalog_indices":[1],"catalog_records":[{"asm":"B.DATR {layout, datatype, padvalue_or_byteid, cmode, rmode, sat, canonicalize}","constraints":[{"field":"CMode","operator":"one-of","values":[0,1,2,3,4,5]},{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28,31]},{"field":"Layout","operator":"one-of","values":[0,1,3,4,6,8,9,17,18,20,21,22,23,24,25,26,27,28,29,30,31]}],"encoding":[{"index":0,"mask":"0x000c707f","match":"0x00001023","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"CMode","pieces":[{"instruction_lsb":29,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3},{"name":"PadValueOrByteId","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"Sat","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"Canonicalize","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"DataType","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RMode","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3},{"name":"Layout","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"b_datr_32_c161a042ff38","length_bits":32,"mnemonic":"B.DATR","semantic_family":"CMD","semantic_group":"Bundle Data Attribute","semantic_handler":"SetBundleDataAttributes","semantic_summary":"Latches the optional per-block tile layout, data type, padding, comparison, rounding, saturation, and canonicalization attributes.","status":"accepted"}],"classification":["attributes"],"contract":{"block_composition":["Optional header command after BSTART and before B.IOR, B.IOT, B.IOS, or the first body instruction; at most one B.DATR is permitted."],"canonical_assembly":["B.DATR {layout, datatype, padvalue_or_byteid, cmode, rmode, sat, canonicalize}"],"defaults":["B.DATR is optional. When omitted, DataType inherits the typed BSTART DataType, PadValueOrByteId supplies Null padding to pad-valued operations, and Layout, CMode, RMode, Sat, and Canonicalize retain their zero meanings. For direct Local tile operations, Layout 29 selects CUBE_M32 and Layout 31 selects CUBE_M16.","An explicit B.DATR encodes every field. Concrete DataType codes override the BSTART type; DTYPE_NONE preserves the BSTART type while latching the remaining controls. Encoded DataType zero selects FP64 and encoded PadValueOrByteId zero selects Zero padding or ByteId zero.","For matrix/CUBE schemas, omitted PadValueOrByteId selects CCTRL=00: final D output and no transparent-cache hint."],"encoding_class":"standalone-encoded","examples":["B.DATR {NORM, FP32, Zero, None, RNE, 0, 0}","B.DATR {ND2M16, DTYPE_NONE, Null, None, Default, 0, 0}"],"exceptions":["A duplicate B.DATR or a B.DATR outside an active block header raises Illegal Block Exception before attribute state changes.","Reserved DataType or CMode, unassigned Layout, unsupported Layout, or operation-inapplicable nonzero fields raise an architectural fault before effects."],"field_contracts":{"CMode":{"ref":"PTO-FIELD-BLOCK-CMODE"},"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"},"PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"}},"field_zero_meanings":{"CMode":"EQ","Canonicalize":"disabled","DataType":"FP64; code 31, not code zero, is DTYPE_NONE","Layout":"NORM","PadValueOrByteId":"Zero padding, ByteId zero, or matrix CCTRL=00 as selected by the operation schema","RMode":"operation-defined default rounding","Sat":"disabled"},"legality":["B.DATR may appear at most once, after BSTART and before the block body.","DataType accepts the 25 concrete TileDataType codes plus code 31 DTYPE_NONE; codes 15, 21..23, and 29..30 are reserved and reject before effects.","Layout codes 0, 1, 3, 4, 6, 8, 9, 17, 18, 20, 21 through 29, and 30 through 31 are assigned. Codes 21 through 26 select ND2M32, ND2M16, ND2N8, M322ND, M162ND, and N82ND respectively; code 29 selects direct Local CUBE_M32 and code 31 selects direct Local CUBE_M16.","CMode codes 0..5 select EQ, NE, LT, GT, LE, and GE respectively; codes 6..7 are reserved.","All RMode codes 0..7 are assigned: operation default, RNE, RTZ, RTM, RTP, RNA, RTO, and RHB.","Canonicalize is legal only for TCVT; each selected tile operation separately constrains the applicable nonzero B.DATR fields and PadValueOrByteId interpretation.","Matrix/CUBE schemas interpret PadValueOrByteId as CCTRL: bit 0 selects raw-partial D plus a cache-replacement hint, bit 1 is an ACC-only explicit-C cache-use or prefetch hint, and init=1 forms require bit 1 to be zero."],"memory_effects":["none"],"operands":[{"field":"Layout","role":"tile data layout, direct Local CUBE layout selector, or exact GM-to-CUBE/CUBE-to-GM conversion selector"},{"field":"DataType","role":"concrete Tile element type or DTYPE_NONE inheritance sentinel"},{"field":"PadValueOrByteId","role":"operation-selected padding value, byte identifier, or matrix CCTRL raw-partial/cache-hint control"},{"field":"CMode","role":"comparison predicate selector: 0 EQ, 1 NE, 2 LT, 3 GT, 4 LE, 5 GE"},{"field":"RMode","role":"rounding selector: 0 operation default, 1 RNE, 2 RTZ, 3 RTM, 4 RTP, 5 RNA, 6 RTO, 7 RHB"},{"field":"Sat","role":"saturation enable"},{"field":"Canonicalize","role":"TCVT private-format canonicalization enable"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["Latch the accepted bundle data attributes for the current block and mark B.DATR present without modifying tile or memory state."]},"depends_on":["PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES","PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"field_domains":[{"assigned":[{"meaning":"EQ","value":0},{"meaning":"NE","value":1},{"meaning":"LT","value":2},{"meaning":"GT","value":3},{"meaning":"LE","value":4},{"meaning":"GE","value":5}],"id":"PTO-FIELD-BLOCK-CMODE","rejection":"Codes 6 and 7 are reserved and reject before architectural effects.","reserved":[6,7],"role":"Selects the comparison relation used by TCMP and TCMPS.","width":3,"zero_meaning":"Code zero selects equality comparison."},{"assigned":[{"meaning":"Zero-or-ByteId0","value":0},{"meaning":"Max-or-ByteId1","value":1},{"meaning":"Min-or-ByteId2","value":2},{"meaning":"Null-or-ByteId3","value":3}],"id":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID","rejection":"All four encodings are assigned; the selected operation separately validates whether the field is PadValue, ByteId, or inapplicable.","reserved":[],"role":"Carries the operation-selected PadValue or ByteId union field.","width":2,"zero_meaning":"For PadValue operations code zero selects Zero; for ByteId operations it selects ByteId zero."}],"id":"PTO-BLOCK-B-DATR","mnemonic":"B.DATR","summary":"Latches the optional per-block tile layout, data type, padding, comparison, rounding, saturation, and canonicalization attributes.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-B-DATR-FIELDS-001
// ndf: kind=contract level=L1 layer=block status=accepted
// B.DATR MUST distinguish omission from every encoded zero value, MUST accept
// exactly the assigned DataType, Layout, CMode, and RMode values, and MUST
// defer nonzero field applicability to the selected Tile operation schema.
// TGPR2T owns PadValueOrByteId as numeric U8 Zero/Max whole-tile padding and
// RMode[16:15] as ByteOffset 0..3; RMode[17] is reserved-zero.
// NDF-END: PTO-B-DATR-FIELDS-001
// NDF-BEGIN: PTO-B-DATR-MATRIX-ACC-CONTROL-001
// ndf: kind=contract level=L1 layer=block status=accepted
// For matrix/CUBE operation schemas only, PadValueOrByteId MUST be interpreted
// as CCTRL[1:0]. CCTRL[0]=1 selects raw accumulator-type D output and MAY hint
// transparent-cache replacement with the identical D value. CCTRL[1]=1 MAY
// hint cache use or prefetch of explicit C. Omission is CCTRL=00. Init=1 forms
// require CCTRL[1]=0; non-matrix operations retain the PadValueOrByteId union.
// NDF-END: PTO-B-DATR-MATRIX-ACC-CONTROL-001
// NDF-BEGIN: PTO-CUBE-CELL-TRANSPORT-001
// ndf: kind=contract level=L1 layer=block status=accepted
// B.DATR Layout codes 21 through 26 MUST select ND2M32, ND2M16, ND2N8,
// M322ND, M162ND, and N82ND respectively.  The first three are GM-to-Local
// CUBE loads and the last three are Local CUBE-to-GM stores.  These selectors
// MUST NOT create distinct Tile instruction identities.
// NDF-END: PTO-CUBE-CELL-TRANSPORT-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_DATR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_datr_32_c161a042ff38);
end;
// DOC-END: decode
// DOC-BEGIN: operation
// B.DATR fields retain their operation-selected meanings. For matrix/CUBE
// operation schemas, PadValueOrByteId is selected as CCTRL[1:0]: CCTRL[0]
// selects raw-partial D plus a cache-replacement hint and CCTRL[1] is an
// explicit-C cache-use/prefetch hint; omission selects 00. For TGPR2T,
// PadValueOrByteId is numeric U8 Zero/Max whole-tile padding, RMode[16:15]
// selects ByteOffset 0..3, and RMode[17] is reserved-zero. Null padding is
// rejected by TGPR2T before allocation or publication.
// DataType code 31 has the canonical spelling DTYPE_NONE. It is an encoded
// field sentinel, not a TileDataType. A concrete B.DATR type overrides the
// BSTART type; DTYPE_NONE preserves a concrete BSTART type and still latches
// the remaining B.DATR controls. If no concrete type can be resolved, complete
// bundle preflight raises Fault_TileLegality before allocation or effects.
readonly func InstructionContractHandler_B_DATR() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleDataAttributes;
end;

pure func InstructionContractHeaderOnly_B_DATR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractDuplicateRejects_B_DATR()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
