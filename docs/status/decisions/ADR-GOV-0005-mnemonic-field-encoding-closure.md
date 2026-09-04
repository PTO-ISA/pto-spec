---
{
  "id": "ADR-GOV-0005",
  "title": "Mnemonic and Encoded-Field Contract Closure",
  "title_zh": "助记符与编码字段契约闭合",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "Codex"
  ],
  "approvers": [
    "PTO ISA maintainers",
    "zhoubot"
  ],
  "created": "2026-08-11",
  "accepted": "2026-08-11",
  "rejected": null,
  "superseded": null,
  "baseline": "4d115387b8a8a3c135f78189778d38547e75c697",
  "target_releases": [
    "0.58.1",
    "0.58.5"
  ],
  "affected_ndf": [
    "PTO-ACRC-DECISION-BINDING-001",
    "PTO-ACRE-IMPLICIT-STOP-001",
    "PTO-ADD-DECISION-BINDING-001",
    "PTO-ADDTPC-PAGE-001",
    "PTO-AND-DECISION-BINDING-001",
    "PTO-ARCH-COMMIT-EVENT-CONFORMANCE-001",
    "PTO-ARCH-CONDITIONAL-BRANCH-RESERVATION-001",
    "PTO-ARCH-ENCODING-OWNERSHIP-001",
    "PTO-ARCH-STATE-CLOSURE-001",
    "PTO-ARCH-TEPL-ALIAS-001",
    "PTO-ARCH-TILE-EXECUTION-ENGINE-001",
    "PTO-ARCH-TILE-INSTRUCTION-CLASS-001",
    "PTO-B-CATR-CONTROL-001",
    "PTO-B-DATR-FIELDS-001",
    "PTO-B-DIM-WRITE-001",
    "PTO-B-FPATR-MATRIX-POSTPROCESS-001",
    "PTO-B-HINT-LIFECYCLE-001",
    "PTO-B-IOR-BINDING-001",
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-IOT-STREAM-001",
    "PTO-BCNT-DECISION-BINDING-001",
    "PTO-BIC-DECISION-BINDING-001",
    "PTO-BIS-DECISION-BINDING-001",
    "PTO-BLOCK-ERCOV-RESERVED-001",
    "PTO-BLOCK-ESAVE-RESERVED-001",
    "PTO-BLOCK-MSET-FILL-001",
    "PTO-BLOCK-XB-RESERVED-001",
    "PTO-BSE-DECISION-BINDING-001",
    "PTO-BSTART-CALL-DECISION-BINDING-001",
    "PTO-BSTART-DECISION-BINDING-001",
    "PTO-BSTART-FP-CONTROL-001",
    "PTO-BSTART-GMOV-COLLECTIVE-001",
    "PTO-BSTART-ICALL-DECISION-BINDING-001",
    "PTO-BSTART-MGATHER-CAS-SCHEMA-001",
    "PTO-BSTART-MGATHER-MASK-SCHEMA-001",
    "PTO-BSTART-MGATHER-SCHEMA-001",
    "PTO-BSTART-MSCATTER-MASK-SCHEMA-001",
    "PTO-BSTART-MSCATTER-SCHEMA-001",
    "PTO-BSTART-SFU-DECISION-BINDING-001",
    "PTO-BSTART-STD-CONTROL-001",
    "PTO-BSTART-SYS-CONTROL-001",
    "PTO-BSTART-TEPL-DECISION-BINDING-001",
    "PTO-BSTART-TGEMV-ACC-CONTRACT-001",
    "PTO-BSTART-TGEMV-BIAS-CONTRACT-001",
    "PTO-BSTART-TGEMV-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-ACC-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-BIAS-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-CONTRACT-001",
    "PTO-BSTART-TLOAD-CUBE-001",
    "PTO-BSTART-TLOAD-MEMORY-001",
    "PTO-BSTART-TMATMUL-ACC-CONTRACT-001",
    "PTO-BSTART-TMATMUL-BIAS-CONTRACT-001",
    "PTO-BSTART-TMATMUL-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-ACC-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-BIAS-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-CONTRACT-001",
    "PTO-BSTART-TMOV-SHARED-001",
    "PTO-BSTART-TPREFETCH-MEMORY-001",
    "PTO-BSTART-TSTORE-CUBE-001",
    "PTO-BSTART-TSTORE-MEMORY-001",
    "PTO-BSTART-VEC-DECISION-BINDING-001",
    "PTO-BSTOP-DECISION-BINDING-001",
    "PTO-BWE-DECISION-BINDING-001",
    "PTO-BWI-DECISION-BINDING-001",
    "PTO-BWT-DECISION-BINDING-001",
    "PTO-BXS-DECISION-BINDING-001",
    "PTO-BXU-DECISION-BINDING-001",
    "PTO-C-BSTART-CONTROL-001",
    "PTO-C-BSTART-FP-CONTROL-001",
    "PTO-C-BSTART-STD-CONTROL-001",
    "PTO-C-BSTART-SYS-CONTROL-001",
    "PTO-C-BSTOP-DECISION-BINDING-001",
    "PTO-C-CMP-EQI-DECISION-BINDING-001",
    "PTO-C-CMP-NEI-DECISION-BINDING-001",
    "PTO-C-EBREAK-CAUSE-001",
    "PTO-C-SETC-EQ-CONDITIONAL-SETTER-001",
    "PTO-C-SETC-NE-CONDITIONAL-SETTER-001",
    "PTO-C-SETC-TGT-SNAPSHOT-001",
    "PTO-C-SETRET-DECISION-BINDING-001",
    "PTO-C-SSRGET-DIRECT-IDS-001",
    "PTO-CLZ-DECISION-BINDING-001",
    "PTO-CTZ-DECISION-BINDING-001",
    "PTO-CUBE-CELL-TRANSPORT-001",
    "PTO-EBREAK-DECISION-BINDING-001",
    "PTO-FABS-DECISION-BINDING-001",
    "PTO-FCVTA-DECISION-BINDING-001",
    "PTO-FCVTM-DECISION-BINDING-001",
    "PTO-FCVTN-DECISION-BINDING-001",
    "PTO-FCVTP-DECISION-BINDING-001",
    "PTO-FCVTZ-DECISION-BINDING-001",
    "PTO-FENCE-D-DECISION-BINDING-001",
    "PTO-FENCE-I-DECISION-BINDING-001",
    "PTO-FENTRY-RESTARTABLE-FRAME-001",
    "PTO-FEXIT-RESTARTABLE-FRAME-001",
    "PTO-FMAX-DECISION-BINDING-001",
    "PTO-FMIN-DECISION-BINDING-001",
    "PTO-FNE-DECISION-BINDING-001",
    "PTO-FNES-DECISION-BINDING-001",
    "PTO-FRET-RA-RESTARTABLE-FRAME-001",
    "PTO-FRET-STK-RESTARTABLE-FRAME-001",
    "PTO-GMOV-CORE4-PEER-001",
    "PTO-HL-ADDI-CONTRACT-001",
    "PTO-HL-ADDIW-CONTRACT-001",
    "PTO-HL-ADDTPC-PAGE-001",
    "PTO-HL-ANDI-CONTRACT-001",
    "PTO-HL-ANDIW-CONTRACT-001",
    "PTO-HL-BFI-DECISION-BINDING-001",
    "PTO-HL-CCAT-CONTRACT-001",
    "PTO-HL-CCATW-CONTRACT-001",
    "PTO-HL-DIV-DECISION-BINDING-001",
    "PTO-HL-DIVU-DECISION-BINDING-001",
    "PTO-HL-DIVUW-DECISION-BINDING-001",
    "PTO-HL-DIVW-DECISION-BINDING-001",
    "PTO-HL-LIS-DECISION-BINDING-001",
    "PTO-HL-LUI-UPPER-HALF-001",
    "PTO-HL-MADDW-WORD-HALVES-001",
    "PTO-HL-ORI-CONTRACT-001",
    "PTO-HL-ORIW-CONTRACT-001",
    "PTO-HL-PRF-A-CACHE-MODEL-001",
    "PTO-HL-PRF-CACHE-MODEL-001",
    "PTO-HL-PRFI-U-CACHE-MODEL-001",
    "PTO-HL-PRFI-UA-CACHE-MODEL-001",
    "PTO-HL-QMT-GQM-001",
    "PTO-HL-QPOP-GQM-001",
    "PTO-HL-QPUSH-GQM-001",
    "PTO-HL-REM-RESULT-ORDER-001",
    "PTO-HL-REMU-RESULT-ORDER-001",
    "PTO-HL-REMUW-RESULT-ORDER-001",
    "PTO-HL-REMW-RESULT-ORDER-001",
    "PTO-HL-SD-UPO-DECISION-BINDING-001",
    "PTO-HL-SD-UPR-DECISION-BINDING-001",
    "PTO-HL-SETC-ANDI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-EQI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-GEI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-GEUI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-LTI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-LTUI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-NEI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETC-ORI-CONDITIONAL-SETTER-001",
    "PTO-HL-SETRET-DECISION-BINDING-001",
    "PTO-HL-SH-UPO-DECISION-BINDING-001",
    "PTO-HL-SH-UPR-DECISION-BINDING-001",
    "PTO-HL-SSRGET-DECISION-BINDING-001",
    "PTO-HL-SSRSET-DECISION-BINDING-001",
    "PTO-HL-SUBI-CONTRACT-001",
    "PTO-HL-SUBIW-CONTRACT-001",
    "PTO-HL-SW-UPO-DECISION-BINDING-001",
    "PTO-HL-SW-UPR-DECISION-BINDING-001",
    "PTO-HL-XORI-CONTRACT-001",
    "PTO-HL-XORIW-CONTRACT-001",
    "PTO-J-DECISION-BINDING-001",
    "PTO-JR-DECISION-BINDING-001",
    "PTO-L-BSTOP-DECISION-BINDING-001",
    "PTO-LSRGET-BARG-001",
    "PTO-MCOPY-RESTART-001",
    "PTO-MGATHER-BYTE-DISPLACEMENT-001",
    "PTO-MGATHER-CAS-ATOMIC-001",
    "PTO-MGATHER-CAS-PUBLICATION-001",
    "PTO-MGATHER-MASK-PREDICATE-001",
    "PTO-MGATHER-MASK-PUBLICATION-001",
    "PTO-MGATHER-MASK-TYPE-002",
    "PTO-MSCATTER-BYTE-DISPLACEMENT-001",
    "PTO-MSCATTER-DUPLICATE-ORDER-001",
    "PTO-MSCATTER-MASK-DUPLICATE-001",
    "PTO-MSCATTER-MASK-PREDICATE-001",
    "PTO-MSCATTER-MASK-TYPE-002",
    "PTO-NUMERIC-FORMAT-DESCRIPTOR-001",
    "PTO-OR-DECISION-BINDING-001",
    "PTO-PRF-NONFAULTING-HINT-001",
    "PTO-PRFI-U-NONFAULTING-HINT-001",
    "PTO-RELEASE-VERIFICATION",
    "PTO-REV-DECISION-BINDING-001",
    "PTO-SCVTF-DECISION-BINDING-001",
    "PTO-SD-U-ADR-CONTRACT-001",
    "PTO-SD-XOR-ADR-CONTRACT-001",
    "PTO-SDI-ADR-CONTRACT-001",
    "PTO-SDI-U-ADR-CONTRACT-001",
    "PTO-SETC-AND-CONDITIONAL-SETTER-001",
    "PTO-SETC-ANDI-CONDITIONAL-SETTER-001",
    "PTO-SETC-EQ-CONDITIONAL-SETTER-001",
    "PTO-SETC-EQI-CONDITIONAL-SETTER-001",
    "PTO-SETC-GE-CONDITIONAL-SETTER-001",
    "PTO-SETC-GEI-CONDITIONAL-SETTER-001",
    "PTO-SETC-GEU-CONDITIONAL-SETTER-001",
    "PTO-SETC-GEUI-CONDITIONAL-SETTER-001",
    "PTO-SETC-LT-CONDITIONAL-SETTER-001",
    "PTO-SETC-LTI-CONDITIONAL-SETTER-001",
    "PTO-SETC-LTU-CONDITIONAL-SETTER-001",
    "PTO-SETC-LTUI-CONDITIONAL-SETTER-001",
    "PTO-SETC-NE-CONDITIONAL-SETTER-001",
    "PTO-SETC-NEI-CONDITIONAL-SETTER-001",
    "PTO-SETC-OR-CONDITIONAL-SETTER-001",
    "PTO-SETC-ORI-CONDITIONAL-SETTER-001",
    "PTO-SETC-TGT-ADR-CONTRACT-001",
    "PTO-SETRET-ADR-CONTRACT-001",
    "PTO-SH-ADR-CONTRACT-001",
    "PTO-SH-PCR-ADR-CONTRACT-001",
    "PTO-SH-U-ADR-CONTRACT-001",
    "PTO-SHI-ADR-CONTRACT-001",
    "PTO-SHI-U-ADR-CONTRACT-001",
    "PTO-SLL-ADR-CONTRACT-001",
    "PTO-SLLI-ADR-CONTRACT-001",
    "PTO-SLLIW-ADR-CONTRACT-001",
    "PTO-SLLW-ADR-CONTRACT-001",
    "PTO-SOURCE-HIERARCHY",
    "PTO-SRA-ADR-CONTRACT-001",
    "PTO-SRAI-ADR-CONTRACT-001",
    "PTO-SRAIW-ADR-CONTRACT-001",
    "PTO-SRAW-ADR-CONTRACT-001",
    "PTO-SRL-ADR-CONTRACT-001",
    "PTO-SRLI-ADR-CONTRACT-001",
    "PTO-SRLIW-ADR-CONTRACT-001",
    "PTO-SRLW-ADR-CONTRACT-001",
    "PTO-SSRGET-ADR-CONTRACT-001",
    "PTO-SSRSET-ADR-CONTRACT-001",
    "PTO-SSRSWAP-ADR-CONTRACT-001",
    "PTO-SUB-ADR-CONTRACT-001",
    "PTO-SUBI-ADR-CONTRACT-001",
    "PTO-SUBIW-ADR-CONTRACT-001",
    "PTO-SUBW-ADR-CONTRACT-001",
    "PTO-SW-ADD-ADR-CONTRACT-001",
    "PTO-SW-ADR-CONTRACT-001",
    "PTO-SW-AND-ADR-CONTRACT-001",
    "PTO-SW-OR-ADR-CONTRACT-001",
    "PTO-SW-PCR-ADR-CONTRACT-001",
    "PTO-SW-SMAX-ADR-CONTRACT-001",
    "PTO-SW-SMIN-ADR-CONTRACT-001",
    "PTO-SW-U-ADR-CONTRACT-001",
    "PTO-SW-UMAX-ADR-CONTRACT-001",
    "PTO-SW-UMIN-ADR-CONTRACT-001",
    "PTO-SW-XOR-ADR-CONTRACT-001",
    "PTO-SWAPB-ADR-CONTRACT-001",
    "PTO-SWAPD-ADR-CONTRACT-001",
    "PTO-SWAPH-ADR-CONTRACT-001",
    "PTO-SWAPW-ADR-CONTRACT-001",
    "PTO-SWI-ADR-CONTRACT-001",
    "PTO-SWI-U-ADR-CONTRACT-001",
    "PTO-TABS-CONTRACT-001",
    "PTO-TADD-CONTRACT-001",
    "PTO-TADDS-CONTRACT-001",
    "PTO-TAND-CONTRACT-001",
    "PTO-TANDS-CONTRACT-001",
    "PTO-TCI-CONTRACT-001",
    "PTO-TCMP-CONTRACT-001",
    "PTO-TCMPS-CONTRACT-001",
    "PTO-TCOLARGMAX-CONTRACT-001",
    "PTO-TCOLARGMIN-CONTRACT-001",
    "PTO-TCOLEXPAND-CONTRACT-001",
    "PTO-TCOLEXPANDADD-CONTRACT-001",
    "PTO-TCOLEXPANDDIV-CONTRACT-001",
    "PTO-TCOLEXPANDEXPDIF-CONTRACT-001",
    "PTO-TCOLEXPANDMAX-CONTRACT-001",
    "PTO-TCOLEXPANDMIN-CONTRACT-001",
    "PTO-TCOLEXPANDMUL-CONTRACT-001",
    "PTO-TCOLEXPANDSUB-CONTRACT-001",
    "PTO-TCOLMAX-CONTRACT-001",
    "PTO-TCOLMIN-CONTRACT-001",
    "PTO-TCOLPROD-CONTRACT-001",
    "PTO-TCOLSUM-CONTRACT-001",
    "PTO-TCVT-CONTRACT-001",
    "PTO-TDIV-CONTRACT-001",
    "PTO-TDIVS-CONTRACT-001",
    "PTO-TEXP-CONTRACT-001",
    "PTO-TEXPANDS-CONTRACT-001",
    "PTO-TFMA-CONTRACT-001",
    "PTO-TGATHER-CONTRACT-001",
    "PTO-TGEMV-ACC-CONTRACT-001",
    "PTO-TGEMV-BIAS-CONTRACT-001",
    "PTO-TGEMV-CONTRACT-001",
    "PTO-TGEMV-MX-ACC-CONTRACT-001",
    "PTO-TGEMV-MX-BIAS-CONTRACT-001",
    "PTO-TGEMV-MX-CONTRACT-001",
    "PTO-TILE-CAPACITY-PER-PE",
    "PTO-TIMG2COL-CONTRACT-001",
    "PTO-TLB-IA-ADR-CONTRACT-001",
    "PTO-TLB-IALL-ADR-CONTRACT-001",
    "PTO-TLB-IAV-ADR-CONTRACT-001",
    "PTO-TLB-IV-ADR-CONTRACT-001",
    "PTO-TLOAD-CUBE-001",
    "PTO-TLOAD-MEMORY-001",
    "PTO-TLOG-CONTRACT-001",
    "PTO-TMATMUL-ACC-CONTRACT-001",
    "PTO-TMATMUL-BIAS-CONTRACT-001",
    "PTO-TMATMUL-CONTRACT-001",
    "PTO-TMATMUL-MX-ACC-CONTRACT-001",
    "PTO-TMATMUL-MX-BIAS-CONTRACT-001",
    "PTO-TMATMUL-MX-CONTRACT-001",
    "PTO-TMAX-CONTRACT-001",
    "PTO-TMAXS-CONTRACT-001",
    "PTO-TMIN-CONTRACT-001",
    "PTO-TMINS-CONTRACT-001",
    "PTO-TMOV-CONTRACT-001",
    "PTO-TMUL-CONTRACT-001",
    "PTO-TMULS-CONTRACT-001",
    "PTO-TNEG-CONTRACT-001",
    "PTO-TNOT-CONTRACT-001",
    "PTO-TOR-CONTRACT-001",
    "PTO-TORS-CONTRACT-001",
    "PTO-TPREFETCH-FOOTPRINT-001",
    "PTO-TRECIP-CONTRACT-001",
    "PTO-TRELU-CONTRACT-001",
    "PTO-TREM-CONTRACT-001",
    "PTO-TREMS-CONTRACT-001",
    "PTO-TROWARGMAX-CONTRACT-001",
    "PTO-TROWARGMIN-CONTRACT-001",
    "PTO-TROWEXPAND-CONTRACT-001",
    "PTO-TROWEXPANDADD-CONTRACT-001",
    "PTO-TROWEXPANDDIV-CONTRACT-001",
    "PTO-TROWEXPANDEXPDIF-CONTRACT-001",
    "PTO-TROWEXPANDMAX-CONTRACT-001",
    "PTO-TROWEXPANDMIN-CONTRACT-001",
    "PTO-TROWEXPANDMUL-CONTRACT-001",
    "PTO-TROWEXPANDSUB-CONTRACT-001",
    "PTO-TROWMAX-CONTRACT-001",
    "PTO-TROWMIN-CONTRACT-001",
    "PTO-TROWPROD-CONTRACT-001",
    "PTO-TROWSUM-CONTRACT-001",
    "PTO-TRSQRT-CONTRACT-001",
    "PTO-TSCATTER-CONTRACT-001",
    "PTO-TSEL-CONTRACT-001",
    "PTO-TSELS-CONTRACT-001",
    "PTO-TSHL-CONTRACT-001",
    "PTO-TSHLS-CONTRACT-001",
    "PTO-TSHR-CONTRACT-001",
    "PTO-TSHRS-CONTRACT-001",
    "PTO-TSQRT-CONTRACT-001",
    "PTO-TSTORE-CUBE-001",
    "PTO-TSTORE-MEMORY-001",
    "PTO-TSUB-CONTRACT-001",
    "PTO-TSUBS-CONTRACT-001",
    "PTO-TTRI-CONTRACT-001",
    "PTO-TXOR-CONTRACT-001",
    "PTO-TXORS-CONTRACT-001",
    "PTO-UCVTF-DECISION-BINDING-001",
    "PTO-XOR-ADR-CONTRACT-001",
    "PTO-XORI-ADR-CONTRACT-001",
    "PTO-XORIW-ADR-CONTRACT-001",
    "PTO-XORW-ADR-CONTRACT-001",
    "PTO-INST-SCALAR-CSEL",
    "PTO-INST-SCALAR-FCVTA",
    "PTO-INST-SCALAR-FCVTM",
    "PTO-INST-SCALAR-FCVTN",
    "PTO-INST-SCALAR-FCVTP",
    "PTO-INST-SCALAR-FCVTZ"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR",
    "PTO-ARCH-OVERVIEW-ARCHITECTURE",
    "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP",
    "PTO-ARCH-OVERVIEW-INSTRUCTION-CLASSIFICATION",
    "PTO-BLOCK-B-CATR",
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-B-DIM",
    "PTO-BLOCK-B-FPATR",
    "PTO-BLOCK-B-HINT",
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-BSTART",
    "PTO-BLOCK-BSTART-CALL",
    "PTO-BLOCK-BSTART-FP",
    "PTO-BLOCK-BSTART-GMOV",
    "PTO-BLOCK-BSTART-ICALL",
    "PTO-BLOCK-BSTART-MGATHER",
    "PTO-BLOCK-BSTART-MGATHER-CAS",
    "PTO-BLOCK-BSTART-MGATHER-MASK",
    "PTO-BLOCK-BSTART-MSCATTER",
    "PTO-BLOCK-BSTART-MSCATTER-MASK",
    "PTO-BLOCK-BSTART-SFU",
    "PTO-BLOCK-BSTART-STD",
    "PTO-BLOCK-BSTART-SYS",
    "PTO-BLOCK-BSTART-TEPL",
    "PTO-BLOCK-BSTART-TGEMV",
    "PTO-BLOCK-BSTART-TGEMV-ACC",
    "PTO-BLOCK-BSTART-TGEMV-BIAS",
    "PTO-BLOCK-BSTART-TGEMVMX",
    "PTO-BLOCK-BSTART-TGEMVMX-ACC",
    "PTO-BLOCK-BSTART-TGEMVMX-BIAS",
    "PTO-BLOCK-BSTART-TLOAD",
    "PTO-BLOCK-BSTART-TMATMUL",
    "PTO-BLOCK-BSTART-TMATMUL-ACC",
    "PTO-BLOCK-BSTART-TMATMUL-BIAS",
    "PTO-BLOCK-BSTART-TMATMULMX",
    "PTO-BLOCK-BSTART-TMATMULMX-ACC",
    "PTO-BLOCK-BSTART-TMATMULMX-BIAS",
    "PTO-BLOCK-BSTART-TMOV",
    "PTO-BLOCK-BSTART-TPREFETCH",
    "PTO-BLOCK-BSTART-TSTORE",
    "PTO-BLOCK-BSTART-VEC",
    "PTO-BLOCK-BSTOP",
    "PTO-BLOCK-C-B-DIMI",
    "PTO-BLOCK-C-BSTART",
    "PTO-BLOCK-C-BSTART-FP",
    "PTO-BLOCK-C-BSTART-STD",
    "PTO-BLOCK-C-BSTART-SYS",
    "PTO-BLOCK-C-BSTOP",
    "PTO-BLOCK-ERCOV",
    "PTO-BLOCK-ESAVE",
    "PTO-BLOCK-FENTRY",
    "PTO-BLOCK-FEXIT",
    "PTO-BLOCK-FRET-RA",
    "PTO-BLOCK-FRET-STK",
    "PTO-BLOCK-HL-QMT",
    "PTO-BLOCK-HL-QPOP",
    "PTO-BLOCK-HL-QPUSH",
    "PTO-BLOCK-L-BSTOP",
    "PTO-BLOCK-MCOPY",
    "PTO-BLOCK-MSET",
    "PTO-BLOCK-XB",
    "PTO-SCALAR-ACRC",
    "PTO-SCALAR-ACRE",
    "PTO-SCALAR-ADD",
    "PTO-SCALAR-ADDI",
    "PTO-SCALAR-ADDIW",
    "PTO-SCALAR-ADDTPC",
    "PTO-SCALAR-ADDW",
    "PTO-SCALAR-AND",
    "PTO-SCALAR-ANDI",
    "PTO-SCALAR-ANDIW",
    "PTO-SCALAR-ANDW",
    "PTO-SCALAR-ASSERT",
    "PTO-SCALAR-BC-IALL",
    "PTO-SCALAR-BC-IVA",
    "PTO-SCALAR-BCNT",
    "PTO-SCALAR-BIC",
    "PTO-SCALAR-BIS",
    "PTO-SCALAR-BSE",
    "PTO-SCALAR-BWE",
    "PTO-SCALAR-BWI",
    "PTO-SCALAR-BWT",
    "PTO-SCALAR-BXS",
    "PTO-SCALAR-BXU",
    "PTO-SCALAR-C-ADD",
    "PTO-SCALAR-C-ADDI",
    "PTO-SCALAR-C-AND",
    "PTO-SCALAR-C-CMP-EQI",
    "PTO-SCALAR-C-CMP-NEI",
    "PTO-SCALAR-C-EBREAK",
    "PTO-SCALAR-C-LDI",
    "PTO-SCALAR-C-LWI",
    "PTO-SCALAR-C-MOVI",
    "PTO-SCALAR-C-MOVR",
    "PTO-SCALAR-C-OR",
    "PTO-SCALAR-C-SDI",
    "PTO-SCALAR-C-SETC-EQ",
    "PTO-SCALAR-C-SETC-NE",
    "PTO-SCALAR-C-SETC-TGT",
    "PTO-SCALAR-C-SETRET",
    "PTO-SCALAR-C-SEXT-B",
    "PTO-SCALAR-C-SEXT-H",
    "PTO-SCALAR-C-SEXT-W",
    "PTO-SCALAR-C-SLLI",
    "PTO-SCALAR-C-SRLI",
    "PTO-SCALAR-C-SSRGET",
    "PTO-SCALAR-C-SUB",
    "PTO-SCALAR-C-SWI",
    "PTO-SCALAR-C-ZEXT-B",
    "PTO-SCALAR-C-ZEXT-H",
    "PTO-SCALAR-C-ZEXT-W",
    "PTO-SCALAR-CASB",
    "PTO-SCALAR-CASD",
    "PTO-SCALAR-CASH",
    "PTO-SCALAR-CASW",
    "PTO-SCALAR-CLZ",
    "PTO-SCALAR-CMP-AND",
    "PTO-SCALAR-CMP-ANDI",
    "PTO-SCALAR-CMP-EQ",
    "PTO-SCALAR-CMP-EQI",
    "PTO-SCALAR-CMP-GE",
    "PTO-SCALAR-CMP-GEI",
    "PTO-SCALAR-CMP-GEU",
    "PTO-SCALAR-CMP-GEUI",
    "PTO-SCALAR-CMP-LT",
    "PTO-SCALAR-CMP-LTI",
    "PTO-SCALAR-CMP-LTU",
    "PTO-SCALAR-CMP-LTUI",
    "PTO-SCALAR-CMP-NE",
    "PTO-SCALAR-CMP-NEI",
    "PTO-SCALAR-CMP-OR",
    "PTO-SCALAR-CMP-ORI",
    "PTO-SCALAR-CSEL",
    "PTO-SCALAR-CTZ",
    "PTO-SCALAR-DC-CISW",
    "PTO-SCALAR-DC-CIVA",
    "PTO-SCALAR-DC-CSW",
    "PTO-SCALAR-DC-CVA",
    "PTO-SCALAR-DC-IALL",
    "PTO-SCALAR-DC-ISW",
    "PTO-SCALAR-DC-IVA",
    "PTO-SCALAR-DC-ZVA",
    "PTO-SCALAR-DIV",
    "PTO-SCALAR-DIVU",
    "PTO-SCALAR-DIVUW",
    "PTO-SCALAR-DIVW",
    "PTO-SCALAR-DMA",
    "PTO-SCALAR-EBREAK",
    "PTO-SCALAR-FABS",
    "PTO-SCALAR-FADD",
    "PTO-SCALAR-FCVT",
    "PTO-SCALAR-FCVTA",
    "PTO-SCALAR-FCVTM",
    "PTO-SCALAR-FCVTN",
    "PTO-SCALAR-FCVTP",
    "PTO-SCALAR-FCVTZ",
    "PTO-SCALAR-FDIV",
    "PTO-SCALAR-FENCE-D",
    "PTO-SCALAR-FENCE-I",
    "PTO-SCALAR-FEQ",
    "PTO-SCALAR-FEQS",
    "PTO-SCALAR-FEXP",
    "PTO-SCALAR-FGE",
    "PTO-SCALAR-FGES",
    "PTO-SCALAR-FLT",
    "PTO-SCALAR-FLTS",
    "PTO-SCALAR-FMADD",
    "PTO-SCALAR-FMAX",
    "PTO-SCALAR-FMIN",
    "PTO-SCALAR-FMSUB",
    "PTO-SCALAR-FMUL",
    "PTO-SCALAR-FNE",
    "PTO-SCALAR-FNES",
    "PTO-SCALAR-FNMADD",
    "PTO-SCALAR-FNMSUB",
    "PTO-SCALAR-FRECIP",
    "PTO-SCALAR-FSQRT",
    "PTO-SCALAR-FSUB",
    "PTO-SCALAR-HL-ADDI",
    "PTO-SCALAR-HL-ADDIW",
    "PTO-SCALAR-HL-ADDTPC",
    "PTO-SCALAR-HL-ANDI",
    "PTO-SCALAR-HL-ANDIW",
    "PTO-SCALAR-HL-BFI",
    "PTO-SCALAR-HL-CASB",
    "PTO-SCALAR-HL-CASD",
    "PTO-SCALAR-HL-CASH",
    "PTO-SCALAR-HL-CASW",
    "PTO-SCALAR-HL-CCAT",
    "PTO-SCALAR-HL-CCATW",
    "PTO-SCALAR-HL-CMP-ANDI",
    "PTO-SCALAR-HL-CMP-EQI",
    "PTO-SCALAR-HL-CMP-GEI",
    "PTO-SCALAR-HL-CMP-GEUI",
    "PTO-SCALAR-HL-CMP-LTI",
    "PTO-SCALAR-HL-CMP-LTUI",
    "PTO-SCALAR-HL-CMP-NEI",
    "PTO-SCALAR-HL-CMP-ORI",
    "PTO-SCALAR-HL-DIV",
    "PTO-SCALAR-HL-DIVU",
    "PTO-SCALAR-HL-DIVUW",
    "PTO-SCALAR-HL-DIVW",
    "PTO-SCALAR-HL-LB-PCR",
    "PTO-SCALAR-HL-LB-PO",
    "PTO-SCALAR-HL-LB-PR",
    "PTO-SCALAR-HL-LBI",
    "PTO-SCALAR-HL-LBI-PO",
    "PTO-SCALAR-HL-LBI-PR",
    "PTO-SCALAR-HL-LBIP",
    "PTO-SCALAR-HL-LBP",
    "PTO-SCALAR-HL-LBU-PCR",
    "PTO-SCALAR-HL-LBU-PO",
    "PTO-SCALAR-HL-LBU-PR",
    "PTO-SCALAR-HL-LBUI",
    "PTO-SCALAR-HL-LBUI-PO",
    "PTO-SCALAR-HL-LBUI-PR",
    "PTO-SCALAR-HL-LBUIP",
    "PTO-SCALAR-HL-LBUP",
    "PTO-SCALAR-HL-LD-PCR",
    "PTO-SCALAR-HL-LD-PO",
    "PTO-SCALAR-HL-LD-PR",
    "PTO-SCALAR-HL-LDI",
    "PTO-SCALAR-HL-LDI-PO",
    "PTO-SCALAR-HL-LDI-PR",
    "PTO-SCALAR-HL-LDI-U",
    "PTO-SCALAR-HL-LDI-UPO",
    "PTO-SCALAR-HL-LDI-UPR",
    "PTO-SCALAR-HL-LDIP",
    "PTO-SCALAR-HL-LDIP-U",
    "PTO-SCALAR-HL-LDP",
    "PTO-SCALAR-HL-LH-PCR",
    "PTO-SCALAR-HL-LH-PO",
    "PTO-SCALAR-HL-LH-PR",
    "PTO-SCALAR-HL-LHI",
    "PTO-SCALAR-HL-LHI-PO",
    "PTO-SCALAR-HL-LHI-PR",
    "PTO-SCALAR-HL-LHI-U",
    "PTO-SCALAR-HL-LHI-UPO",
    "PTO-SCALAR-HL-LHI-UPR",
    "PTO-SCALAR-HL-LHIP",
    "PTO-SCALAR-HL-LHIP-U",
    "PTO-SCALAR-HL-LHP",
    "PTO-SCALAR-HL-LHU-PCR",
    "PTO-SCALAR-HL-LHU-PO",
    "PTO-SCALAR-HL-LHU-PR",
    "PTO-SCALAR-HL-LHUI",
    "PTO-SCALAR-HL-LHUI-PO",
    "PTO-SCALAR-HL-LHUI-PR",
    "PTO-SCALAR-HL-LHUI-U",
    "PTO-SCALAR-HL-LHUI-UPO",
    "PTO-SCALAR-HL-LHUI-UPR",
    "PTO-SCALAR-HL-LHUIP",
    "PTO-SCALAR-HL-LHUIP-U",
    "PTO-SCALAR-HL-LHUP",
    "PTO-SCALAR-HL-LIS",
    "PTO-SCALAR-HL-LIU",
    "PTO-SCALAR-HL-LUI",
    "PTO-SCALAR-HL-LW-PCR",
    "PTO-SCALAR-HL-LW-PO",
    "PTO-SCALAR-HL-LW-PR",
    "PTO-SCALAR-HL-LWI",
    "PTO-SCALAR-HL-LWI-PO",
    "PTO-SCALAR-HL-LWI-PR",
    "PTO-SCALAR-HL-LWI-U",
    "PTO-SCALAR-HL-LWI-UPO",
    "PTO-SCALAR-HL-LWI-UPR",
    "PTO-SCALAR-HL-LWIP",
    "PTO-SCALAR-HL-LWIP-U",
    "PTO-SCALAR-HL-LWP",
    "PTO-SCALAR-HL-LWU-PCR",
    "PTO-SCALAR-HL-LWU-PO",
    "PTO-SCALAR-HL-LWU-PR",
    "PTO-SCALAR-HL-LWUI",
    "PTO-SCALAR-HL-LWUI-PO",
    "PTO-SCALAR-HL-LWUI-PR",
    "PTO-SCALAR-HL-LWUI-U",
    "PTO-SCALAR-HL-LWUI-UPO",
    "PTO-SCALAR-HL-LWUI-UPR",
    "PTO-SCALAR-HL-LWUIP",
    "PTO-SCALAR-HL-LWUIP-U",
    "PTO-SCALAR-HL-LWUP",
    "PTO-SCALAR-HL-MADD",
    "PTO-SCALAR-HL-MADDW",
    "PTO-SCALAR-HL-MIADD",
    "PTO-SCALAR-HL-MISUB",
    "PTO-SCALAR-HL-MUL",
    "PTO-SCALAR-HL-MULU",
    "PTO-SCALAR-HL-ORI",
    "PTO-SCALAR-HL-ORIW",
    "PTO-SCALAR-HL-PRF",
    "PTO-SCALAR-HL-PRF-A",
    "PTO-SCALAR-HL-PRFI-U",
    "PTO-SCALAR-HL-PRFI-UA",
    "PTO-SCALAR-HL-REM",
    "PTO-SCALAR-HL-REMU",
    "PTO-SCALAR-HL-REMUW",
    "PTO-SCALAR-HL-REMW",
    "PTO-SCALAR-HL-SB-PCR",
    "PTO-SCALAR-HL-SB-PO",
    "PTO-SCALAR-HL-SB-PR",
    "PTO-SCALAR-HL-SBI",
    "PTO-SCALAR-HL-SBI-PO",
    "PTO-SCALAR-HL-SBI-PR",
    "PTO-SCALAR-HL-SBIP",
    "PTO-SCALAR-HL-SBP",
    "PTO-SCALAR-HL-SD-PCR",
    "PTO-SCALAR-HL-SD-PO",
    "PTO-SCALAR-HL-SD-PR",
    "PTO-SCALAR-HL-SD-UPO",
    "PTO-SCALAR-HL-SD-UPR",
    "PTO-SCALAR-HL-SDI",
    "PTO-SCALAR-HL-SDI-PO",
    "PTO-SCALAR-HL-SDI-PR",
    "PTO-SCALAR-HL-SDI-U",
    "PTO-SCALAR-HL-SDI-UPO",
    "PTO-SCALAR-HL-SDI-UPR",
    "PTO-SCALAR-HL-SDIP",
    "PTO-SCALAR-HL-SDIP-U",
    "PTO-SCALAR-HL-SDP",
    "PTO-SCALAR-HL-SDP-U",
    "PTO-SCALAR-HL-SETC-ANDI",
    "PTO-SCALAR-HL-SETC-EQI",
    "PTO-SCALAR-HL-SETC-GEI",
    "PTO-SCALAR-HL-SETC-GEUI",
    "PTO-SCALAR-HL-SETC-LTI",
    "PTO-SCALAR-HL-SETC-LTUI",
    "PTO-SCALAR-HL-SETC-NEI",
    "PTO-SCALAR-HL-SETC-ORI",
    "PTO-SCALAR-HL-SETRET",
    "PTO-SCALAR-HL-SH-PCR",
    "PTO-SCALAR-HL-SH-PO",
    "PTO-SCALAR-HL-SH-PR",
    "PTO-SCALAR-HL-SH-UPO",
    "PTO-SCALAR-HL-SH-UPR",
    "PTO-SCALAR-HL-SHI",
    "PTO-SCALAR-HL-SHI-PO",
    "PTO-SCALAR-HL-SHI-PR",
    "PTO-SCALAR-HL-SHI-U",
    "PTO-SCALAR-HL-SHI-UPO",
    "PTO-SCALAR-HL-SHI-UPR",
    "PTO-SCALAR-HL-SHIP",
    "PTO-SCALAR-HL-SHIP-U",
    "PTO-SCALAR-HL-SHP",
    "PTO-SCALAR-HL-SHP-U",
    "PTO-SCALAR-HL-SSRGET",
    "PTO-SCALAR-HL-SSRSET",
    "PTO-SCALAR-HL-SUBI",
    "PTO-SCALAR-HL-SUBIW",
    "PTO-SCALAR-HL-SW-PCR",
    "PTO-SCALAR-HL-SW-PO",
    "PTO-SCALAR-HL-SW-PR",
    "PTO-SCALAR-HL-SW-UPO",
    "PTO-SCALAR-HL-SW-UPR",
    "PTO-SCALAR-HL-SWI",
    "PTO-SCALAR-HL-SWI-PO",
    "PTO-SCALAR-HL-SWI-PR",
    "PTO-SCALAR-HL-SWI-U",
    "PTO-SCALAR-HL-SWI-UPO",
    "PTO-SCALAR-HL-SWI-UPR",
    "PTO-SCALAR-HL-SWIP",
    "PTO-SCALAR-HL-SWIP-U",
    "PTO-SCALAR-HL-SWP",
    "PTO-SCALAR-HL-SWP-U",
    "PTO-SCALAR-HL-XORI",
    "PTO-SCALAR-HL-XORIW",
    "PTO-SCALAR-IC-IALL",
    "PTO-SCALAR-IC-IVA",
    "PTO-SCALAR-J",
    "PTO-SCALAR-JR",
    "PTO-SCALAR-LB",
    "PTO-SCALAR-LB-PCR",
    "PTO-SCALAR-LBI",
    "PTO-SCALAR-LBU",
    "PTO-SCALAR-LBU-PCR",
    "PTO-SCALAR-LBUI",
    "PTO-SCALAR-LD",
    "PTO-SCALAR-LD-ADD",
    "PTO-SCALAR-LD-AND",
    "PTO-SCALAR-LD-OR",
    "PTO-SCALAR-LD-PCR",
    "PTO-SCALAR-LD-SMAX",
    "PTO-SCALAR-LD-SMIN",
    "PTO-SCALAR-LD-UMAX",
    "PTO-SCALAR-LD-UMIN",
    "PTO-SCALAR-LD-XOR",
    "PTO-SCALAR-LDI",
    "PTO-SCALAR-LDI-U",
    "PTO-SCALAR-LH",
    "PTO-SCALAR-LH-PCR",
    "PTO-SCALAR-LHI",
    "PTO-SCALAR-LHI-U",
    "PTO-SCALAR-LHU",
    "PTO-SCALAR-LHU-PCR",
    "PTO-SCALAR-LHUI",
    "PTO-SCALAR-LHUI-U",
    "PTO-SCALAR-LR-B",
    "PTO-SCALAR-LR-D",
    "PTO-SCALAR-LR-H",
    "PTO-SCALAR-LR-W",
    "PTO-SCALAR-LSRGET",
    "PTO-SCALAR-LUI",
    "PTO-SCALAR-LW",
    "PTO-SCALAR-LW-ADD",
    "PTO-SCALAR-LW-AND",
    "PTO-SCALAR-LW-OR",
    "PTO-SCALAR-LW-PCR",
    "PTO-SCALAR-LW-SMAX",
    "PTO-SCALAR-LW-SMIN",
    "PTO-SCALAR-LW-UMAX",
    "PTO-SCALAR-LW-UMIN",
    "PTO-SCALAR-LW-XOR",
    "PTO-SCALAR-LWI",
    "PTO-SCALAR-LWI-U",
    "PTO-SCALAR-LWU",
    "PTO-SCALAR-LWU-PCR",
    "PTO-SCALAR-LWUI",
    "PTO-SCALAR-LWUI-U",
    "PTO-SCALAR-MADD",
    "PTO-SCALAR-MADDW",
    "PTO-SCALAR-MAX",
    "PTO-SCALAR-MAXU",
    "PTO-SCALAR-MIN",
    "PTO-SCALAR-MINU",
    "PTO-SCALAR-MUL",
    "PTO-SCALAR-MULU",
    "PTO-SCALAR-MULUW",
    "PTO-SCALAR-MULW",
    "PTO-SCALAR-OR",
    "PTO-SCALAR-ORI",
    "PTO-SCALAR-ORIW",
    "PTO-SCALAR-ORW",
    "PTO-SCALAR-PRF",
    "PTO-SCALAR-PRFI-U",
    "PTO-SCALAR-REM",
    "PTO-SCALAR-REMU",
    "PTO-SCALAR-REMUW",
    "PTO-SCALAR-REMW",
    "PTO-SCALAR-REV",
    "PTO-SCALAR-SB",
    "PTO-SCALAR-SB-PCR",
    "PTO-SCALAR-SBI",
    "PTO-SCALAR-SC-B",
    "PTO-SCALAR-SC-D",
    "PTO-SCALAR-SC-H",
    "PTO-SCALAR-SC-W",
    "PTO-SCALAR-SCVTF",
    "PTO-SCALAR-SD",
    "PTO-SCALAR-SD-ADD",
    "PTO-SCALAR-SD-AND",
    "PTO-SCALAR-SD-OR",
    "PTO-SCALAR-SD-PCR",
    "PTO-SCALAR-SD-SMAX",
    "PTO-SCALAR-SD-SMIN",
    "PTO-SCALAR-SD-U",
    "PTO-SCALAR-SD-UMAX",
    "PTO-SCALAR-SD-UMIN",
    "PTO-SCALAR-SD-XOR",
    "PTO-SCALAR-SDI",
    "PTO-SCALAR-SDI-U",
    "PTO-SCALAR-SETC-AND",
    "PTO-SCALAR-SETC-ANDI",
    "PTO-SCALAR-SETC-EQ",
    "PTO-SCALAR-SETC-EQI",
    "PTO-SCALAR-SETC-GE",
    "PTO-SCALAR-SETC-GEI",
    "PTO-SCALAR-SETC-GEU",
    "PTO-SCALAR-SETC-GEUI",
    "PTO-SCALAR-SETC-LT",
    "PTO-SCALAR-SETC-LTI",
    "PTO-SCALAR-SETC-LTU",
    "PTO-SCALAR-SETC-LTUI",
    "PTO-SCALAR-SETC-NE",
    "PTO-SCALAR-SETC-NEI",
    "PTO-SCALAR-SETC-OR",
    "PTO-SCALAR-SETC-ORI",
    "PTO-SCALAR-SETC-TGT",
    "PTO-SCALAR-SETRET",
    "PTO-SCALAR-SH",
    "PTO-SCALAR-SH-PCR",
    "PTO-SCALAR-SH-U",
    "PTO-SCALAR-SHI",
    "PTO-SCALAR-SHI-U",
    "PTO-SCALAR-SLL",
    "PTO-SCALAR-SLLI",
    "PTO-SCALAR-SLLIW",
    "PTO-SCALAR-SLLW",
    "PTO-SCALAR-SRA",
    "PTO-SCALAR-SRAI",
    "PTO-SCALAR-SRAIW",
    "PTO-SCALAR-SRAW",
    "PTO-SCALAR-SRL",
    "PTO-SCALAR-SRLI",
    "PTO-SCALAR-SRLIW",
    "PTO-SCALAR-SRLW",
    "PTO-SCALAR-SSRGET",
    "PTO-SCALAR-SSRSET",
    "PTO-SCALAR-SSRSWAP",
    "PTO-SCALAR-SUB",
    "PTO-SCALAR-SUBI",
    "PTO-SCALAR-SUBIW",
    "PTO-SCALAR-SUBW",
    "PTO-SCALAR-SW",
    "PTO-SCALAR-SW-ADD",
    "PTO-SCALAR-SW-AND",
    "PTO-SCALAR-SW-OR",
    "PTO-SCALAR-SW-PCR",
    "PTO-SCALAR-SW-SMAX",
    "PTO-SCALAR-SW-SMIN",
    "PTO-SCALAR-SW-U",
    "PTO-SCALAR-SW-UMAX",
    "PTO-SCALAR-SW-UMIN",
    "PTO-SCALAR-SW-XOR",
    "PTO-SCALAR-SWAPB",
    "PTO-SCALAR-SWAPD",
    "PTO-SCALAR-SWAPH",
    "PTO-SCALAR-SWAPW",
    "PTO-SCALAR-SWI",
    "PTO-SCALAR-SWI-U",
    "PTO-SCALAR-TLB-IA",
    "PTO-SCALAR-TLB-IALL",
    "PTO-SCALAR-TLB-IAV",
    "PTO-SCALAR-TLB-IV",
    "PTO-SCALAR-UCVTF",
    "PTO-SCALAR-XOR",
    "PTO-SCALAR-XORI",
    "PTO-SCALAR-XORIW",
    "PTO-SCALAR-XORW",
    "PTO-TILE-GMOV",
    "PTO-TILE-MGATHER",
    "PTO-TILE-MGATHER-CAS",
    "PTO-TILE-MGATHER-MASK",
    "PTO-TILE-MODEL-MEMORY-GM-ATOM-RED",
    "PTO-TILE-MSCATTER",
    "PTO-TILE-MSCATTER-MASK",
    "PTO-TILE-TABS",
    "PTO-TILE-TADD",
    "PTO-TILE-TADDS",
    "PTO-TILE-TAND",
    "PTO-TILE-TANDS",
    "PTO-TILE-TCI",
    "PTO-TILE-TCMP",
    "PTO-TILE-TCMPS",
    "PTO-TILE-TCOLARGMAX",
    "PTO-TILE-TCOLARGMIN",
    "PTO-TILE-TCOLEXPAND",
    "PTO-TILE-TCOLEXPANDADD",
    "PTO-TILE-TCOLEXPANDDIV",
    "PTO-TILE-TCOLEXPANDEXPDIF",
    "PTO-TILE-TCOLEXPANDMAX",
    "PTO-TILE-TCOLEXPANDMIN",
    "PTO-TILE-TCOLEXPANDMUL",
    "PTO-TILE-TCOLEXPANDSUB",
    "PTO-TILE-TCOLMAX",
    "PTO-TILE-TCOLMIN",
    "PTO-TILE-TCOLPROD",
    "PTO-TILE-TCOLSUM",
    "PTO-TILE-TCVT",
    "PTO-TILE-TDIV",
    "PTO-TILE-TDIVS",
    "PTO-TILE-TEXP",
    "PTO-TILE-TEXPANDS",
    "PTO-TILE-TFMA",
    "PTO-TILE-TGATHER",
    "PTO-TILE-TGEMV",
    "PTO-TILE-TGEMV-ACC",
    "PTO-TILE-TGEMV-BIAS",
    "PTO-TILE-TGEMV-MX",
    "PTO-TILE-TGEMV-MX-ACC",
    "PTO-TILE-TGEMV-MX-BIAS",
    "PTO-TILE-TIMG2COL",
    "PTO-TILE-TLOAD",
    "PTO-TILE-TLOG",
    "PTO-TILE-TMATMUL",
    "PTO-TILE-TMATMUL-ACC",
    "PTO-TILE-TMATMUL-BIAS",
    "PTO-TILE-TMATMUL-MX",
    "PTO-TILE-TMATMUL-MX-ACC",
    "PTO-TILE-TMATMUL-MX-BIAS",
    "PTO-TILE-TMAX",
    "PTO-TILE-TMAXS",
    "PTO-TILE-TMIN",
    "PTO-TILE-TMINS",
    "PTO-TILE-TMOV",
    "PTO-TILE-TMUL",
    "PTO-TILE-TMULS",
    "PTO-TILE-TNEG",
    "PTO-TILE-TNOT",
    "PTO-TILE-TOR",
    "PTO-TILE-TORS",
    "PTO-TILE-TPREFETCH",
    "PTO-TILE-TRECIP",
    "PTO-TILE-TRELU",
    "PTO-TILE-TREM",
    "PTO-TILE-TREMS",
    "PTO-TILE-TROWARGMAX",
    "PTO-TILE-TROWARGMIN",
    "PTO-TILE-TROWEXPAND",
    "PTO-TILE-TROWEXPANDADD",
    "PTO-TILE-TROWEXPANDDIV",
    "PTO-TILE-TROWEXPANDEXPDIF",
    "PTO-TILE-TROWEXPANDMAX",
    "PTO-TILE-TROWEXPANDMIN",
    "PTO-TILE-TROWEXPANDMUL",
    "PTO-TILE-TROWEXPANDSUB",
    "PTO-TILE-TROWMAX",
    "PTO-TILE-TROWMIN",
    "PTO-TILE-TROWPROD",
    "PTO-TILE-TROWSUM",
    "PTO-TILE-TRSQRT",
    "PTO-TILE-TSCATTER",
    "PTO-TILE-TSEL",
    "PTO-TILE-TSELS",
    "PTO-TILE-TSHL",
    "PTO-TILE-TSHLS",
    "PTO-TILE-TSHR",
    "PTO-TILE-TSHRS",
    "PTO-TILE-TSQRT",
    "PTO-TILE-TSTORE",
    "PTO-TILE-TSUB",
    "PTO-TILE-TSUBS",
    "PTO-TILE-TTRI",
    "PTO-TILE-TXOR",
    "PTO-TILE-TXORS",
    "PTO-SCALAR-MODEL-DISPATCH-DECODE",
    "PTO-SCALAR-MODEL-DISPATCH-FSU",
    "PTO-SCALAR-MODEL-FSU-PROFILE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0059"
  ],
  "amendments": [
    {
      "date": "2026-09-02",
      "baseline": "cb0d65b584ce3ad82dd133176e34a97babcfd8ca",
      "approvers": [
        "zhoubot"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/197",
      "affected_ndf": [
        "PTO-INST-SCALAR-CSEL"
      ],
      "affected_units": [
        "PTO-SCALAR-CSEL",
        "PTO-SCALAR-MODEL-DISPATCH-DECODE"
      ]
    },
    {
      "date": "2026-09-01",
      "baseline": "835ae4dbafd9fd65eda082ba8f83cb0825c9f2c0",
      "approvers": [
        "zhoubot"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/205",
      "affected_ndf": [
        "PTO-FCVTA-DECISION-BINDING-001",
        "PTO-FCVTM-DECISION-BINDING-001",
        "PTO-FCVTN-DECISION-BINDING-001",
        "PTO-FCVTP-DECISION-BINDING-001",
        "PTO-FCVTZ-DECISION-BINDING-001",
        "PTO-INST-SCALAR-FCVTA",
        "PTO-INST-SCALAR-FCVTM",
        "PTO-INST-SCALAR-FCVTN",
        "PTO-INST-SCALAR-FCVTP",
        "PTO-INST-SCALAR-FCVTZ"
      ],
      "affected_units": [
        "PTO-SCALAR-FCVTA",
        "PTO-SCALAR-FCVTM",
        "PTO-SCALAR-FCVTN",
        "PTO-SCALAR-FCVTP",
        "PTO-SCALAR-FCVTZ",
        "PTO-SCALAR-MODEL-DISPATCH-FSU",
        "PTO-SCALAR-MODEL-FSU-PROFILE"
      ]
    }
  ],
  "release_boundary": true
}
---
# ADR-GOV-0005: Mnemonic and Encoded-Field Contract Closure


## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

A mnemonic is incomplete when some field values have no named disposition, reserved values look like omissions, or generated pages omit operands, legality, effects, and composition. PTO needs total encoded-field ownership and a reproducible path from each mnemonic owner to every projection.

如果某些字段值没有具名处置、保留值看起来像遗漏，或生成页面缺少操作数、合法性、效果和组合关系，那么助记符规范并不完整。PTO 需要对编码字段进行全域所有权管理，并建立从每个助记符 owner 到各投影的可复现路径。

### Detailed decision / 详细决策

Every encoded value must be accepted, reserved, or rejected by its owning ASL contract. Per-mnemonic metadata and embedded ASL regions drive pages, catalogs, decoder witnesses, and coverage, while shared contracts carry common rules without duplicating normative behavior in prose.

每个编码值都必须由 owning ASL 契约明确归为接受、保留或拒绝。逐助记符元数据及嵌入的 ASL 区域驱动页面、目录、解码见证和覆盖；公共规则由共享契约承载，避免在文字中复制规范行为。

### What changed / 改动内容

#### English

- Closed unnamed field values with explicit dispositions.
- Expanded generated contracts from concise ASL-owned facts and shared references.
- Required future encodings to add allocation, legality, effects, rejection, and executable evidence together.

#### 中文

- 为未命名字段值补上明确处置。
- 从 ASL owner 的精简事实和共享引用生成更完整的契约。
- 要求未来编码同时补齐分配、合法性、效果、拒绝行为和可执行证据。

### Scope and boundaries / 范围与边界

This record governs encoded-field completeness and mnemonic projection for the affected families. Current semantics stay in owning ASL/NDF clauses; reserved values gain no inferred behavior and generated prose remains non-normative.

本记录管理受影响指令族的编码字段完整性和助记符投影。当前语义仍归 owning ASL/NDF 条款所有；保留值不获得推断行为，生成文字仍非规范来源。
- **Date**: 2026-08-11
- **Deciders**: PTO ISA maintainers

## Context {#PTO-DEC-0059-CONTEXT}

<!-- ndf: kind=info level=may layer=L0 status=accepted -->

PTO already projects one ASL file into one generated page for each accepted
mnemonic. The projection proves identity, encoding pieces, catalog constraints,
and handler linkage, but it does not yet prove that every field value has a
named disposition or that every mnemonic page explains the complete
architectural contract.

`B.DATR.DataType` exposes the immediate defect. The field is five bits wide and
therefore has 32 possible values. Twenty-five values name active data types;
seven values are unassigned. The current accepted-value constraint rejects the
unassigned values, but the ASL and generated page do not identify those seven
values as reserved future-extension space. A reader therefore cannot distinguish
an intentionally reserved value from an accidentally omitted definition.

The same completeness problem appears in other forms:

- generated field tables often use the placeholder role “encoded operand or
  control” instead of an architectural meaning;
- a constraint can list accepted values without naming the complement;
- cross-field legality, omission defaults, ignored fields, and no-effect cases
  are not represented uniformly;
- selector-encoded Tile mnemonics can be mistaken for standalone instruction
  words because their pages do not use one common encoding-class vocabulary;
- a semantic-handler name can appear without explaining inputs, results,
  state changes, memory behavior, fault atomicity, or ordering;
- binary comparison can prove masks and matches while missing prose or
  reserved-space drift.

This decision defines the contract that closes those gaps. It does not assign a
new opcode, selector, data type, or instruction semantic.

## Authority and source order {#PTO-DEC-0059-AUTHORITY}

<!-- ndf: kind=req level=must layer=L1 status=accepted refines=PTO-DEC-0059-CONTEXT -->

Normative instruction facts MUST have one authored home under `asl/`. Catalogs,
Markdown, MkDocs navigation, traceability, and release evidence MUST be derived
projections. A second hand-maintained JSON or Markdown instruction-description
source MUST NOT be introduced.

Executable ASL owns legality and architectural effects. Structured metadata in
the same ASL unit owns names, field roles, value descriptions, encoding class,
assembly rendering, and cross-references. A repository checker MUST compare
these two surfaces so co-location cannot hide drift.

Shared definitions MUST live once under the matching `asl/arch/` subject and be
referenced by mnemonic ASL units. Mnemonic files MUST NOT repeat large shared
enumerations merely to make their generated pages complete. The generator MUST
expand shared contracts into each relevant page.

Normative ASL and generated instruction pages MUST remain version-neutral.
Release versions belong in release metadata, manifests, and historical status
records, not in reusable instruction semantics.

## Encoded-field domain contract {#PTO-DEC-0059-FIELD-DOMAIN}

<!-- ndf: kind=req level=must layer=L1 status=accepted refines=PTO-DEC-0059-AUTHORITY -->

Every encoded field of width `N` MUST define a total disposition for all values
from zero through `2^N - 1`. The disposition is a disjoint partition:

1. **assigned** — the value has an architectural meaning;
2. **reserved** — the value has no current meaning and is held for a reviewed
   future extension.

The assigned and reserved sets MUST be disjoint and their union MUST equal the
full field domain. Immediate and opaque-bit fields whose every bit pattern is
meaningful satisfy the rule by assigning the full domain.

An assigned value MAY still fail a contextual or cross-field legality rule.
That failure does not make the value reserved. Conversely, a reserved value
MUST be rejected as an illegal instruction before architectural state, memory,
queue, descriptor, allocation, or ordering effects occur. Assemblers MUST NOT
emit reserved values, and canonical disassembly MUST NOT give them accepted
spellings.

Each field contract MUST state:

- bit width and instruction-bit pieces;
- signedness or raw-bit interpretation;
- architectural role;
- assigned values or assigned ranges and their meanings;
- reserved values or reserved ranges;
- encoded-zero meaning;
- omission/default behavior when the surrounding schema permits omission;
- static legality and any referenced cross-field legality rule;
- exception and no-effect behavior for rejection.

Reserved zero bits and fixed constants are fields for closure purposes even
when they are absent from the assembly syntax. Their required value and
rejection behavior MUST be explicit.

## `B.DATR.DataType` allocation {#PTO-DEC-0059-DATATYPE}

<!-- ndf: kind=req level=must layer=L1 status=accepted refines=PTO-DEC-0059-FIELD-DOMAIN -->

`B.DATR.DataType` MUST remain a five-bit field. It MUST use the following total
32-value allocation. This decision names the previously implicit complement;
it does not change any assigned value.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | FP64 |
| 1 | assigned | FP32 |
| 2 | assigned | TF32 |
| 3 | assigned | HF32 |
| 4 | assigned | FP16 |
| 5 | assigned | BF16 |
| 6 | assigned | HiF8 |
| 7 | assigned | E4M3 |
| 8 | assigned | E5M2 |
| 9 | assigned | E3M2 |
| 10 | assigned | E2M3 |
| 11 | assigned | E2M1X2 |
| 12 | assigned | E1M2X2 |
| 13 | assigned | E8M0 |
| 14 | assigned | HiF4X2 |
| 15 | reserved | future extension |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | reserved | future extension |
| 22 | reserved | future extension |
| 23 | reserved | future extension |
| 24 | assigned | U64 |
| 25 | assigned | U32 |
| 26 | assigned | U16 |
| 27 | assigned | U8 |
| 28 | assigned | U4X2 |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

Codes 15, 21, 22, 23, 29, 30, and 31 MUST reject. No code represents `NONE`,
`NULL`, “inherit,” or an absent data type. Code zero means FP64. If a block
schema permits `B.DATR` or its DataType contribution to be omitted, the
operation-specific schema default MUST supply a named assigned type; omission
MUST NOT be modeled by a reserved encoding.

The shared architectural data-type definition MUST own this table. `B.DATR`,
typed block starts, Tile descriptor decoding, operation legality, generated
catalogs, and all downstream PTO projections MUST reference the same
definition.
This five-bit namespace is distinct from every scalar numeric namespace and
from the six-bit TLSU transfer-type namespace. A generic ASL carrier MAY be
wider than five bits, but a `B.DATR.DataType` decode MUST consume exactly the
five encoded bits and MUST NOT acquire an additional code through a sixth bit.

## Mnemonic encoding classes {#PTO-DEC-0059-MNEMONIC-CLASS}

<!-- ndf: kind=req level=must layer=L1 status=accepted refines=PTO-DEC-0059-AUTHORITY -->

Every `PTO-INSTRUCTION` record MUST declare exactly one of the first four
encoding classes below. A named `PTO-UNIT` that is not accepted assembly syntax
MUST declare the fifth class:

1. **standalone-encoded** — one or more instruction words directly decode to
   the mnemonic;
2. **encoding-alias** — the mnemonic is an accepted alternate spelling of an
   existing encoded form and declares its canonical disassembly spelling;
3. **selector-encoded-block-operation** — the mnemonic is selected by encoded
   block fields and executes only after a valid block schema is assembled and
   committed; it has no standalone instruction word;
4. **pseudo-expansion** — the assembler expands the mnemonic into a declared
   ordered sequence of accepted encoded instructions;
5. **semantic-only** — the name is an ASL architectural helper or state
   operation, is not a mnemonic, and is not accepted assembly syntax.

Deleted spellings and names reserved for possible future use are not accepted
mnemonics. They MUST live in an explicit name-disposition ledger as either
`deleted` or `reserved-name`, with no generated accepted instruction page.
Encoding-space reservation is independent: a deleted spelling MAY have no
reserved bit pattern, while an extension form MAY require PTO to reserve an
encoding range without accepting its name or semantics.

For a selector-encoded block operation, the mnemonic ASL contract MUST state:

- the carrier start form and exact Mode/Function or family/function selector;
- required block commands and their ordering constraints;
- optional commands and their explicit defaults;
- the source of each operand and result binding;
- fields accepted by the operation and the rejection rule for nonzero surplus
  fields;
- the commit point and no-effect behavior on schema or operation rejection;
- that no standalone opcode exists.

## Per-mnemonic explanation contract {#PTO-DEC-0059-MNEMONIC-CONTENT}

<!-- ndf: kind=req level=must layer=L1 status=accepted refines=PTO-DEC-0059-MNEMONIC-CLASS -->

Each accepted mnemonic ASL unit and its generated page MUST provide the
following information. A non-applicable subject MUST be written as an explicit
`none`; it MUST NOT be silently omitted.

1. stable mnemonic ID, surface, semantic class, and execution engine where
   applicable;
2. accepted assembly forms and canonical disassembly form;
3. encoding class and encoding ownership;
4. instruction length, match/mask, fixed bits, and all encoded fields for each
   standalone form; exact canonical owner for an alias; exact ordered expansion
   for a pseudo; or exact selector/block composition for a block operation;
5. architectural meaning and complete value disposition for every field;
6. operands, result destinations, types, aliasing permissions, and source
   snapshot/write order;
7. required inputs, optional inputs, omission defaults, and the distinction
   between omitted and explicitly encoded zero;
8. legality rules, including cross-field and descriptor conditions;
9. architectural state effects and preserved state;
10. memory accesses, access order, atomicity, restart, and ordering semantics;
11. synchronous exceptions and the before-effects rejection boundary;
12. deterministic operation pseudocode or embedded ASL operation region;
13. at least one canonical assembly example and, when a reserved or boundary
    value exists, one rejecting example.

The summary MUST describe the instruction's architectural effect. Repeating the
mnemonic name, semantic family, or handler name is not an explanation.

## ASL metadata and executable ownership {#PTO-DEC-0059-ASL-SCHEMA}

<!-- ndf: kind=arch level=must layer=L2 status=accepted refines=PTO-DEC-0059-FIELD-DOMAIN,PTO-DEC-0059-MNEMONIC-CONTENT -->

The existing `PTO-INSTRUCTION` and `PTO-UNIT` records MUST be extended rather
than replaced. The extension MUST support references to shared ASL-owned
contracts so a mnemonic file remains concise. At minimum it MUST represent:

- `encoding_class`;
- `canonical_assembly` and accepted aliases;
- structured `field_contracts` or references to shared field contracts;
- operand/result roles and defaults;
- legality, state-effect, memory-effect, ordering, and exception summaries;
- block-composition data for selector-encoded operations;
- references to executable ASL regions and stable requirement IDs.

Shared field contracts MUST have stable IDs. References MUST resolve, and a
field reference MUST match the field width, pieces, and signedness in every form
that uses it. An instruction-local override MAY narrow contextual legality or
change an operand label, but MUST NOT silently change a shared raw-code meaning.

Executable decode and semantic functions MUST remain the behavior authority.
Metadata MUST be checked against decoder constraints, handler reachability, and
runtime canaries. Generated catalogs MUST contain the resolved structured
contract so downstream tools do not parse prose.

## Projection and navigation {#PTO-DEC-0059-PROJECTION}

<!-- ndf: kind=arch level=must layer=L2 status=accepted refines=PTO-DEC-0059-ASL-SCHEMA -->

The ASL tree, generated Markdown tree, and independent test tree MUST keep their
mirrored scalar/block/tile/arch classification. Each mnemonic MUST retain one
ASL file and one page. Shared architecture subjects such as data types, field
domains, state, and memory rules MUST each retain their own ASL unit and page.

Generated pages MUST render resolved value tables and shared contracts at the
point of use while linking back to their unique ASL owner. Embedded ASL regions
MUST be byte-derived from the named source region. Supplementary prose MAY add
rationale or examples but MUST NOT redefine an encoding, value, default,
legality rule, or operation.

Agent and skill entry points MUST direct readers to active ASL and generated
pages first. Legacy and historical material MUST be excluded from search and
navigation unless the task explicitly requests history.

## Verification contract {#PTO-DEC-0059-VERIFICATION}

<!-- ndf: kind=verif level=must layer=L3 status=accepted verifies=PTO-DEC-0059-FIELD-DOMAIN,PTO-DEC-0059-MNEMONIC-CONTENT,PTO-DEC-0059-PROJECTION -->

Lightweight repository validation MUST fail closed on:

- an encoded field whose assigned/reserved partition is incomplete,
  overlapping, duplicated, or out of range;
- a reserved field value that appears in accepted assembly, a positive decoder
  witness, or canonical disassembly;
- a field without an architectural role, zero meaning, and applicable default;
- a mnemonic without exactly one encoding class;
- a selector-encoded block operation without complete composition/default data;
- a standalone-encoding claim without a catalog form, or a no-standalone claim
  with an independently decoded word;
- an accepted mnemonic with a placeholder summary or missing required subject;
- unresolved shared-contract references;
- stale catalogs, pages, navigation, or embedded ASL;
- active agent navigation that routes to legacy definitions.

The manual release validation MUST additionally execute:

- one negative decode/dispatch canary for every reserved value or a generated
  exhaustive equivalent;
- assigned-value boundary witnesses for every finite selector domain;
- cross-field legality canaries;
- omission versus encoded-zero cases for every optional field;
- exact block composition and commit/fault atomicity cases for every
  selector-encoded operation;
- end-to-end ASL-to-catalog-to-page-to-test traceability for every mnemonic.

The pull-request path MAY run only the lightweight structural and projection
checks. Exhaustive ASLRef execution and coverage remain release gates. A failed,
missing, skipped, or pending release check MUST NOT count as success.

## PTO publication boundary {#PTO-DEC-0059-PUBLICATION}

<!-- ndf: kind=req level=must layer=L1 status=accepted depends-on=PTO-DEC-0059-FIELD-DOMAIN,PTO-DEC-0059-MNEMONIC-CONTENT -->

PTO MUST publish one exact release commit, tree, and manifest. Every downstream
consumer of a PTO scalar, block, or Tile mnemonic MUST consume structured PTO
projections and preserve:

- encoding class, length, mask, match, fixed bits, fields, and constraints;
- assigned and reserved field-value dispositions;
- canonical assembly/disassembly and accepted common aliases;
- operand/result roles, defaults, legality, state effects, memory effects,
  ordering, exceptions, and block composition.

Extension instructions MUST remain outside the PTO accepted surface. PTO MUST
reserve every extension encoding space that could otherwise conflict, without
accepting the extension mnemonic or semantics. A reserved PTO field value or
encoding range may be assigned only by a new accepted PTO architecture
decision.

A downstream conformance comparator MUST consume structured PTO projections,
not prose or mnemonic counts. A mismatch MUST reject the downstream artifact.

## Delivery sequence {#PTO-DEC-0059-DELIVERY}

<!-- ndf: kind=arch level=must layer=L2 status=accepted depends-on=PTO-DEC-0059-VERIFICATION,PTO-DEC-0059-PUBLICATION -->

Implementation MUST proceed in this order:

1. extend the ASL metadata schema and lightweight closure checker without
   changing instruction behavior;
2. make the shared DataType contract total and update `B.DATR` plus all typed
   consumers;
3. close the remaining block field domains and block composition contracts;
4. audit and complete every scalar mnemonic;
5. audit and complete every selector-encoded Tile mnemonic;
6. regenerate catalogs, pages, navigation, traceability, and release evidence;
7. run the complete PTO release validation on one clean exact commit;
8. publish the exact PTO release manifest and reject downstream artifacts that
   do not carry that identity.

Each step MUST preserve reviewed masks, matches, selectors, and existing
semantics unless a separate accepted architecture decision explicitly changes
them. Mechanical schema/projection work and normative semantic changes MUST NOT
be hidden in one undifferentiated commit.

## Acceptance criteria {#PTO-DEC-0059-ACCEPTANCE}

<!-- ndf: kind=verif level=must layer=L3 status=accepted verifies=PTO-DEC-0059-DELIVERY -->

This decision is complete only when all of the following are true:

- `B.DATR.DataType` reports 25 assigned and seven reserved values, with all 32
  values covered exactly once;
- every reserved DataType value rejects before effects;
- every encoded field in the accepted PTO surface has a total disposition;
- every accepted mnemonic has exactly one encoding class and all required
  explanation subjects;
- every selector-encoded Tile operation explicitly states that it has no
  standalone opcode and provides its complete block composition;
- no active catalog or page contains a placeholder architectural role or
  handler-only semantic explanation;
- ASL, catalogs, generated pages, navigation, tests, and traceability compare
  cleanly from one source graph;
- PTO release validation succeeds for one clean exact commit;
- the release manifest binds that exact commit, tree, projections, and
  validation evidence.

## Consequences {#PTO-DEC-0059-CONSEQUENCES}

<!-- ndf: kind=info level=may layer=L0 status=accepted -->

The authored ASL grows only by concise per-mnemonic facts and references to
shared contracts. Generated pages become longer where a complete value table or
composition is necessary, but the information remains derived and searchable.
Future instruction additions must allocate from an explicitly reserved domain,
define every field and effect, add executable rejection evidence, and update
PTO encoding ownership before release. Git history remains the only legacy backup;
active normative trees do not retain parallel legacy definitions.

## Open questions {#PTO-DEC-0059-OPEN}

<!-- ndf: kind=info level=may layer=L0 status=accepted -->

None. The architectural decisions required for this design were explicitly
confirmed before this record was written. Implementation findings that expose a
new semantic ambiguity must be recorded as a new open item rather than guessed.

## Encoded-field corrections {#PTO-DEC-0059-0585-CORRECTIONS}

<!-- ndf: kind=info level=must layer=L0 status=accepted -->

Corrections to an already assigned encoded interface update the owning ASL and
evidence without allocating a new ADR. In particular:

- `CSEL` raw selector `11` negates the false source; `00`, `01`, and `10` are
  unmodified aliases.
- `FCVTA/M/N/P/Z` raw destination codes 0..3 select unsigned 64/32/16/8 and
  4..7 select signed 64/32/16/8; 8..31 are reserved.

Issues [#197](https://github.com/PTO-ISA/pto-spec/issues/197) and
[#205](https://github.com/PTO-ISA/pto-spec/issues/205) preserve the exact
encodings, regression evidence, and implementation history. For CSEL, compiler
output produced after the compiler selector table had already been remapped is
not independent architecture evidence.
