---
{
  "id": "ADR-GOV-0014",
  "title": "PTO ISA 0.58.7.0 to 0.59.0 compatibility and release identity",
  "title_zh": "PTO ISA 0.58.7.0 至 0.59.0 的兼容性与发布身份",
  "status": "accepted",
  "authors": [
    "Codex"
  ],
  "approvers": [
    "Codex independent reviewer /root/release059_boundary_review"
  ],
  "created": "2026-10-18",
  "accepted": "2026-10-18",
  "rejected": null,
  "superseded": null,
  "baseline": "de57af400cf607f03730aa522a4e9bfb160596de",
  "target_releases": [
    "0.59.0.0"
  ],
  "affected_ndf": [
    "PTO-ARCH-CORE-SYNCHRONIZATION-001",
    "PTO-ARCH-DMA-ENCODING-ONLY-001",
    "PTO-ARCH-GM-OBLIGATIONS-001",
    "PTO-ARCH-KERNEL-LIFECYCLE-001",
    "PTO-ARCH-LOCAL-VTAG-LIFETIME-001",
    "PTO-ARCH-MEMORY-MODEL-COLLECTIVE-SYNC-001",
    "PTO-ARCH-MEMORY-MODEL-TRAP-RESTORE-001",
    "PTO-ARCH-PE-EXECUTION-CONTEXT-001",
    "PTO-ARCH-SHARED-VTAG-LIFETIME-001",
    "PTO-AS-TILEOP-MACRO-001",
    "PTO-B-ASSEMBLE-SHARED-GENERATION-001",
    "PTO-B-ASSEMBLE-SPECULATION-001",
    "PTO-B-DATR-FIELDS-001",
    "PTO-B-IOR-BINDING-001",
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-IOT-STREAM-001",
    "PTO-B-SHARED-WHOLE-PARENT-READY-001",
    "PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001",
    "PTO-B-SUBVIEW-SHARED-PER-PE-001",
    "PTO-BSTART-TMATMUL-ACC-CONTRACT-001",
    "PTO-BSTART-TMATMUL-BIAS-CONTRACT-001",
    "PTO-BSTART-TMATMUL-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-ACC-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-BIAS-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-CONTRACT-001",
    "PTO-COMMON-CONVERSION-001",
    "PTO-CUBE-ACCUMULATOR-OUTPUT-001",
    "PTO-CUBE-CELL-STATE-001",
    "PTO-CUBE-M32-B64-DOUBLE-CELL-001",
    "PTO-CUBE-MATRIX-SCALE-001",
    "PTO-CUBE-SHARED-TRANSPOSE-001",
    "PTO-INST-BLOCK-B-DATR",
    "PTO-INST-BLOCK-B-FPATR",
    "PTO-INST-BLOCK-B-IOR",
    "PTO-INST-BLOCK-B-IOS",
    "PTO-INST-BLOCK-B-IOT",
    "PTO-INST-BLOCK-BSTART-TMATMUL",
    "PTO-INST-BLOCK-BSTART-TMATMUL-ACC",
    "PTO-INST-BLOCK-BSTART-TMATMUL-BIAS",
    "PTO-INST-BLOCK-BSTART-TMATMULMX",
    "PTO-INST-BLOCK-BSTART-TMATMULMX-ACC",
    "PTO-INST-BLOCK-BSTART-TMATMULMX-BIAS",
    "PTO-INST-SCALAR-LD-ADD",
    "PTO-INST-SCALAR-LD-AND",
    "PTO-INST-SCALAR-LD-OR",
    "PTO-INST-SCALAR-LD-SMAX",
    "PTO-INST-SCALAR-LD-SMIN",
    "PTO-INST-SCALAR-LD-UMAX",
    "PTO-INST-SCALAR-LD-UMIN",
    "PTO-INST-SCALAR-LD-XOR",
    "PTO-INST-SCALAR-LR-B",
    "PTO-INST-SCALAR-LR-D",
    "PTO-INST-SCALAR-LR-H",
    "PTO-INST-SCALAR-LR-W",
    "PTO-INST-SCALAR-LW-ADD",
    "PTO-INST-SCALAR-LW-AND",
    "PTO-INST-SCALAR-LW-OR",
    "PTO-INST-SCALAR-LW-SMAX",
    "PTO-INST-SCALAR-LW-SMIN",
    "PTO-INST-SCALAR-LW-UMAX",
    "PTO-INST-SCALAR-LW-UMIN",
    "PTO-INST-SCALAR-LW-XOR",
    "PTO-INST-SCALAR-SB-ADD",
    "PTO-INST-SCALAR-SB-SUB",
    "PTO-INST-SCALAR-SC-B",
    "PTO-INST-SCALAR-SC-D",
    "PTO-INST-SCALAR-SC-H",
    "PTO-INST-SCALAR-SC-W",
    "PTO-INST-SCALAR-SD-ADD",
    "PTO-INST-SCALAR-SD-AND",
    "PTO-INST-SCALAR-SD-OR",
    "PTO-INST-SCALAR-SD-SMAX",
    "PTO-INST-SCALAR-SD-SMIN",
    "PTO-INST-SCALAR-SD-SUB",
    "PTO-INST-SCALAR-SD-UMAX",
    "PTO-INST-SCALAR-SD-UMIN",
    "PTO-INST-SCALAR-SD-XOR",
    "PTO-INST-SCALAR-SH-ADD",
    "PTO-INST-SCALAR-SH-SUB",
    "PTO-INST-SCALAR-SW-ADD",
    "PTO-INST-SCALAR-SW-AND",
    "PTO-INST-SCALAR-SW-OR",
    "PTO-INST-SCALAR-SW-SMAX",
    "PTO-INST-SCALAR-SW-SMIN",
    "PTO-INST-SCALAR-SW-SUB",
    "PTO-INST-SCALAR-SW-UMAX",
    "PTO-INST-SCALAR-SW-UMIN",
    "PTO-INST-SCALAR-SW-XOR",
    "PTO-INST-SCALAR-SWAPB",
    "PTO-INST-SCALAR-SWAPD",
    "PTO-INST-SCALAR-SWAPH",
    "PTO-INST-SCALAR-SWAPW",
    "PTO-INST-SCALAR-SYNC-CORE",
    "PTO-INST-TILE-GMOV",
    "PTO-INST-TILE-TABS",
    "PTO-INST-TILE-TADD",
    "PTO-INST-TILE-TADDS",
    "PTO-INST-TILE-TAND",
    "PTO-INST-TILE-TANDS",
    "PTO-INST-TILE-TCI",
    "PTO-INST-TILE-TCMP",
    "PTO-INST-TILE-TCMPS",
    "PTO-INST-TILE-TCOLARGMAX",
    "PTO-INST-TILE-TCOLARGMIN",
    "PTO-INST-TILE-TCOLEXPAND",
    "PTO-INST-TILE-TCOLEXPANDADD",
    "PTO-INST-TILE-TCOLEXPANDDIV",
    "PTO-INST-TILE-TCOLEXPANDEXPDIF",
    "PTO-INST-TILE-TCOLEXPANDMAX",
    "PTO-INST-TILE-TCOLEXPANDMIN",
    "PTO-INST-TILE-TCOLEXPANDMUL",
    "PTO-INST-TILE-TCOLEXPANDSUB",
    "PTO-INST-TILE-TCOLMAX",
    "PTO-INST-TILE-TCOLMIN",
    "PTO-INST-TILE-TCOLPROD",
    "PTO-INST-TILE-TCOLSUM",
    "PTO-INST-TILE-TCVT",
    "PTO-INST-TILE-TDIV",
    "PTO-INST-TILE-TDIVS",
    "PTO-INST-TILE-TEXP",
    "PTO-INST-TILE-TEXPANDS",
    "PTO-INST-TILE-TEXPDIF",
    "PTO-INST-TILE-TFMA",
    "PTO-INST-TILE-TLEA",
    "PTO-INST-TILE-TLOAD",
    "PTO-INST-TILE-TLOG",
    "PTO-INST-TILE-TMATMUL",
    "PTO-INST-TILE-TMATMUL-ACC",
    "PTO-INST-TILE-TMATMUL-BIAS",
    "PTO-INST-TILE-TMATMUL-MX",
    "PTO-INST-TILE-TMATMUL-MX-ACC",
    "PTO-INST-TILE-TMATMUL-MX-BIAS",
    "PTO-INST-TILE-TMAX",
    "PTO-INST-TILE-TMAXS",
    "PTO-INST-TILE-TMIN",
    "PTO-INST-TILE-TMINS",
    "PTO-INST-TILE-TMOV",
    "PTO-INST-TILE-TMUL",
    "PTO-INST-TILE-TMULS",
    "PTO-INST-TILE-TNEG",
    "PTO-INST-TILE-TNOT",
    "PTO-INST-TILE-TOR",
    "PTO-INST-TILE-TORS",
    "PTO-INST-TILE-TPACK",
    "PTO-INST-TILE-TPERMUTE",
    "PTO-INST-TILE-TPREFETCH",
    "PTO-INST-TILE-TRECIP",
    "PTO-INST-TILE-TRELU",
    "PTO-INST-TILE-TREM",
    "PTO-INST-TILE-TREMS",
    "PTO-INST-TILE-TROWARGMAX",
    "PTO-INST-TILE-TROWARGMIN",
    "PTO-INST-TILE-TROWEXPAND",
    "PTO-INST-TILE-TROWEXPANDADD",
    "PTO-INST-TILE-TROWEXPANDDIV",
    "PTO-INST-TILE-TROWEXPANDEXPDIF",
    "PTO-INST-TILE-TROWEXPANDMAX",
    "PTO-INST-TILE-TROWEXPANDMIN",
    "PTO-INST-TILE-TROWEXPANDMUL",
    "PTO-INST-TILE-TROWEXPANDSUB",
    "PTO-INST-TILE-TROWMAX",
    "PTO-INST-TILE-TROWMIN",
    "PTO-INST-TILE-TROWPROD",
    "PTO-INST-TILE-TROWSUM",
    "PTO-INST-TILE-TRSQRT",
    "PTO-INST-TILE-TSEL",
    "PTO-INST-TILE-TSELS",
    "PTO-INST-TILE-TSHL",
    "PTO-INST-TILE-TSHLS",
    "PTO-INST-TILE-TSHR",
    "PTO-INST-TILE-TSHRS",
    "PTO-INST-TILE-TSHUF",
    "PTO-INST-TILE-TSQRT",
    "PTO-INST-TILE-TSTORE",
    "PTO-INST-TILE-TSUB",
    "PTO-INST-TILE-TSUBS",
    "PTO-INST-TILE-TTRI",
    "PTO-INST-TILE-TUNPACK",
    "PTO-INST-TILE-TXOR",
    "PTO-INST-TILE-TXORS",
    "PTO-LOCAL-TILE-B64-APPLICABILITY-001",
    "PTO-REQ-STATE-001",
    "PTO-REQ-TILE-001",
    "PTO-SB-ADD-CONTRACT-001",
    "PTO-SB-SUB-CONTRACT-001",
    "PTO-SD-SUB-CONTRACT-001",
    "PTO-SH-ADD-CONTRACT-001",
    "PTO-SH-SUB-CONTRACT-001",
    "PTO-SW-SUB-CONTRACT-001",
    "PTO-SYNC-CORE-DECISION-BINDING-001",
    "PTO-TADD-CONTRACT-001",
    "PTO-TADDS-CONTRACT-001",
    "PTO-TCI-CONTRACT-001",
    "PTO-TCMP-CONTRACT-001",
    "PTO-TCMPS-CONTRACT-001",
    "PTO-TCOLARGMAX-CONTRACT-001",
    "PTO-TCOLARGMIN-CONTRACT-001",
    "PTO-TCOLEXPANDEXPDIF-CONTRACT-001",
    "PTO-TCOLMAX-CONTRACT-001",
    "PTO-TCOLMIN-CONTRACT-001",
    "PTO-TCOLPROD-CONTRACT-001",
    "PTO-TCOLSUM-CONTRACT-001",
    "PTO-TCVT-CONTRACT-001",
    "PTO-TDIVS-CONTRACT-001",
    "PTO-TEXP-CONTRACT-001",
    "PTO-TEXPDIF-CONTRACT-001",
    "PTO-THREAD-ID-PE-IDENTITY-001",
    "PTO-TILE-CARRIER-REINTERPRETATION-001",
    "PTO-TILE-MODEL-EXECUTION-MASK-APPLICABILITY-001",
    "PTO-TILE-MODEL-EXECUTION-MASK-EXPANSION-001",
    "PTO-TILE-MODEL-EXECUTION-MASK-EXPDIF-001",
    "PTO-TILE-MODEL-EXECUTION-MASK-REARRANGEMENT-001",
    "PTO-TLEA-CONTRACT-001",
    "PTO-TLOAD-MEMORY-001",
    "PTO-TMATMUL-ACC-CONTRACT-001",
    "PTO-TMATMUL-BIAS-CONTRACT-001",
    "PTO-TMATMUL-CONTRACT-001",
    "PTO-TMATMUL-MX-ACC-CONTRACT-001",
    "PTO-TMATMUL-MX-BIAS-CONTRACT-001",
    "PTO-TMATMUL-MX-CONTRACT-001",
    "PTO-TPACK-CONTRACT-001",
    "PTO-TPERMUTE-CONTRACT-001",
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
    "PTO-TSEL-CONTRACT-001",
    "PTO-TSELS-CONTRACT-001",
    "PTO-TSHUF-CONTRACT-001",
    "PTO-TSUB-CONTRACT-001",
    "PTO-TSUBS-CONTRACT-001",
    "PTO-TTRI-CONTRACT-001",
    "PTO-TUNPACK-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-MEMORY-MODEL",
    "PTO-ARCH-DATA-TYPES-MEMORY-OPERATIONS",
    "PTO-ARCH-DATA-TYPES-SYSTEM-REGISTERS",
    "PTO-ARCH-DATA-TYPES-TRAP-CONTEXT",
    "PTO-ARCH-DISPATCH-TOP-LEVEL",
    "PTO-ARCH-FEATURES-TILE-ALLOCATION",
    "PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION",
    "PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS",
    "PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS",
    "PTO-ARCH-MEMORY-MODEL-ORDERING",
    "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP",
    "PTO-ARCH-OVERVIEW-INSTRUCTION-CLASSIFICATION",
    "PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY",
    "PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT",
    "PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS",
    "PTO-ARCH-STATE-CORE-SYNCHRONIZATION",
    "PTO-ARCH-STATE-KERNEL-LIFECYCLE",
    "PTO-ARCH-STATE-LOCAL-PAYLOAD-GENERATION",
    "PTO-ARCH-STATE-PE-EXECUTION-CONTEXT",
    "PTO-ARCH-STATE-TRAP-CONTEXT",
    "PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING",
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-B-FPATR",
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-BSTART-TMATMUL",
    "PTO-BLOCK-BSTART-TMATMUL-ACC",
    "PTO-BLOCK-BSTART-TMATMUL-BIAS",
    "PTO-BLOCK-BSTART-TMATMULMX",
    "PTO-BLOCK-BSTART-TMATMULMX-ACC",
    "PTO-BLOCK-BSTART-TMATMULMX-BIAS",
    "PTO-BLOCK-MODEL-COMMIT-VALIDATION",
    "PTO-BLOCK-MODEL-DISPATCH-CELL-REARRANGEMENT-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-COMMAND-DATA-ATTRIBUTES",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
    "PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL",
    "PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY",
    "PTO-BLOCK-MODEL-DISPATCH-DESTINATION-OPERATION",
    "PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE",
    "PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-GENERATION-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-GM-OBLIGATION",
    "PTO-BLOCK-MODEL-DISPATCH-LEA-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-MATRIX-SCALE",
    "PTO-BLOCK-MODEL-DISPATCH-PREDICATE-DESTINATION",
    "PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU",
    "PTO-BLOCK-MODEL-DISPATCH-START",
    "PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-INSTRUCTION-OPERANDS",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-TIMG2COL-EXECUTION",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-GM-ATOM-RED",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-LAYOUT-CONVERSION",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-MASK",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER-MASK",
    "PTO-BLOCK-MODEL-DISPATCH-WEIGHT-SHARED-EXEC",
    "PTO-BLOCK-MODEL-LIFECYCLE-RESET",
    "PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE",
    "PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-SQUASH",
    "PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS",
    "PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS",
    "PTO-BLOCK-MODEL-OPERANDS-SCALAR-BINDINGS",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION-PE-REQUESTS",
    "PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR",
    "PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS",
    "PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING",
    "PTO-BLOCK-MODEL-STATE-CONTROL-STATE",
    "PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE",
    "PTO-BLOCK-MODEL-STATE-SHARED-GENERATION",
    "PTO-BLOCK-MODEL-STATE-SOURCE-LIFETIME",
    "PTO-BLOCK-MODEL-STATE-TYPES",
    "PTO-SCALAR-LD-ADD",
    "PTO-SCALAR-LD-AND",
    "PTO-SCALAR-LD-OR",
    "PTO-SCALAR-LD-SMAX",
    "PTO-SCALAR-LD-SMIN",
    "PTO-SCALAR-LD-UMAX",
    "PTO-SCALAR-LD-UMIN",
    "PTO-SCALAR-LD-XOR",
    "PTO-SCALAR-LR-B",
    "PTO-SCALAR-LR-D",
    "PTO-SCALAR-LR-H",
    "PTO-SCALAR-LR-W",
    "PTO-SCALAR-LW-ADD",
    "PTO-SCALAR-LW-AND",
    "PTO-SCALAR-LW-OR",
    "PTO-SCALAR-LW-SMAX",
    "PTO-SCALAR-LW-SMIN",
    "PTO-SCALAR-LW-UMAX",
    "PTO-SCALAR-LW-UMIN",
    "PTO-SCALAR-LW-XOR",
    "PTO-SCALAR-MODEL-AGU-MEMORY",
    "PTO-SCALAR-MODEL-AMO-SEMANTICS",
    "PTO-SCALAR-MODEL-DISPATCH-AMO",
    "PTO-SCALAR-MODEL-DISPATCH-DECODE",
    "PTO-SCALAR-MODEL-DISPATCH-SYS",
    "PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL",
    "PTO-SCALAR-MODEL-FSU-REFERENCE-QUANTIZATION",
    "PTO-SCALAR-MODEL-FSU-SCALAR-FP",
    "PTO-SCALAR-MODEL-SYS-SEMANTICS",
    "PTO-SCALAR-SB-ADD",
    "PTO-SCALAR-SB-SUB",
    "PTO-SCALAR-SC-B",
    "PTO-SCALAR-SC-D",
    "PTO-SCALAR-SC-H",
    "PTO-SCALAR-SC-W",
    "PTO-SCALAR-SD-ADD",
    "PTO-SCALAR-SD-AND",
    "PTO-SCALAR-SD-OR",
    "PTO-SCALAR-SD-SMAX",
    "PTO-SCALAR-SD-SMIN",
    "PTO-SCALAR-SD-SUB",
    "PTO-SCALAR-SD-UMAX",
    "PTO-SCALAR-SD-UMIN",
    "PTO-SCALAR-SD-XOR",
    "PTO-SCALAR-SH-ADD",
    "PTO-SCALAR-SH-SUB",
    "PTO-SCALAR-SW-ADD",
    "PTO-SCALAR-SW-AND",
    "PTO-SCALAR-SW-OR",
    "PTO-SCALAR-SW-SMAX",
    "PTO-SCALAR-SW-SMIN",
    "PTO-SCALAR-SW-SUB",
    "PTO-SCALAR-SW-UMAX",
    "PTO-SCALAR-SW-UMIN",
    "PTO-SCALAR-SW-XOR",
    "PTO-SCALAR-SWAPB",
    "PTO-SCALAR-SWAPD",
    "PTO-SCALAR-SWAPH",
    "PTO-SCALAR-SWAPW",
    "PTO-SCALAR-SYNC-CORE",
    "PTO-TILE-GMOV",
    "PTO-TILE-MODEL-CAPACITY-LOCAL",
    "PTO-TILE-MODEL-CAPACITY-SHARED",
    "PTO-TILE-MODEL-DISPATCH-TILE-SCALAR-AND-IMMEDIATE",
    "PTO-TILE-MODEL-DISPATCH-TOP-LEVEL",
    "PTO-TILE-MODEL-EXECUTION-COMPARISON",
    "PTO-TILE-MODEL-EXECUTION-CUBE",
    "PTO-TILE-MODEL-EXECUTION-ELEMENTWISE",
    "PTO-TILE-MODEL-EXECUTION-EXPANSION",
    "PTO-TILE-MODEL-EXECUTION-EXPDIF",
    "PTO-TILE-MODEL-EXECUTION-FUSED-MULTIPLY-ADD",
    "PTO-TILE-MODEL-EXECUTION-GENERATION",
    "PTO-TILE-MODEL-EXECUTION-INDEXED-REARRANGEMENT",
    "PTO-TILE-MODEL-EXECUTION-LEA",
    "PTO-TILE-MODEL-EXECUTION-MASK",
    "PTO-TILE-MODEL-EXECUTION-MASK-COMPARISON",
    "PTO-TILE-MODEL-EXECUTION-MASK-STATE",
    "PTO-TILE-MODEL-EXECUTION-MATRIX-SCALE",
    "PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS",
    "PTO-TILE-MODEL-EXECUTION-REARRANGEMENT",
    "PTO-TILE-MODEL-EXECUTION-REDUCTION",
    "PTO-TILE-MODEL-EXECUTION-UNARY",
    "PTO-TILE-MODEL-LEGALITY-ALLOCATION-CAPACITY",
    "PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT",
    "PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA",
    "PTO-TILE-MODEL-LEGALITY-INDEXED-REARRANGEMENT",
    "PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT",
    "PTO-TILE-MODEL-LEGALITY-LEA-OPERANDS",
    "PTO-TILE-MODEL-LEGALITY-MATRIX-FUNCTIONS",
    "PTO-TILE-MODEL-LEGALITY-MATRIX-SHAPE",
    "PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA",
    "PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA",
    "PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS",
    "PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION",
    "PTO-TILE-MODEL-MEMORY-ATOMICS",
    "PTO-TILE-MODEL-MEMORY-GATHER-SCATTER",
    "PTO-TILE-MODEL-MEMORY-GM-ATOM-RED",
    "PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-EXECUTION",
    "PTO-TILE-MODEL-MEMORY-LOAD-STORE",
    "PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT",
    "PTO-TILE-MODEL-NUMERIC-E8M0-CONVERSION",
    "PTO-TILE-MODEL-NUMERIC-FORMATS",
    "PTO-TILE-MODEL-NUMERIC-REFERENCE-CONVERSION",
    "PTO-TILE-MODEL-NUMERIC-REFERENCE-FIXED-BINARY",
    "PTO-TILE-MODEL-NUMERIC-TCVT-CONVERSION",
    "PTO-TILE-MODEL-SHAPE-CUBE-CELL",
    "PTO-TILE-MODEL-SHAPE-CUBE-DOUBLE-CELL",
    "PTO-TILE-MODEL-STATE-ALLOCATION",
    "PTO-TILE-MODEL-STATE-DESCRIPTORS",
    "PTO-TILE-MODEL-STATE-FEATURE-MAP-DESCRIPTORS",
    "PTO-TILE-MODEL-STATE-LOCAL-REGISTERS",
    "PTO-TILE-MODEL-STATE-SHARED-REGISTERS",
    "PTO-TILE-MODEL-STATE-TYPES",
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
    "PTO-TILE-TEXPDIF",
    "PTO-TILE-TFMA",
    "PTO-TILE-TLEA",
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
    "PTO-TILE-TPACK",
    "PTO-TILE-TPERMUTE",
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
    "PTO-TILE-TSEL",
    "PTO-TILE-TSELS",
    "PTO-TILE-TSHL",
    "PTO-TILE-TSHLS",
    "PTO-TILE-TSHR",
    "PTO-TILE-TSHRS",
    "PTO-TILE-TSHUF",
    "PTO-TILE-TSQRT",
    "PTO-TILE-TSTORE",
    "PTO-TILE-TSUB",
    "PTO-TILE-TSUBS",
    "PTO-TILE-TTRI",
    "PTO-TILE-TUNPACK",
    "PTO-TILE-TXOR",
    "PTO-TILE-TXORS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/391",
  "release_impact": "required",
  "release_boundary": true,
  "interface_change": true,
  "amendments": [],
  "legacy_ids": []
}
---
# ADR-GOV-0014: PTO ISA 0.58.7.0 to 0.59.0 compatibility and release identity

## Summary

Prepare architecture `0.59.0`, first publication `0.59.0.0`, and encoding ABI
`pto-isa-0.59.0-mode-function-v1` for the accepted post-`v0.58.7.0` changes.
Mask/predicate mechanisms and elementwise control flow are the principal release
features, accompanied by the current atomic and reduction operation contracts.
This record classifies the publication boundary; it defines no instruction semantics.

## Context

The immutable prior publication is `v0.58.7.0` at
`de57af400cf607f03730aa522a4e9bfb160596de`. The preparation baseline is merged
main `a5551dbb6c5ea48a8db7913eaf26140fc4caf2e9`. Issue #391 records the operator's
0.59 request and exact changed-owner inventory. The accepted scalar atomic
encoding and reservation updates already landed in #390. Their current meaning
is defined by the PTO ASL/NDF owners; a development identity is not a publication.

## Decision

Use architecture `0.59.0`, publication `0.59.0.0`, ABI
`pto-isa-0.59.0-mode-function-v1`, and the previous immutable publication as the
release-selection baseline. The affected metadata enumerates every changed NDF
and ASL-unit digest relative to that baseline, including retired identities.
Current ASL/NDF and its accepted topic decisions retain semantic ownership.

## Normative delta

This compatibility record adds no ASL behavior. Its version identity describes
the complete accepted delta only after exact-commit release verification succeeds.
Draft and excluded decisions retain their existing status and are not promoted
by a new release number.

## Externally visible interface delta

The accumulated accepted changes include Tile execution masks, predicate
carriers and destinations, elementwise control-flow construction, atomic and
reduction applicability, cooperative matrix operand views, numeric results,
and scalar atomic encoding assignments. Masking applies only to the supported
instruction/type/layout combinations defined by their owners; this release
makes no universal-predication claim. DMA.FREE.S/L and MCOPY.DS/DL remain
encoding-only reservations with rejection before effects, not executable DMA
resource operations.

The scalar op5/far recoding and newly assigned store-only atomic forms are a
binary compatibility break. TCVT explicit same-type rounding and floating
ADD/SUB signed-zero corrections also change observable results under their
accepted contracts. None of these changes receives an old-binary alias here.

## Defaults and intentionally unspecified behavior

Defaults, fault precedence, masks, ordering, and intentionally unspecified
behavior remain exactly those in current ASL/NDF. This record adds no inferred
precondition, compatibility decoder, or target-specific behavior.

## Compatibility and dependent-toolchain impact

The boundary is **breaking** relative to `v0.58.7.0`. Consumers that require the
old contract remain pinned there. Consumers adopting `v0.59.0.0` must update
exact release/ABI/content identities, audit changed encoding and semantic
contracts, rebuild and relink affected binaries, and run their own integration
cases. Old binaries must not be silently relabeled. A matching encoding hash
alone does not establish semantic compatibility.

## Alternatives considered

Reusing the old publication identity was rejected because accepted contracts
have changed. Publishing a new tag after validating a different version commit
was rejected because release evidence is bound to exact content. The version
and all generated evidence must be finalized before the single release attempt;
publication follows only its complete success.

## Risks and mitigations

A broad release can hide stale inventories or missing owner coverage. The
release-selection checker requires complete digest-drift coverage, while
strict encoding maps and negative canaries reject unreviewed assignments.
The protected workflow binds one commit, its pinned ASLRef/NDF inputs, every
planned AVS result, and certified uploaded artifacts. Missing or failed evidence
blocks publication. LLVM, ASL-MODEL, other downstream implementations, and site
publication retain independent validation and are not certified by this release.

## Implementation obligations

- Refresh active version identities and generated release evidence from owners.
- Preserve immutable historical tags and their artifacts; Git history retains
  historical projections without active duplicate definitions.
- Keep current development identity distinct from publication authority.
- Preserve every validator and negative canary; fix stale expectations only
  against the already accepted owners and focused regression evidence.

## Verification obligations

The preparation lands through a signed, independently reviewed PR with required
hosted checks. After its merge, dispatch one manual exact-commit Release
verification. Require final `Release / validate` success and every certified
artifact, verify the publication handoff, and recheck the hosted run immediately
before tagging and publication. Local checks do not grant release authority.

## Release consequences

The first eligible tag is `v0.59.0.0`. Candidate metadata is not publication.
The operator's release request authorizes publication only after the complete
exact-candidate workflow succeeds; no failed, skipped, stale, or partial result
satisfies that condition.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Accepted mask/predicate, elementwise-control, atomic, reduction,
encoding, and numeric changes need a distinct identity from `v0.58.7.0`.
Reusing the previous label would obscure changed binary assignments and numeric
results, preventing consumers from selecting and verifying the intended contract.

**中文。** 已接受的 mask/predicate、逐元素控制流、原子与归约操作、编码和
数值行为变更，需要与 `v0.58.7.0` 明确区分的发布身份。复用旧标签会掩盖
二进制编码和数值结果变化，使下游无法选择并验证期望的契约。

### Detailed decision / 详细决策

**English.** Prepare `0.59.0` / `0.59.0.0` with a new ABI identity and exact
baseline-to-candidate owner coverage. The selection inventory covers changed
NDF clauses and ASL units, including retired baseline identities. Publish only
after the complete exact-commit workflow and artifact certification succeed.

**中文。** 准备架构号 `0.59.0`、出版号 `0.59.0.0` 和新的 ABI 身份，完整记录
从已发布基线到候选版本的 NDF 条款和 ASL 单元差异，包括已退役的基线身份；
只在精确提交的完整工作流和制品认证成功后出版。

### What changed / 改动内容

#### English

- Define a breaking publication boundary for the complete accepted owner delta.
- Make mask/predicate and elementwise control flow the principal release themes.
- Include existing accepted atomic/reduction and scalar-encoding work without
  introducing new execution semantics through release prose.

#### 中文

- 对全部已接受的 owner 差异定义不兼容的发布边界。
- 将 mask/predicate 和逐元素控制流作为本次发布的主要变化。
- 纳入已接受的原子、归约和标量编码工作，不通过发布文字增加执行语义。

### Scope and boundaries / 范围与边界

**English.** Current ASL/NDF owns behavior. Unsupported masking combinations,
draft decisions, encoding-only DMA reservations, downstream implementations,
and independently published sites do not acquire acceptance from this record.

**中文。** 当前 ASL/NDF 拥有行为定义。不支持的掩码组合、草案决策、仅保留
编码的 DMA 形式、下游实现和独立发布的网站，不因本记录获得通过结论。
