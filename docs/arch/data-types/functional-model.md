<!-- GENERATED FROM: asl/arch/data-types/functional-model.asl -->
# Functional Model

**Executable model-contract ASL source:** `asl/arch/data-types/functional-model.asl`

This page is a generated reference view of a non-architectural functional-model contract. PTO architecture remains owned by the architectural ASL/NDF that this model contract invokes.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FUNCTIONAL-MODEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-functional-types-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the non-architectural typed observation boundary shared by ASLRef, the generated model library, and a host runner. It names model step outcomes, instruction-attempt observations, instruction lengths, access probes, and the fields in one immutable result; it does not add an instruction or architectural state.

<!-- PTO-READER-BLOCK: arch-functional-types-concepts role=concepts-state -->
## Result concepts

- `PTOFunctionalStepStatus` separates ordinary execution, synchronous trap, suspended host request, and an unsupported profile state.
- `PTOFunctionalInstructionStatus` says whether decode was not attempted, executed, or rejected.
- `PTOFunctionalInstructionLength` includes zero for a result with no fetched instruction and the four architectural lengths 16, 32, 48, and 64.
- `PTOInstructionAccessProbe` carries permission and the translated byte address as one snapshot.

<!-- PTO-READER-BLOCK: arch-functional-types-rules role=rules-interactions -->
## Step-result fields

`PTOFunctionalStepResult` records observations of pre/post TPC and BPC, the zero-extended raw instruction, selected length, precise fault identity/address/cause, origin PE, host-request token/type/argument, and deterministic model sequence. Consumers read these fields directly instead of reconstructing architectural behavior from a private decoder or runner state.

<!-- PTO-READER-BLOCK: arch-functional-types-boundaries role=boundaries -->
## Boundaries

The record is model architecture, not PTO architecture. It does not define ELF loading, stop-PC, step budgets, process exit, model-descriptor compatibility, or snapshot serialization. A zero request token/type/argument means that the result does not carry a host request; the model-control owner defines when nonzero values are present.

<!-- PTO-READER-BLOCK: arch-functional-types-example role=example-usage -->
## Non-normative reading example

For a successfully fetched scalar instruction, read `instruction_status=Executed` together with the pre/post control fields. If the same accepted instruction opens a host request, the step status is `HostRequest` while the instruction-attempt status remains `Executed`.

<!-- PTO-READER-BLOCK: arch-functional-types-related role=related-owners-navigation -->
## Related owners

- [Functional step](../dispatch/functional-step.md) populates this record.
- [Functional-model profile](../profile/functional-model.md) owns request lifecycle and completion.
- [Fault](fault.md) defines the fault identities carried here.
<!-- SUPPLEMENTARY-END -->

## Model-contract ASL

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

type PTOFunctionalInstructionStatus of enumeration {
    PTOFunctionalInstruction_NotAttempted,
    PTOFunctionalInstruction_Executed,
    PTOFunctionalInstruction_Rejected
};

type PTOFunctionalInstructionLength of integer {0,16,32,48,64};

type PTOInstructionAccessProbe of record {
    permitted: boolean,
    translated_address: Word
};

type PTOFunctionalStepResult of record {
    status: PTOFunctionalStepStatus,
    instruction_status: PTOFunctionalInstructionStatus,
    pre_tpc: Word,
    post_tpc: Word,
    pre_bpc: Word,
    post_bpc: Word,
    raw_instruction: bits(64),
    length_bits: PTOFunctionalInstructionLength,
    fault: FaultCode,
    fault_address: Word,
    fault_cause: bits(24),
    origin_pe: MemoryAgentId,
    request_token: Word,
    request_type: bits(16),
    request_argument0: Word,
    sequence: Word
};
```
<!-- GENERATED-ASL-END: unit -->
