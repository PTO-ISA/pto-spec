<!-- GENERATED FROM: asl/scalar/bru/B.NZ.asl -->
# B.NZ

**Normative ASL source:** `asl/scalar/bru/B.NZ.asl`

B.NZ - Conditionally branch to the PC-relative target after comparing scalar operands.

## Normative identity {#PTO-INST-SCALAR-B-NZ}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
b.nz label
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_nz_32_0f583cdd8d4d | L32 | 32 | 0x00002037 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_nz_32_0f583cdd8d4d | simm22 | 22 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17},{"instruction_lsb":7,"value_lsb":17,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_nz_32_0f583cdd8d4d | simm22 | 22 | 0–4194303 | none | none | 22-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 22-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm22 | 22-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/B.NZ.asl -->
```asl
readonly func InstructionContractOperation_B_NZ() => ScalarOperation
begin
    return ScalarOperation_B_NZ;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/B.NZ.asl -->
```asl
readonly func InstructionContractHandler_B_NZ() => ScalarSemanticHandler
begin
    return ScalarHandler_BranchRelative;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- B.NZ - Conditionally branch to the PC-relative target after comparing scalar operands.
- After decode and legality checks, execute the normative BranchRelative ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- b.nz label

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
