<!-- GENERATED FROM: asl/arch/data-types/functional-model.asl -->
# Functional Model

**Generated-model harness ASL source:** `asl/arch/data-types/functional-model.asl`

This page is a generated reference view of non-architectural model harness ASL. Its model NDF is owned by the downstream model repository; PTO architecture remains owned by the architectural ASL/NDF it invokes.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FUNCTIONAL-MODEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-functional-types-purpose role=purpose-scope -->
## 用途与范围

本单元定义 ASLRef、生成式模型库与宿主运行器共享的类型化观测边界。它命名步骤结果、指令尝试结果、指令长度、访问探测以及单个不可变步骤结果中的字段；它本身不执行指令。

<!-- PTO-READER-BLOCK: arch-functional-types-concepts role=concepts-state -->
## 结果概念

- `PTOFunctionalStepStatus` 区分普通执行、同步陷阱、暂停的宿主请求和不受支持的配置档状态。
- `PTOFunctionalInstructionStatus` 表明解码未尝试、已执行或被拒绝。
- `PTOFunctionalInstructionLength` 包含未取到指令时使用的零，以及 16、32、48、64 四种架构长度。
- `PTOInstructionAccessProbe` 在一个快照中携带权限结果与翻译后的字节地址。

<!-- PTO-READER-BLOCK: arch-functional-types-rules role=rules-interactions -->
## 步骤结果字段

`PTOFunctionalStepResult` 记录前后 TPC/BPC、零扩展原始指令、所选长度、精确故障标识/地址/原因、来源 PE、宿主请求 token/类型/参数以及确定性的配置档序号。使用者直接读取这些字段，不从私有解码器或运行器状态重建结果。

<!-- PTO-READER-BLOCK: arch-functional-types-boundaries role=boundaries -->
## 边界

该记录不定义 ELF 装载、停止 PC、步骤预算、进程退出、模型描述符兼容性或快照序列化。请求 token/类型/参数均为零表示结果不携带宿主请求；宿主请求状态所有者定义非零值何时出现。

<!-- PTO-READER-BLOCK: arch-functional-types-example role=example-usage -->
## 非规范阅读示例

对于成功取回的标量指令，应将 `instruction_status=Executed` 与前后控制字段一起读取。如果同一条已接受指令打开宿主请求，则步骤状态为 `HostRequest`，而指令尝试状态仍为 `Executed`。

<!-- PTO-READER-BLOCK: arch-functional-types-related role=related-owners-navigation -->
## 相关所有者

- [功能步骤](../dispatch/functional-step.md)填充此记录。
- [功能模型配置档](../profile/functional-model.md)拥有请求生命周期和完成行为。
- [故障](fault.md)定义此处携带的故障标识。
<!-- SUPPLEMENTARY-END -->

## Model-harness ASL

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
