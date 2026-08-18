<!-- GENERATED FROM: asl/scalar/bru/C.SETC.EQ.asl -->
# C.SETC.EQ

**Normative ASL source:** `asl/scalar/bru/C.SETC.EQ.asl`

C.SETC.EQ - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-C-SETC-EQ}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.setc.eq srcL, srcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_setc_eq_16_03e6b07a3699 | C16 | 16 | 0x0026 / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_setc_eq_16_03e6b07a3699 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_setc_eq_16_03e6b07a3699 | SrcR | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_setc_eq_16_03e6b07a3699 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| c_setc_eq_16_03e6b07a3699 | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/C.SETC.EQ.asl -->
```asl
readonly func InstructionContractOperation_C_SETC_EQ() => ScalarOperation
begin
    return ScalarOperation_C_SETC_EQ;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/C.SETC.EQ.asl -->
```asl
readonly func InstructionContractHandler_C_SETC_EQ() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_C_SETC_EQ()
    => ScalarCondition
begin
    return ScalarCondition_EQ;
end;

pure func InstructionContractCommitResult_C_SETC_EQ(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_C_SETC_EQ(),
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

- Compute C.SETC.EQ's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- c.setc.eq srcL, srcR

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
