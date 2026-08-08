// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-TYPES-OPERATIONS","surface":"scalar","classification":["model","types","operations"],"depends_on":["PTO-ARCH-OVERVIEW-INSTRUCTION-CLASSIFICATION"]}
type ScalarBinaryOperation of enumeration {
    ScalarBinary_ADD,
    ScalarBinary_SUB,
    ScalarBinary_AND,
    ScalarBinary_OR,
    ScalarBinary_XOR,
    ScalarBinary_SLL,
    ScalarBinary_SRL,
    ScalarBinary_SRA,
    ScalarBinary_MIN,
    ScalarBinary_MINU,
    ScalarBinary_MAX,
    ScalarBinary_MAXU
};

type ScalarRightModifier of enumeration {
    ScalarRight_None,
    ScalarRight_SignedWord,
    ScalarRight_UnsignedWord,
    ScalarRight_NegateOrNot
};

type ExecutionControlRequest of enumeration {
    ExecutionControl_SendEvent,
    ExecutionControl_WaitEvent,
    ExecutionControl_WaitInterrupt,
    ExecutionControl_WaitTimeout
};

type ScalarCondition of enumeration {
    ScalarCondition_EQ,
    ScalarCondition_NE,
    ScalarCondition_LT,
    ScalarCondition_GE,
    ScalarCondition_LTU,
    ScalarCondition_GEU,
    ScalarCondition_Z,
    ScalarCondition_NZ
};

