<!-- GENERATED FROM: asl/scalar/bru/C.CMP.NEI.asl -->
# C.CMP.NEI

**Normative ASL source:** `asl/scalar/bru/C.CMP.NEI.asl`

C.CMP.NEI - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-C-CMP-NEI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
