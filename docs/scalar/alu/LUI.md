<!-- GENERATED FROM: asl/scalar/alu/LUI.asl -->
# LUI

**Normative ASL source:** `asl/scalar/alu/LUI.asl`

LUI sign-extends its encoded 20-bit immediate to XLEN, shifts it left by 12 bits, and publishes the result through RegDst.

## Normative identity {#PTO-INST-SCALAR-LUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lui-purpose role=purpose -->
## What LUI does

`LUI` is a 32-bit encoded scalar ALU instruction that materializes `SignExtend(imm20) << 12` and publishes the XLEN value through one Reg5 destination. It reads no scalar register.

The published value is always a multiple of `4096` whose magnitude is at most `2^31`, so the instruction materializes a signed immediate in the upper `20` bits of a word.

<!-- PTO-READER-BLOCK: scalar-lui-mechanism role=mechanism -->
## How the result is formed

The owning ASL exposes `InstructionContractResult_LUI`, which returns `MaterializeLUI(encoded_immediate)`. That helper is `LSL(SignExtend{PTO_XLEN}(immediate), 12)`: the `20`-bit field is sign-extended first and shifted left afterwards. Dispatch calls it from `ScalarOperation_LUI` with `ScalarDecodedBits20(instruction, form, ScalarField_imm20)`.

```asm
lui simm, ->{t, u, Rd}
```

Design point: the shift follows the sign extension, so a negative field fills the top of the word instead of leaving zeros. `imm20 = 0x80000` materializes `0xFFFFFFFF80000000`, not `0x0000000080000000`.

<!-- PTO-READER-BLOCK: scalar-lui-inputs role=inputs-outputs -->
## Inputs and destination

- `RegDst`, instruction slice `[7 +: 5]`, receives the XLEN result or discards it.
- `imm20`, instruction slice `[12 +: 20]`, supplies the signed upper immediate.

There is no `SrcL` or `SrcR` field. The destination uses the common map: codes `1..23` write absolute GPRs, code `30` pushes `U`, code `31` pushes `T`, and code `0` with codes `24..29` discard.

Design point: with no source field, `LUI` has no read to snapshot and no temporary source availability to test. The only operand that can affect the result is the immediate, and the only state it writes is the destination.

<!-- PTO-READER-BLOCK: scalar-lui-effects role=effects -->
## Effects and ordering

The result is computed from the encoded immediate alone and then published through `RegDst`. There is no earlier architectural state for it to observe, so the ordering question reduces to the single destination write.

`TPC` advances by `4` bytes after the destination effect. `LUI` accesses no memory and changes no numeric-status, reservation, descriptor, Tile, bundle, privilege or control-flow state; the only possible queue change is the one `T` or `U` push selected by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-lui-constraints role=constraints -->
## Legality and fault boundary

Both encoded fields are fully assigned: all `32` `RegDst` codes are accepted and all `2^20` values of `imm20` are legal. Only the low opcode field is fixed, so once the form decodes the operand-legality pass has nothing left to reject.

Applicability fails only while a system-block terminal request is pending, raising `Fault_BundleControl` at `TPC`. Otherwise the only reachable fault is `Fault_IllegalInstruction` at `PC` for an encoding that does not match the form, and it is raised before the bundle body is entered. No unavailable-temporary fault exists, because there is no Reg5 source.

Design point: the immediate is `20` bits, so `SignExtend(imm20)` has magnitude at most `2^19` and the left shift by `12` produces at most `2^31`. The shift therefore stays inside XLEN for every `imm20` value, and the bits it drops out of the top of the register are redundant sign bits, so each `imm20` value materializes one distinct multiple of `4096` in the range `-2147483648` through `2147479552`.

<!-- PTO-READER-BLOCK: scalar-lui-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `imm20 = 1`, `SignExtend(1)` is `1` and the shift produces `4096`, so `RegDst` receives `4096`. With `imm20 = 0x80000`, the field is negative, `SignExtend` produces `0xFFFFFFFFFFF80000`, and the published value is `0xFFFFFFFF80000000`. The largest positive field, `imm20 = 0x7FFFF`, publishes `0x7FFFF000`.
<!-- SUPPLEMENTARY-END -->

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
