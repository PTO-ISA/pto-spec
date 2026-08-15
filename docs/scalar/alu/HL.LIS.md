<!-- GENERATED FROM: asl/scalar/alu/HL.LIS.asl -->
# HL.LIS

**Normative ASL source:** `asl/scalar/alu/HL.LIS.asl`

HL.LIS sign-extends its split encoded 32-bit immediate to XLEN and publishes the result through RegDst.

## Normative identity {#PTO-INST-SCALAR-HL-LIS}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.lis simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lis_48_908853d6ef87 | HL48 | 48 | 0x0000000d000e / 0x0000007f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lis_48_908853d6ef87 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lis_48_908853d6ef87 | simm32 | 32 | signed | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lis_48_908853d6ef87 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| hl_lis_48_908853d6ef87 | simm32 | 32 | 0–4294967295 | none | none | signed split 32-bit immediate | Encoded zero materializes numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| simm32 | signed split 32-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.LIS.asl -->
```asl
readonly func InstructionContractOperation_HL_LIS() => ScalarOperation
begin
    return ScalarOperation_HL_LIS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.LIS.asl -->
```asl
readonly func InstructionContractHandler_HL_LIS() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLongSigned;
end;

pure func InstructionContractResult_HL_LIS(
    encoded_immediate: bits(32))
    => Word
begin
    return MaterializeLongSigned(encoded_immediate);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior.

## Legality

- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Reassemble simm32 from its two encoded pieces and sign-extend bit 31 through XLEN.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot any Reg5 source before the destination effect.
- Publish the result, then advance TPC by the encoded instruction length.

## Exceptions

- Materialization is a total fixed-width operation and raises no arithmetic exception.
- A fixed-bit mismatch raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- hl.lis simm, ->{t, u, rd}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
