<!-- GENERATED FROM: asl/scalar/model/types/operations.asl -->
# Operations

**Normative ASL source:** `asl/scalar/model/types/operations.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-TYPES-OPERATIONS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-types-operations-purpose role=purpose-scope -->
## Purpose and scope

This unit declares four enumerations shared by the scalar model. It contains no functions; the behavior of each value is defined by the units that consume it.

| Enumeration | Values | Behavior owner |
| --- | --- | --- |
| `ScalarBinaryOperation` | 12 integer operations | [ALU semantics](../alu/semantics.md) |
| `ScalarRightModifier` | 4 right-operand transforms | [ALU semantics](../alu/semantics.md) |
| `ExecutionControlRequest` | 4 scheduling requests | [SYS semantics](../sys/semantics.md) |
| `ScalarCondition` | 8 comparison conditions | [BRU semantics](../bru/semantics.md) |

<!-- PTO-READER-BLOCK: scalar-model-types-operations-concepts role=concepts-state -->
## Concepts and visible state

`ScalarBinaryOperation` lists `ADD`, `SUB`, `AND`, `OR`, `XOR`, the shifts `SLL`, `SRL`, and `SRA`, and the minimum and maximum operations `MIN`, `MINU`, `MAX`, and `MAXU`. The U suffix marks an unsigned comparison.

`ScalarRightModifier` lists `ScalarRight_None`, `ScalarRight_SignedWord`, `ScalarRight_UnsignedWord`, and `ScalarRight_NegateOrNot`.

`ExecutionControlRequest` lists `ExecutionControl_SendEvent`, `ExecutionControl_WaitEvent`, `ExecutionControl_WaitInterrupt`, and `ExecutionControl_WaitTimeout`.

`ScalarCondition` lists `EQ`, `NE`, `LT`, `GE`, `LTU`, `GEU`, `Z`, and `NZ`.

None of these types holds state. They are names that decode and dispatch pass to semantic helpers; `ExecuteControlRequest` records its request in `_LastControlRequest`.

<!-- PTO-READER-BLOCK: scalar-model-types-operations-rules role=rules-interactions -->
## Rules and interactions

`ScalarRight_NegateOrNot` is one value with two meanings. `ApplyScalarRightModifier` treats it as bitwise NOT for the logical family and as negation otherwise.

Design point: the binary decode returns the same value for NOT and negation. ALU dispatch passes `logical_family`, so the operation decides the concrete transform. This matches the assembly suffixes: `.not` for AND, OR, and XOR, and `.neg` for ADD and SUB.

The encoded field value does not equal the enumeration position. For example, the binary ALU decode maps raw `11` to `ScalarRight_None`, while the comparison decode maps raw `00` to it. [Scalar decode helpers](../dispatch/decode.md) owns these mappings.

`SYS` dispatch maps `BSE`, `BWE`, `BWI`, and `BWT` to the four control requests in that order.

<!-- PTO-READER-BLOCK: scalar-model-types-operations-boundaries role=boundaries -->
## Architectural boundaries

`ConditionHolds` defines `Z` and `NZ`, but `ScalarConditionForOperation` in BRU dispatch never returns them. No decoded scalar form in the current ASL selects them.

`ScalarBinaryW` rejects `MIN`, `MINU`, `MAX`, and `MAXU` with an assertion. Decoded dispatch uses those four only in 64-bit form.

The unit declares a dependency on the instruction classification unit; none of these enumerations refers to it directly.

<!-- PTO-READER-BLOCK: scalar-model-types-operations-example role=example-usage -->
## Non-normative reading example

`XOR` with `SrcRType` raw `10` reaches `ExecuteDecodedBinary` with `ScalarBinary_XOR` and `logical_family` TRUE.

- The binary decode maps `10` to `ScalarRight_NegateOrNot`.
- Because the family is logical, the right operand is inverted.
- With left 0x0F, right 0x0F, and `shamt` 0, the right operand becomes 0xFFFFFFFFFFFFFFF0, and the result is 0xFFFFFFFFFFFFFFFF.

The same raw value on `ADD` would negate the right operand instead, giving 0x0F + (-0x0F) = 0.

<!-- PTO-READER-BLOCK: scalar-model-types-operations-related role=related-owners-navigation -->
## Related owners

- [ALU semantics](../alu/semantics.md) gives `ScalarBinaryOperation` and `ScalarRightModifier` their meaning.
- [BRU semantics](../bru/semantics.md) evaluates `ScalarCondition`.
- [SYS semantics](../sys/semantics.md) records `ExecutionControlRequest`.
- [Instruction classification](../../../arch/overview/instruction-classification.md) is the declared dependency.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/types/operations.asl -->
```asl
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
```
<!-- GENERATED-ASL-END: unit -->
