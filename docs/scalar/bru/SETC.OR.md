<!-- GENERATED FROM: asl/scalar/bru/SETC.OR.asl -->
# SETC.OR

**Normative ASL source:** `asl/scalar/bru/SETC.OR.asl`

SETC.OR - Combine scalar comparison results and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-OR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
setc.or SrcL, SrcR<.sw, .uw, .not>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_or_32_740134c709d2 | L32 | 32 | 0x00003065 / 0xf8007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_or_32_740134c709d2 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_or_32_740134c709d2 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| setc_or_32_740134c709d2 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_or_32_740134c709d2 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_or_32_740134c709d2 | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_or_32_740134c709d2 | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.OR.asl -->
```asl
readonly func InstructionContractOperation_SETC_OR() => ScalarOperation
begin
    return ScalarOperation_SETC_OR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.OR.asl -->
```asl
readonly func InstructionContractHandler_SETC_OR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;

pure func InstructionContractCombinesWithOR_SETC_OR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCommitLogicalValue_SETC_OR(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_SETC_OR() then
        return left OR right;
    end;
    return left AND right;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- SETC.OR - Combine scalar comparison results and update the bundle commit condition.
- After decode and legality checks, execute the normative ExecuteSetCommitLogical ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- setc.or SrcL, SrcR<.sw, .uw, .not>

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
