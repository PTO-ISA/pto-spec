<!-- GENERATED FROM: asl/scalar/bru/CMP.GEI.asl -->
# CMP.GEI

**Normative ASL source:** `asl/scalar/bru/CMP.GEI.asl`

CMP.GEI - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-CMP-GEI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
cmp.gei SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| cmp_gei_32_48bf7ea50737 | L32 | 32 | 0x00005055 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| cmp_gei_32_48bf7ea50737 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| cmp_gei_32_48bf7ea50737 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| cmp_gei_32_48bf7ea50737 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| cmp_gei_32_48bf7ea50737 | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| cmp_gei_32_48bf7ea50737 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| cmp_gei_32_48bf7ea50737 | simm12 | 12 | 0–4095 | none | none | 12-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 12-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| simm12 | 12-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.GEI.asl -->
```asl
readonly func InstructionContractOperation_CMP_GEI() => ScalarOperation
begin
    return ScalarOperation_CMP_GEI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.GEI.asl -->
```asl
readonly func InstructionContractHandler_CMP_GEI() => ScalarSemanticHandler
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

- CMP.GEI - Compare scalar operands and write the encoded boolean result.
- After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- cmp.gei SrcL, simm, ->{t, u, Rd}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
