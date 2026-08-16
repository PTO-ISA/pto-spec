<!-- GENERATED FROM: asl/scalar/bru/J.asl -->
# J

**Normative ASL source:** `asl/scalar/bru/J.asl`

J - Jump to the PC-relative target.

## Normative identity {#PTO-INST-SCALAR-J}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
j label
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| j_32_a303cf05af42 | L32 | 32 | 0x00000037 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| j_32_a303cf05af42 | simm22 | 22 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17},{"instruction_lsb":7,"value_lsb":17,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| j_32_a303cf05af42 | simm22 | 22 | 0–4194303 | none | none | 22-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 22-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm22 | 22-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/J.asl -->
```asl
readonly func InstructionContractOperation_J() => ScalarOperation
begin
    return ScalarOperation_J;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/J.asl -->
```asl
readonly func InstructionContractHandler_J() => ScalarSemanticHandler
begin
    return ScalarHandler_JumpRelative;
end;

pure func InstructionContractUsesCurrentPC_J()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTarget_J(
    current_pc: Word,
    halfword_offset: Word)
    => Word
begin
    return current_pc + LSL(halfword_offset, 1);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- J - Jump to the PC-relative target.
- After decode and legality checks, execute the normative JumpRelative ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- j label

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
