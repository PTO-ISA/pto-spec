<!-- GENERATED FROM: asl/scalar/bru/HL.SETC.LTI.asl -->
# HL.SETC.LTI

**Normative ASL source:** `asl/scalar/bru/HL.SETC.LTI.asl`

HL.SETC.LTI - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-HL-SETC-LTI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.setc.lti SrcL, simm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_setc_lti_48_ad4ffebe877c | HL48 | 48 | 0x00004075000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_setc_lti_48_ad4ffebe877c | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_setc_lti_48_ad4ffebe877c | shamt | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_setc_lti_48_ad4ffebe877c | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_setc_lti_48_ad4ffebe877c | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| hl_setc_lti_48_ad4ffebe877c | shamt | 5 | 0–31 | none | none | shift amount | Encoded zero performs no shift. |
| hl_setc_lti_48_ad4ffebe877c | simm24 | 24 | 0–16777215 | none | none | 24-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 24-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| shamt | shift amount |
| simm24 | 24-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.SETC.LTI.asl -->
```asl
readonly func InstructionContractOperation_HL_SETC_LTI() => ScalarOperation
begin
    return ScalarOperation_HL_SETC_LTI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.SETC.LTI.asl -->
```asl
readonly func InstructionContractHandler_HL_SETC_LTI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_HL_SETC_LTI()
    => ScalarCondition
begin
    return ScalarCondition_LT;
end;

pure func InstructionContractCommitResult_HL_SETC_LTI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_HL_SETC_LTI(),
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

- Compute HL.SETC.LTI's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- hl.setc.lti SrcL, simm

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
