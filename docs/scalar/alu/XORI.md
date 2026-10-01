<!-- GENERATED FROM: asl/scalar/alu/XORI.asl -->
# XORI

**Normative ASL source:** `asl/scalar/alu/XORI.asl`

XORI performs XLEN exclusive-or with a sign-extended signed 12-bit immediate.

## Normative identity {#PTO-INST-SCALAR-XORI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-xori-purpose role=purpose -->
## What XORI computes

`XORI` is the immediate form of the scalar exclusive OR. It sign-extends its 12-bit immediate `simm12` to the full `PTO_XLEN` width, exclusive-ORs that value with the left source `SrcL`, and publishes the complete 64-bit result through `RegDst`.

`XORI` is a 32-bit form, so a successful execution advances `TPC` by `4` bytes. It has no memory effect and raises no arithmetic exception.

Design point: the immediate form has no `SrcR` field, no `SrcRType` selector and no `shamt` shift, so there is nothing to transform or shift before the operation. All 4096 immediate encodings are usable values, and the mnemonic cannot be given a right-source modifier it does not have.

<!-- PTO-READER-BLOCK: scalar-xori-mechanism role=mechanism -->
## Immediate extension, then exclusive OR

The `simm12` field is signed. It holds a value from `-2048` through `2047`, and execution sign-extends those 12 bits to 64 bits before the operation, so a negative immediate contributes 1s in every bit above bit 10.

The operation itself is a full-width exclusive OR of `SrcL` with the extended immediate, truncated to 64 bits.

Design point: because the immediate is sign-extended, `-1` supplies an all-ones operand for all 64 bits, so `xori a0, -1, ->a0` complements `a0`. The largest positive immediate `2047` reaches only bit 10, so it can never change bits 63 through 11 of the source.

<!-- PTO-READER-BLOCK: scalar-xori-inputs role=inputs-outputs -->
## Encoded operands

- `RegDst` is a 5-bit field at instruction bits `7..11`: codes `1..23` write that absolute GPR, code `0` and codes `24..29` discard, code `30` pushes the U queue and code `31` pushes the T queue.
- `SrcL` is a 5-bit field at bits `15..19`: codes `0..23` read absolute GPRs, `24..27` read `T#1..T#4` and `28..31` read `U#1..U#4`.
- `simm12` is a signed 12-bit field at bits `20..31`.

Source code `0` reads the architectural zero register, and a T/U source is read without consuming the queue entry. An immediate encoded as zero supplies numeric zero, so `xori a0, 0, ->a1` copies `a0`.

<!-- PTO-READER-BLOCK: scalar-xori-effects role=effects -->
## Destination and ordering

`SrcL` is read before the destination is written, and the published value is computed from that pre-instruction value.

Design point: `xori a0, 255, ->a0` therefore publishes the exclusive OR of the old `a0` with `255`, not of the newly written value with `255`. Source and destination may name the same register without changing the result.

After a successful execution `TPC` advances by `4` bytes. No memory location, reservation, descriptor, numeric flag, trap, block, privilege or control-flow state changes.

<!-- PTO-READER-BLOCK: scalar-xori-constraints role=constraints -->
## Legality and the fault boundary

Every `SrcL` and `RegDst` code is assigned, and every signed 12-bit immediate from `-2048` through `2047` is legal, so `XORI` has no reserved field value. Bitwise exclusive OR is defined for every source and immediate bit pattern, so no arithmetic exception can be raised.

Before any effect the form is decoded, its encoded fields are checked, and a selected T/U source must hold a valid queue entry. A pattern owned by no form, or an unavailable `T#1..T#4` or `U#1..U#4` entry, raises `Fault_IllegalInstruction` before the destination is written and before `TPC` advances.

Design point: `XORI` has no memory operand, so a rejected `XORI` leaves the register file and `TPC` untouched: the operand-availability check runs before the destination write.

<!-- PTO-READER-BLOCK: scalar-xori-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL=0x0000000000000000` and `simm=-1` the extended immediate is `0xffffffffffffffff`, so the published value is `0xffffffffffffffff`.

With `SrcL=0x00000000000000ff` and `simm=240` the extended immediate is `0x00000000000000f0` and the published value is `0x000000000000000f`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
xori SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| xori_32_5cf7e5be17e7 | L32 | 32 | 0x00004015 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| xori_32_5cf7e5be17e7 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| xori_32_5cf7e5be17e7 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| xori_32_5cf7e5be17e7 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| xori_32_5cf7e5be17e7 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| xori_32_5cf7e5be17e7 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads the architectural zero GPR. |
| xori_32_5cf7e5be17e7 | simm12 | 12 | 0–4095 | none | none | signed 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| simm12 | signed 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/XORI.asl -->
```asl
readonly func InstructionContractOperation_XORI()
    => ScalarOperation
begin
    return ScalarOperation_XORI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/XORI.asl -->
```asl
readonly func InstructionContractHandler_XORI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_XORI()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsSigned_XORI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_XORI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, simm12, and RegDst are required encoded fields; no field can be omitted.
- simm12 is a signed 12-bit immediate from -2048 through 2047. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every signed 12-bit immediate from -2048 through 2047 is legal and is sign-extended to PTO_XLEN before the exclusive-or.

## State effects

- Sign-extend simm12 to PTO_XLEN, compute the bitwise exclusive-or with the snapshotted SrcL value, and publish the complete XLEN result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, numeric-flag, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the result and then advances TPC by four bytes.

## Exceptions

- XORI raises no arithmetic exception; bitwise exclusive-or is defined for every source and simm12 bit pattern.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- xori a0, -1, ->a0
- xori t#1, 2047, ->u
- xori zero, -2048, ->zero
