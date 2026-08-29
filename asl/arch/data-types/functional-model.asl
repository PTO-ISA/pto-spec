// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FUNCTIONAL-MODEL","surface":"arch","classification":["data-types","functional-model"],"depends_on":["PTO-ARCH-DATA-TYPES-FAULT"]}
type PTOFunctionalStepStatus of enumeration {
    PTOFunctionalStep_Executed,
    PTOFunctionalStep_Trap,
    PTOFunctionalStep_HostRequest,
    PTOFunctionalStep_Unsupported
};

type PTOFunctionalHostCompletionStatus of enumeration {
    PTOFunctionalHostCompletion_Accepted,
    PTOFunctionalHostCompletion_Rejected
};

type PTOFunctionalInstructionLength of integer {0,16,32,48,64};

type PTOInstructionAccessProbe of record {
    permitted: boolean,
    translated_address: Word
};

type PTOFunctionalStepResult of record {
    status: PTOFunctionalStepStatus,
    pre_tpc: Word,
    post_tpc: Word,
    pre_bpc: Word,
    post_bpc: Word,
    raw_instruction: bits(64),
    length_bits: PTOFunctionalInstructionLength,
    fault: FaultCode,
    fault_address: Word,
    origin_pe: MemoryAgentId,
    request_token: Word,
    sequence: Word
};
