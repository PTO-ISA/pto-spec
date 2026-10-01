<!-- GENERATED FROM: asl/scalar/bru/C.SETC.NE.asl -->
# C.SETC.NE

**Normative ASL source:** `asl/scalar/bru/C.SETC.NE.asl`

C.SETC.NE - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-C-SETC-NE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-setc-ne-purpose role=purpose -->
## What C.SETC.NE does

`C.SETC.NE` compares two scalar sources for inequality and uses the answer as the commit condition of the Conditional block that is currently executing.

It produces no register value. Its result is a decision: the bundle commit argument and the taken bit of the block argument.

<!-- PTO-READER-BLOCK: scalar-c-setc-ne-mechanism role=mechanism -->
## Mechanism

The contract returns `ScalarHandler_ExecuteSetCommit` with the condition `ScalarCondition_NE`. The model snapshots both sources, evaluates `left != right`, canonicalizes the answer to XLEN `1` or `0`, and writes that value into the commit argument.

Applicability is checked before any source is read. `C.SETC.NE` is a commit-condition setter, so it runs only while a block is active, its body is active, the block's transfer type is `Conditional`, and no earlier setter has already succeeded in this block.

When the check passes, the model also copies the canonical answer into the taken bit of the block argument and marks the block condition as set. The other block-argument fields are preserved.

Design point: the setter marker is a single block-private occurrence flag shared by the whole setter family, so a Conditional block can express exactly one commit condition and cannot be made to depend on two comparisons in sequence.

<!-- PTO-READER-BLOCK: scalar-c-setc-ne-inputs-outputs role=inputs-outputs -->
## Inputs and result

`SrcL` supplies the left scalar source and `SrcR` supplies the right scalar source. Both are complete `32`-way Reg5 sources: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`.

Encoded zero in either source names the architectural zero GPR, so the instruction can compare a register against zero.

Neither source is consumed, because both are read as values rather than as queue pops.

There is no destination field. The only observers of the result are the commit condition of the block and anything that reads the block argument afterwards.

<!-- PTO-READER-BLOCK: scalar-c-setc-ne-effects role=effects -->
## Effects and ordering

On success one update covers the commit argument, the taken bit of the block argument, and the occurrence marker, and then `TPC` advances by `2` bytes, the encoded length of the `16`-bit form.

The state contract preserves the block's `BARG.BPC`, `BARG.BPCN`, `BARG.BlockType`, and `BARG.TYPE` fields. There is no memory effect, no reservation effect, no descriptor effect, no numeric status flag, and no destination-register effect.

Design point: the commit argument already carries a canonical XLEN `1` or `0`, which is the same shape a compare writes to a register. That is what lets a later consumer read the bundle predicate and a register result through the same kind of test.

<!-- PTO-READER-BLOCK: scalar-c-setc-ne-constraints role=constraints -->
## Legality and precise faults

Wrong block placement raises `Fault_BundleControl` at the current `TPC`: no active block, an inactive body, a transfer type other than `Conditional`, or a `C.SETC.NE` after another setter has already succeeded in the same block.

That placement check runs before scalar source readiness and before any source read, so a misplaced setter changes neither the commit argument nor the occurrence marker.

A fixed-bit mismatch or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before commit state, queues, or `TPC` change. A failed first occurrence does not consume the shared marker, so the instruction can be reissued and still set the condition.

<!-- PTO-READER-BLOCK: scalar-c-setc-ne-example role=example -->
## Non-normative example

Inside a Conditional block, set GPR1 to `5` and GPR2 to `5`.

`c.setc.ne 1, 2` finds the condition holds, so the commit argument becomes `0` and the block's taken bit becomes `0`.

A second `C.SETC.NE` in the same block is rejected with `Fault_BundleControl` instead of overwriting that decision.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.setc.ne srcL, srcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_setc_ne_16_e9092e487e98 | C16 | 16 | 0x0036 / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_setc_ne_16_e9092e487e98 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_setc_ne_16_e9092e487e98 | SrcR | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_setc_ne_16_e9092e487e98 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| c_setc_ne_16_e9092e487e98 | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/C.SETC.NE.asl -->
```asl
readonly func InstructionContractOperation_C_SETC_NE() => ScalarOperation
begin
    return ScalarOperation_C_SETC_NE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/C.SETC.NE.asl -->
```asl
readonly func InstructionContractHandler_C_SETC_NE() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_C_SETC_NE()
    => ScalarCondition
begin
    return ScalarCondition_NE;
end;

pure func InstructionContractCommitResult_C_SETC_NE(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_C_SETC_NE(),
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- All SETC condition setters share one block-private successful-occurrence marker; a failed first occurrence does not consume it.

## State effects

- Compute C.SETC.NE's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
- Atomically write that value to the commit argument and BARG.TAKEN, then mark the block condition as set. Preserve BARG.BPC, BARG.BPCN, BARG.BlockType, and BARG.TYPE.
- No memory, reservation, descriptor, numeric-status, or destination-register effect occurs. Successful execution advances TPC by the encoded instruction length.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check Conditional-block applicability and the shared occurrence marker before scalar source readiness or reads.
- Snapshot all sources, compute the canonical zero-or-one condition, then atomically update the commit argument, BARG.TAKEN, and the occurrence marker.

## Exceptions

- Wrong block placement or a second successful SETC condition setter raises Illegal Block Exception before scalar source readiness or any architectural or pending-block effect.
- A fixed-bit mismatch or unavailable selected relative source raises Fault_IllegalInstruction before commit state, BARG, queues, or TPC effects.

## Examples

- c.setc.ne srcL, srcR
