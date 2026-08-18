<!-- GENERATED FROM: asl/scalar/bru/SETC.AND.asl -->
# SETC.AND

**Normative ASL source:** `asl/scalar/bru/SETC.AND.asl`

SETC.AND - Combine scalar comparison results and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-AND}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
setc.and SrcL, SrcR<.sw, .uw, .not>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_and_32_90b4e93ef9d4 | L32 | 32 | 0x00002065 / 0xf8007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_and_32_90b4e93ef9d4 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_and_32_90b4e93ef9d4 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| setc_and_32_90b4e93ef9d4 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_and_32_90b4e93ef9d4 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_and_32_90b4e93ef9d4 | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_and_32_90b4e93ef9d4 | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.AND.asl -->
```asl
readonly func InstructionContractOperation_SETC_AND() => ScalarOperation
begin
    return ScalarOperation_SETC_AND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.AND.asl -->
```asl
readonly func InstructionContractHandler_SETC_AND() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;

pure func InstructionContractCombinesWithOR_SETC_AND()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCommitLogicalValue_SETC_AND(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_SETC_AND() then
        return left OR right;
    end;
    return left AND right;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- All SETC condition setters share one block-private successful-occurrence marker; a failed first occurrence does not consume it.

## State effects

- Compute SETC.AND's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.and SrcL, SrcR<.sw, .uw, .not>

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
