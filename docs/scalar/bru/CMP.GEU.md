<!-- GENERATED FROM: asl/scalar/bru/CMP.GEU.asl -->
# CMP.GEU

**Normative ASL source:** `asl/scalar/bru/CMP.GEU.asl`

CMP.GEU - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-CMP-GEU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
cmp.geu SrcL, SrcR<{.sw, .uw}>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| cmp_geu_32_0c002dc415ef | L32 | 32 | 0x00007045 / 0xf800707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| cmp_geu_32_0c002dc415ef | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| cmp_geu_32_0c002dc415ef | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| cmp_geu_32_0c002dc415ef | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| cmp_geu_32_0c002dc415ef | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| cmp_geu_32_0c002dc415ef | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| cmp_geu_32_0c002dc415ef | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| cmp_geu_32_0c002dc415ef | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| cmp_geu_32_0c002dc415ef | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.GEU.asl -->
```asl
readonly func InstructionContractOperation_CMP_GEU() => ScalarOperation
begin
    return ScalarOperation_CMP_GEU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.GEU.asl -->
```asl
readonly func InstructionContractHandler_CMP_GEU() => ScalarSemanticHandler
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

- CMP.GEU - Compare scalar operands and write the encoded boolean result.
- After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- cmp.geu SrcL, SrcR<{.sw, .uw}>, ->{t, u, Rd}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
