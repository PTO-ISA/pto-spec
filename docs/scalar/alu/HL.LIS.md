<!-- GENERATED FROM: asl/scalar/alu/HL.LIS.asl -->
# HL.LIS

**Normative ASL source:** `asl/scalar/alu/HL.LIS.asl`

HL.LIS sign-extends its split encoded 32-bit immediate to XLEN and publishes the result through RegDst.

## Normative identity {#PTO-INST-SCALAR-HL-LIS}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lis-purpose role=purpose -->
## What HL.LIS does

`HL.LIS` materializes a signed constant. It encodes no source register: its only operands are the immediate `simm32` and the destination `RegDst`. Decode reassembles the immediate from two pieces, sign-extends bit `31` through bit `63`, and publishes the value through `RegDst`. Successful execution advances `TPC` by `6` bytes.

Design point: the signedness comes from the mnemonic and not from the encoding. `HL.LIS` and `HL.LIU` carry the same `32` encoded bits and differ only in the extension: `HL.LIS` sign-extends, so its results lie in `-2147483648` through `2147483647`, while `HL.LIU` zero-fills and reaches `4294967295`.

<!-- PTO-READER-BLOCK: scalar-hl-lis-mechanism role=mechanism -->
## How the constant is formed

One immediate piece carries value bits `19:0` and the other carries bits `31:20`, so the reassembled `32`-bit pattern is exact and every pattern is an assigned value. The published word is that pattern with bit `31` copied through bit `63`.

Design point: because bit `63` of the result is a copy of bit `31` of the immediate, `HL.LIS` can materialize a value with the highest `PTO_XLEN` bit set, and it can do so from a constant that fits in the `32` encoded bits. Nothing is read before publication, so the published value is a function of the encoding alone.

<!-- PTO-READER-BLOCK: scalar-hl-lis-inputs role=inputs-outputs -->
## Inputs and destinations

- `simm32` carries the signed `32`-bit value.
- `RegDst` publishes it: codes `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: there is no `SrcL` field, so no register and no queue entry is read, and the destination cannot alias a source. A discard destination such as `RegDst=0` therefore performs the materialization and the `TPC` advance while leaving all register and queue state as it was.

<!-- PTO-READER-BLOCK: scalar-hl-lis-effects role=effects -->
## Effects and ordering

There is no source read to order against the publication: the value is assembled from the instruction bits, then written to the selected destination. A `T` or `U` destination push makes the new value index `1` of that queue and discards the entry that was at index `4`; a GPR destination writes that one register.

Publication is followed by the `TPC` advance of `6` bytes. `HL.LIS` performs no memory access and changes no reservation, descriptor, numeric-status, `Tile`, bundle, privilege or branch-target state.

<!-- PTO-READER-BLOCK: scalar-hl-lis-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all `32` `RegDst` codes and all `4294967296` immediate patterns of the `32`-bit field.

Two rejections are reachable, in model order. A `48`-bit word whose fixed bits match no form raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`. Both precede the destination effect and the `TPC` advance.

Design point: the third rejection that the register forms can raise, an unavailable selected `T` or `U` source, is not reachable here. This form encodes no source selector, so there is no source selector for the model to test, and the destination codes are all accepted by the destination map.

`HL.LIS` adds no arithmetic exception: sign extension of a `32`-bit value cannot overflow.

<!-- PTO-READER-BLOCK: scalar-hl-lis-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With the immediate bits `0xFFFFFFFF`, `hl.lis -1, ->a0` writes `18446744073709551615`. With the immediate bits `0x7FFFFFFF`, `hl.lis 2147483647, ->a0` writes `2147483647`, and `hl.lis 0, ->t` pushes `0` as the newest `T` entry.
<!-- SUPPLEMENTARY-END -->

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
