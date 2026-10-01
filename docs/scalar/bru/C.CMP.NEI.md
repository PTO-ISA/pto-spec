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

`C.CMP.NEI` compares the value in `T#1` with the sign-extended `5`-bit immediate `simm5` and pushes the boolean inequality result into `T`.

It is a compact compare: the source and the destination are both implied by the encoding, and the only encoded operand is the immediate.

<!-- PTO-READER-BLOCK: scalar-c-cmp-nei-mechanism role=mechanism -->
## Mechanism

The contract returns `ScalarHandler_ExecuteCompare` with the condition `ScalarCondition_NE`. The model evaluates `left != right` and converts the answer to a canonical XLEN value: `1` when the condition holds and `0` when it does not.

Both operands are read before the queue write. The left operand is fixed by the handler, not by an encoded field: the model reads `T#1` as register code `24`, which selects temporary queue index zero without consuming it. The right operand is `simm5`, sign-extended from `5` bits to XLEN.

The destination is fixed too: register code `31`, which the destination model maps to a push onto the `T` queue. The model reads the implicit `T#1` source without consulting its queue-validity flag. The current ASL compares the backing `_TQueue[[0]]` word even when that entry is invalid; it does not raise a queue-validity fault. Whether that invalid read must fault or may expose the backing word remains an owner gap, so this page does not impose a software precondition.

Design point: read-then-push ordering is what makes the single queue both the source and the result carrier. The push shifts the existing entries toward older indices, so the value that was `T#1` becomes `T#2` and the new result becomes `T#1`, while the compared value is already snapshotted.

<!-- PTO-READER-BLOCK: scalar-c-cmp-nei-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `simm5` supplies the signed `5`-bit immediate, sign-extended to XLEN, so `-1` compares as the all-ones pattern rather than as `31`.
- Implicit `T#1` supplies the left operand; it is read, not consumed.
- The result is pushed onto `T` as the new `T#1`.

There are no other encoded fields. In particular there is no destination field and no right-source modifier field, so a `C.CMP.NEI` operand cannot be sign- or zero-extended the way a register-form compare operand can.

Encoded zero in `simm5` supplies numeric zero, so the instruction can test the source against zero.

<!-- PTO-READER-BLOCK: scalar-c-cmp-nei-effects role=effects -->
## Effects and ordering

On success the instruction writes exactly one queue entry and advances `TPC` by `2` bytes, the encoded length of the `16`-bit form.

It does not read or write memory, does not change reservation state, does not update the bundle commit condition, and records no numeric status flag. `C.CMP.NEI` is not a condition setter, so it can appear in any block placement that accepts an ordinary scalar instruction.

Design point: the result is a data value, not a commit decision. A program that wants to act on the comparison must still route it through a branch or through one of the commit-condition setters.

<!-- PTO-READER-BLOCK: scalar-c-cmp-nei-constraints role=constraints -->
## Legality and fault order

All `32` values of `simm5` are assigned; there is no reserved immediate and nothing for a reserved-encoding check to reject.

The check order is decode, then operand legality, then scalar source availability. Operand legality covers encoded fields only, and this form encodes no source selector: register code `24` is written into the handler, not into the instruction. The current availability preflight therefore does not validate implicit `T#1`; whether an invalid entry must raise `Fault_IllegalInstruction` remains an owner gap.

An instruction rejected for a fixed-bit mismatch leaves the `T` queue contents and the push order unchanged, and trap entry saves the original `TPC`.

<!-- PTO-READER-BLOCK: scalar-c-cmp-nei-example role=example -->
## Non-normative example

Push `7` into `T` with a preceding instruction, so `T#1` holds `7`, and place `C.CMP.NEI` at `TPC = 4096`.

`c.cmp.nei t#1, 7, ->t` compares `7` against `7`, finds the condition holds, and pushes `0` onto `T`.

The following instruction is fetched from `4096 + 2 = 4098`.
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
