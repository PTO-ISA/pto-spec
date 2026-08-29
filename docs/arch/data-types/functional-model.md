<!-- GENERATED FROM: asl/arch/data-types/functional-model.asl -->
# Functional Model

**Normative ASL source:** `asl/arch/data-types/functional-model.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FUNCTIONAL-MODEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/functional-model.asl -->
```asl
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
```
<!-- GENERATED-ASL-END: unit -->
