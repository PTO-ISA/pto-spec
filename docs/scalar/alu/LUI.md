<!-- GENERATED FROM: asl/scalar/alu/LUI.asl -->
# LUI

**Normative ASL source:** `asl/scalar/alu/LUI.asl`

LUI sign-extends its encoded 20-bit immediate to XLEN, shifts it left by 12 bits, and publishes the result through RegDst.

## Normative identity {#PTO-INST-SCALAR-LUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
lui simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lui_32_982113b541d6 | L32 | 32 | 0x00000017 / 0x0000007f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lui_32_982113b541d6 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lui_32_982113b541d6 | imm20 | 20 | encoding-defined | [{"instruction_lsb":12,"value_lsb":0,"width":20}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lui_32_982113b541d6 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| lui_32_982113b541d6 | imm20 | 20 | 0–1048575 | none | none | signed upper 20-bit immediate | Encoded zero materializes numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| imm20 | signed upper 20-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/LUI.asl -->
```asl
readonly func InstructionContractOperation_LUI() => ScalarOperation
begin
    return ScalarOperation_LUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/LUI.asl -->
```asl
readonly func InstructionContractHandler_LUI() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLUI;
end;

pure func InstructionContractResult_LUI(
    encoded_immediate: bits(20))
    => Word
begin
    return MaterializeLUI(encoded_immediate);
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

- Sign-extend imm20 to XLEN, shift left by 12, and discard overflow beyond XLEN.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

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

- lui simm, ->{t, u, rd}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
