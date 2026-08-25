<!-- GENERATED FROM: asl/scalar/bru/C.CMP.NEI.asl -->
# C.CMP.NEI

**Normative ASL source:** `asl/scalar/bru/C.CMP.NEI.asl`

C.CMP.NEI - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-C-CMP-NEI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-cmp-nei-purpose role=purpose -->
## What C.CMP.NEI does

`C.CMP.NEI` evaluates inequality over decoded scalar operands and publishes canonical XLEN one or zero.

<!-- PTO-READER-BLOCK: scalar-c-cmp-nei-mechanism role=mechanism -->
## Mechanism

The compact form snapshots implicit `T#1` as its left operand, compares it with the decoded signed immediate, and pushes the canonical result to T.

The source snapshot precedes the T push, so queue publication cannot change the value already selected.

<!-- PTO-READER-BLOCK: scalar-c-cmp-nei-inputs-outputs role=inputs-outputs -->
## Inputs and output

- Implicit `T#1` is the left source, and the implicit output is a T push.

- `simm5` supplies a signed encoded immediate.

<!-- PTO-READER-BLOCK: scalar-c-cmp-nei-effects role=effects -->
## Effects and ordering

The canonical boolean is pushed implicitly to T, then `TPC` advances by `2` bytes.

There is no encoded destination field; the instruction does not modify commit state or access memory or reservation state.

<!-- PTO-READER-BLOCK: scalar-c-cmp-nei-constraints role=constraints -->
## Legality and fault order

Encoding, reserved field values, and source availability are checked before destination, control, or `TPC` effects.

<!-- PTO-READER-BLOCK: scalar-c-cmp-nei-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

`c.cmp.nei t#1, simm, ->t` publishes XLEN one when its condition is true and XLEN zero otherwise.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.cmp.nei t#1, simm, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_cmp_nei_16_35d1f02063e2 | C16 | 16 | 0x082c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_cmp_nei_16_35d1f02063e2 | simm5 | 5 | signed | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_cmp_nei_16_35d1f02063e2 | simm5 | 5 | 0–31 | none | none | 5-bit signed immediate | Encoded zero supplies numeric zero for the 5-bit signed immediate. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm5 | 5-bit signed immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/C.CMP.NEI.asl -->
```asl
readonly func InstructionContractOperation_C_CMP_NEI() => ScalarOperation
begin
    return ScalarOperation_C_CMP_NEI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/C.CMP.NEI.asl -->
```asl
readonly func InstructionContractHandler_C_CMP_NEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;

pure func InstructionContractCondition_C_CMP_NEI()
    => ScalarCondition
begin
    return ScalarCondition_NE;
end;

pure func InstructionContractCompareResult_C_CMP_NEI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_C_CMP_NEI(),
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- C.CMP.NEI - Compare scalar operands and write the encoded boolean result.
- After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- c.cmp.nei t#1, simm, ->t
