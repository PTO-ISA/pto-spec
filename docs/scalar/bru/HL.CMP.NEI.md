<!-- GENERATED FROM: asl/scalar/bru/HL.CMP.NEI.asl -->
# HL.CMP.NEI

**Normative ASL source:** `asl/scalar/bru/HL.CMP.NEI.asl`

HL.CMP.NEI - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-HL-CMP-NEI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.cmp.nei SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_cmp_nei_48_e77da507704a | HL48 | 48 | 0x00001055000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_cmp_nei_48_e77da507704a | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_cmp_nei_48_e77da507704a | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_cmp_nei_48_e77da507704a | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_cmp_nei_48_e77da507704a | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| hl_cmp_nei_48_e77da507704a | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| hl_cmp_nei_48_e77da507704a | simm24 | 24 | 0–16777215 | none | none | 24-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 24-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| simm24 | 24-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.CMP.NEI.asl -->
```asl
readonly func InstructionContractOperation_HL_CMP_NEI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_NEI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.CMP.NEI.asl -->
```asl
readonly func InstructionContractHandler_HL_CMP_NEI() => ScalarSemanticHandler
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

- HL.CMP.NEI - Compare scalar operands and write the encoded boolean result.
- After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- hl.cmp.nei SrcL, simm, ->{t, u, Rd}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
